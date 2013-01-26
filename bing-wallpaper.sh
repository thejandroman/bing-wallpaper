#!/usr/bin/env bash

PICTURE_DIR="$HOME/Pictures/bing-wallpapers"
# no repeat pic in all language.
no_repeat="TRUE"

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
        filename=$(echo $filename|sed -e "s/.*\/az\/hprichbg\/rb\/\(.\)/\1/")
        if [[ "$no_repeat" = "TRUE" ]]; then
            # replace language flag like EN-US, ZH-CN...
            filename=$(echo $filename|sed -e "s/\([^_]*\)_[^_]*_\(.*\)/\1_\2/")
        fi
        if [ ! -f $PICTURE_DIR/$filename ]; then
            if [[ "$p" != http://* ]]; then
                p="$bingUrl$p"
            fi
            echo "Downloading: $filename ..."
            ## debug.
            #echo "Picture URL: $p"
            #wget -q -O $PICTURE_DIR/$filename $p
            curl -Lo "$PICTURE_DIR/$filename" $p
        else
            echo "Skipped: $filename"
        fi
    done
}

dlWallpaper $BING_URL_EN $COOKIE_EN
dlWallpaper $BING_URL_CN $COOKIE_CN
