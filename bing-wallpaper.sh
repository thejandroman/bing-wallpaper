#!/usr/bin/env bash

PICTURE_DIR="$HOME/Pictures/bing-wallpapers/"

mkdir -p $PICTURE_DIR

function dlWallpaper(){
    if [[ "$1" = "cn" ]]; then
        cookieFile="bing-wallpaper-cookie-cn"
        bingUrl="http://cn.bing.com"
    elif [[ "$1" = "en" ]]; then
        cookieFile="bing-wallpaper-cookie-en"
        bingUrl="http://www.bing.com"
    else
        return 1
    fi

    urls=( $(curl --cookie "$cookieFile" -s "$bingUrl"|grep -Eo "url:'[^']*'"|sed -e "s/url:\'\([^']*\)\'/\1/"|sed -e "s/\\\//g") )
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
