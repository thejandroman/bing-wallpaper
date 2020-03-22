#!/usr/bin/env bash
# shellcheck disable=SC1117

readonly SCRIPT=$(basename "$0")
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
  -s --ssl                       Communicate with bing.com over SSL.
  -b --boost <n>                 Use boost mode. Try to fetch latest <n> pictures.
  -q --quiet                     Do not display log messages.
  -n --filename <file name>      The name of the downloaded picture. Defaults to
                                 the upstream name.
  -p --picturedir <picture dir>  The full path to the picture download dir.
                                 Will be created if it does not exist.
                                 [default: $HOME/Pictures/bing-wallpapers/]
  -r --resolution <resolution>   The resolution of the image to retrieve.
                                 Supported resolutions:
$(printf "                                     %s\n" ${RESOLUTIONS[*]})
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
        -s|--ssl)
            SSL=true
            ;;
        -b|--boost)
            BOOST=$(($2-1))
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
[ -n "$SSL" ]   && PROTO='https'   || PROTO='http'

# Create picture directory if it doesn't already exist
mkdir -p "${PIC_DIR}"

# Parse bing.com and acquire picture URL(s)
declare -a PIC_URL_PATHS
if [ -n "$BOOST" ]; then
    echo "not supported"
    exit 1
else
    read -a PIC_URL_PATHS < <(curl $CURL_QUIET -L "$BING_ARCHIVE_URL" |
        xmllint --xpath "//urlBase" - | sed -r "s/<[^>]+>//g")
fi

PIC_FILE=""
for PIC_URL_PATH in "${PIC_URL_PATHS[@]}"; do
    if [ -z "$FILENAME" ]; then
        FILENAME=$(echo "${PIC_URL_PATH%*/}" | sed -r "s/[^A-Za-z0-9_-]+//g")
        PIC_FILE="$PIC_DIR/${FILENAME}_${RESOLUTION}${EXTENSION}"
    else
        FILENAME="$FILENAME"
        PIC_FILE="$PIC_DIR/${FILENAME}"
    fi

    BING_PIC_URL="${BING_BASE_URL}${PIC_URL_PATH}_${RESOLUTION}${EXTENSION}"
    if [ -n "$FORCE" ] || [ ! -f "$PIC_FILE" ]; then
        print_message "Downloading: $BING_PIC_URL"
        curl $CURL_QUIET -Lo "$PIC_FILE" "$BING_PIC_URL"
    else
        print_message "Skipping: $FILENAME..."
    fi
done

if [ -n "$SET_WALLPAPER" ]; then
    /usr/bin/osascript<<END
tell application "System Events" to set picture of every desktop to ("$PICTURE_DIR/$filename" as POSIX file as alias)
END
fi
