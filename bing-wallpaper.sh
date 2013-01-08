#!/usr/bin/env bash

PICTURE_DIR="$HOME/Pictures/bing-wallpapers/"

mkdir -p $PICTURE_DIR

BING_URL_CN="http://cn.bing.com"
COOKIE_CN="_FS=NU=1&mkt=zh-cn&hta=on&ui=#zh-cn"

BING_URL_EN="http://www.bing.com"
COOKIE_EN="_FS=NU=1&mkt=en-us&hta=on&ui=#en-us"


function dlWallpaper(){
    bingUrl=$1
    cookie=$2

    urls=( $(curl -b "$cookie" -s "$bingUrl"|grep -Eo "url:'[^']*'"|sed -e "s/url:\'\([^']*\)\'/\1/"|sed -e "s/\\\//g") )
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

dlWallpaper $BING_URL_EN $COOKIE_EN
dlWallpaper $BING_URL_CN $COOKIE_CN
