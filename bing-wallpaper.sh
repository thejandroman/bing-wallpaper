#!/usr/bin/env bash
# shellcheck disable=SC1117

readonly SCRIPT=$(basename "$0")
readonly VERSION='0.4.0'
readonly RESOLUTIONS=(1920x1200 1920x1080 800x480 400x240)

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
                                 Supported resolutions: ${RESOLUTIONS[*]}
  -w --set-wallpaper             Set downloaded picture as wallpaper (Only mac support for now).
  -h --help                      Show this screen.
  --version                      Show version.
EOF
}

print_message() {
    if [ -z "$QUIET" ]; then
        printf "%s\n" "${1}"
    fi
}

transform_urls() {
    sed -e 's#\\u0026#\&#g' | \
    sed -e "s/\\\//g" | \
        sed -e "s/[[:digit:]]\{1,\}x[[:digit:]]\{1,\}/$RESOLUTION/" | \
        tr "\n" " "
}

# Defaults
PICTURE_DIR="$HOME/Pictures/bing-wallpapers"
RESOLUTION="1920x1080"

# Option parsing
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -r|--resolution)
            RESOLUTION="$2"
            shift
            ;;
        -p|--picturedir)
            PICTURE_DIR="$2"
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
mkdir -p "${PICTURE_DIR}"

# Parse bing.com and acquire picture URL(s)
urls=$(curl -sL $PROTO://www.bing.com | \
    grep -Eo 'url:".*?"' | \
    sed -e "s/url:\"\([^']*\)\".*/$PROTO:\/\/bing.com\1/" | \
    transform_urls)

if [ -n "$BOOST" ]; then
    archiveUrls=$(curl -sL "$PROTO://www.bing.com/HPImageArchive.aspx?format=js&n=$BOOST" | \
        grep -Eo "url\":\".*?\"" | \
        sed -e "s/url\":\"\([^\"]*\)\"/$PROTO:\/\/bing.com\1/" | \
        transform_urls)
    urls=( "${urls[@]}" "${archiveUrls[@]}" )
fi

for p in "${urls[@]}"; do
    if [ -z "$FILENAME" ]; then
        filename=$(echo "$p" | sed -e 's/.*[?&;]id=\([^&]*\).*/\1/' | grep -oe '[^\.]*\.[^\.]*$')
    else
        filename="$FILENAME"
    fi
    if [ -n "$FORCE" ] || [ ! -f "$PICTURE_DIR/$filename" ]; then
        print_message "Downloading: $filename..."
        curl $CURL_QUIET -Lo "$PICTURE_DIR/$filename" "$p"
    else
        print_message "Skipping: $filename..."
    fi
done

if [ -n "$SET_WALLPAPER" ]; then
    /usr/bin/osascript<<END
tell application "System Events" to set picture of every desktop to ("$PICTURE_DIR/$filename" as POSIX file as alias)
END
fi
