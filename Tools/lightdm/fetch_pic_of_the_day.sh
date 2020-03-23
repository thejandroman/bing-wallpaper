#!/bin/sh

set -e
set -o pipefail

#
# Copy script to /var/lib/lightdm/bin/ and configure Seat in
# lightdm.conf as follows:
#
#   display-setup-script=/var/lib/lightdm/bin/fetch_pic_of_the_day.sh -m de-DE -r 1366x768
#
# Params are passed directly to bing-wallpaper.sh. Modify as you like.
# Make sure $USER_NAME is able to write to $PIC_DIR and $LOGFILE.
#
# $PIC_DIR/$PIC_NAME is a symbolic link to the picture of the day.
# Configure your lightdm greeter accordingly and enjoy!
#

BIN_BASH=/bin/bash
BIN_BING_WP=/usr/bin/bing-wallpaper.sh
USER_NAME=lightdm
PIC_DIR=/usr/share/backgrounds/bing
PIC_NAME=lightdm.jpg
LOGFILE=/tmp/fetch_pic_of_the_day.log

# Only root should call this script!
if [ $(id -u) -ne 0 ]; then
    exit 1
fi

CMD=$(cat <<-EOF

echo "################################################################################" >> $LOGFILE
echo "\$(date): Fetching pic of the day from bing.com!" >> $LOGFILE
if [ ! -d "${PIC_DIR}" ]; then
    echo "Dir ${PIC_DIR} does not exist! Abort!" >> $LOGFILE
    exit 1
fi

${BIN_BING_WP} ${@} -p $PIC_DIR >> $LOGFILE 2>&1

cd "${PIC_DIR}"
if [ -L "${PIC_NAME}" ]; then
    WALLPAPER=\$(find . -type f -name "*.jpg" -newermm ${PIC_NAME})
    if [ -n "${WALLPAPER}" ]; then
        WALLPAPER=\$(find . -type f -name "*.jpg" -newermm ${PIC_NAME} | xargs ls -tr | tail -1)
    else
        echo "Wallpaper is up-to-date." >> $LOGFILE
    fi
else
    WALLPAPER=\$(find . -type f -name "*.jpg")
    if [ -n "${WALLPAPER}" ]; then
        WALLPAPER=\$(find . -type f -name "*.jpg" | xargs ls -tr | tail -1)
    else
        echo "No wallpaper found." >> $LOGFILE
    fi
fi

if [ -n "\${WALLPAPER}" ]; then
    echo "Set wallpaper to \${WALLPAPER}." >> $LOGFILE
    ln -sf "\${WALLPAPER}" ${PIC_NAME}
fi
EOF
)

su -s "${BIN_BASH}" -c "$CMD" - "${USER_NAME}"
