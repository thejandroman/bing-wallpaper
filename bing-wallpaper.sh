#!/usr/bin/env bash
# shellcheck disable=SC1117

set -e
set -o pipefail

readonly SCRIPT=${0##*/}
readonly VERSION='0.4.0'
readonly RESOLUTIONS=(1920x1200 1920x1080 1366x768 800x480 400x240)
RESOLUTION="${RESOLUTIONS[2]}"

usage() {
cat <<EOF
Usage:
  $SCRIPT [options]
  $SCRIPT -h | --help
  $SCRIPT --version

Options:
  -f --force                     Force download of picture. This will overwrite
                                 the picture if the filename already exists.
  -b --boost <n>                 Use boost mode. Try to fetch latest <n> pictures.
  -q --quiet                     Do not display log messages.
  -n --filename <file name>      The name of the downloaded picture. Defaults to
                                 the upstream name.
  -p --picturedir <picture dir>  The full path to the picture download dir.
                                 Will be created if it does not exist.
                                 [default: $HOME/Pictures/bing-wallpapers/]
  -r --resolution <resolution>   The resolution of the image to retrieve.
                                 Supported resolutions:
$(printf "                                     %s\n" ${RESOLUTIONS[@]})
                                 default:
                                     ${RESOLUTION}
  -w --set-wallpaper             Set downloaded picture as wallpaper (Linux only).
  -h --help                      Show this screen.
  --version                      Show version.
EOF
}

print_message() {
    if [ -z "$QUIET" ]; then
        printf "%s\n" "${1}"
    fi
}

# Defaults
MARKET="de-DE"
BING_BASE_URL="https://www.bing.com"
BING_ARCHIVE_URL="${BING_BASE_URL}/HPImageArchive.aspx?format=xml&idx=0&n=1&mkt=$MARKET"
DIRNAME="Bilder"
PIC_DIR="$HOME/$DIRNAME/bing-wallpapers/"
EXTENSION=".jpg"

# Option parsing
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -r|--resolution)
            RESOLUTION="$2"
            PATTERN=" $RESOLUTION "
            if [[ ! " ${RESOLUTIONS[*]} " =~ "$PATTERN" ]]; then
                (>&2 printf "Unknown resolution:\n    %s\n" $RESOLUTION)
                (>&2 printf "Supported resolutions:\n")
                (>&2 printf "    %s\n" "${RESOLUTIONS[@]}")
                exit 1
            fi
            shift
            ;;
        -p|--picturedir)
            PIC_DIR="$2"
            shift
            ;;
        -n|--filename)
            FILENAME="$2"
            shift
            ;;
        -f|--force)
            FORCE=true
            ;;
        -b|--boost)
            BOOST=$(($2))
            if (( $BOOST < 1 )); then
                (>&2 printf "Num of pictures has to be greater than zero.\n")
                exit 1
            fi
            BING_ARCHIVE_URL="${BING_ARCHIVE_URL/&n=1/&n=$BOOST}"
            shift
            ;;
        -q|--quiet)
            QUIET=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -w|--set-wallpaper)
            SET_WALLPAPER=true
            ;;
        --version)
            printf "%s\n" $VERSION
            exit 0
            ;;
        *)
            (>&2 printf "Unknown parameter: %s\n" "$1")
            usage
            exit 1
            ;;
    esac
    shift
done

# Set options
[ -n "$QUIET" ] && CURL_QUIET='-s'

# Create picture directory if it doesn't already exist
mkdir -p "${PIC_DIR}"

# Parse bing.com and acquire picture URL(s)
declare -a PIC_URL_PATHS
read -a PIC_URL_PATHS < <(curl $CURL_QUIET -L "$BING_ARCHIVE_URL" |
    xmllint --xpath "//urlBase" - | sed -r "s/<[^>]+>//g" | xargs echo)

PIC_FILE=""
PIC_FILE_AS_WALLPAPER=""
COUNT=0
for PIC_URL_PATH in ${PIC_URL_PATHS[@]}; do
    if [ -z "$FILENAME" ]; then
        FILENAME_=$(echo "${PIC_URL_PATH%*/}" | sed -r "s/[^A-Za-z0-9_-]+//g")
        PIC_FILE="$PIC_DIR/${FILENAME_}_${RESOLUTION}${EXTENSION}"
    else
        PIC_FILE="$PIC_DIR/${FILENAME}"
    fi

    # The first picture?
    #   * If requested, use as wallpaper.
    #   * Reset FILENAME as it would cause override(s).
    if (( ++COUNT == 1 )); then
        PIC_FILE_AS_WALLPAPER="$PIC_FILE"
        FILENAME=""
    fi

    BING_PIC_URL="${BING_BASE_URL}${PIC_URL_PATH}_${RESOLUTION}${EXTENSION}"
    if [ -n "$FORCE" ] || [ ! -f "$PIC_FILE" ]; then
        print_message "Downloading: $BING_PIC_URL"
        curl $CURL_QUIET -Lo "$PIC_FILE" "$BING_PIC_URL"
    else
        print_message "Skipping: $BING_PIC_URL..."
    fi
done

if [ -n "$SET_WALLPAPER" ] && [ -n "$PIC_FILE_AS_WALLPAPER" ]; then
    xsetbg -onroot "$PIC_FILE_AS_WALLPAPER"
fi
