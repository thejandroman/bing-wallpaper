#!/usr/bin/env bash

PICTURE_DIR="$HOME/Pictures/bing-wallpapers/"

mkdir -p $PICTURE_DIR

CURR_DIR=$(cd "$(dirname "$0")"; pwd)
COOKIE_CN="_FS=NU=1&mkt=zh-cn&hta=on&ui=#zh-cn"
COOKIE_EN="_FS=NU=1&mkt=en-us&hta=on&ui=#en-us"


function dlWallpaper(){
    if [[ "$1" = "cn" ]]; then
        #cookieFile="${CURR_DIR}/bing-wallpaper-cookie-cn"
        cookie=$COOKIE_CN
        bingUrl="http://cn.bing.com"
    elif [[ "$1" = "en" ]]; then
        #cookieFile="${CURR_DIR}/bing-wallpaper-cookie-en"
        cookie=$COOKIE_EN
        bingUrl="http://www.bing.com"
    else
        return 1
    fi

    urls=( $(curl --cookie "$cookie" -s "$bingUrl"|grep -Eo "url:'[^']*'"|sed -e "s/url:\'\([^']*\)\'/\1/"|sed -e "s/\\\//g") )
    for p in ${urls[@]}; do
        filename=$(echo $p|sed -e "s/.*%2f\(.\)/\1/")
        if [ ! -f $PICTURE_DIR/$filename ]; then
            if [[ "$p" != http://* ]]; then
                p="$bingUrl$p"
            fi
            echo "Downloading: $filename ..."
            #wget -q -O $PICTURE_DIR/$filename $p
            curl -Lo "$PICTURE_DIR/$filename" $p
        else
            echo "Skipping: $filename ."
        fi
    done
}

dlWallpaper en
dlWallpaper cn
