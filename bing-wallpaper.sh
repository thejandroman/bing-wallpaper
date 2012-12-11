#!/usr/bin/env bash

PICTURE_DIR="$HOME/Pictures/bing-wallpapers/"

mkdir -p $PICTURE_DIR

#urls=( $(curl -s http://www.bing.com|grep -Eo "url:'.*?'"|sed -e "s/url:\'\(.*\)\'/http:\/\/bing.com\1/"|sed -e "s/\\\//g") )
urls=( $(curl -s http://cn.bing.com|grep -Eo "url:'[^']*'"|sed -e "s/url:\'\([^']*\)\'/\1/"|sed -e "s/\\\//g") )

for p in ${urls[@]}; do
    filename=$(echo $p|sed -e "s/.*%2f\(.\)/\1/")
    if [ ! -f $PICTURE_DIR/$filename ]; then
        if [[ "$p" != http://* ]]; then
            p="http://cn.bing.com$p"
        fi
        echo "Downloading: $filename ..."
        #wget -q -O $PICTURE_DIR/$filename $p
        curl -Lo "$PICTURE_DIR/$filename" $p
    else
        echo "Skipping: $filename ."
    fi
done
