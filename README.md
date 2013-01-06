Bing Wallpaper for Mac
=====================

Information
-----------
A script which downloads the latest picture of the day from Bing.com and saves it to a directory.


[Blog entry](http://blog.ideasftw.com/bing-desktop-for-mac)

How to use?
-----------

* If desired change the default **PICTURE_DIR** in **bing-wallpaper.sh** to the wallpaper directory. If left unchanged the default value is **~/Pictures/bing-wallpapers/**.
* Change the path of **bing-wallpaper.sh** in **bing-cron** to the script location. If left unchanged the default value is **~/Pictures/bing-wallpaper.sh**.
* From the terminal run `crontab /path/to/bing-cron` to setup the cronjob.
* Open Mac's `System Preferences` -> `Desktop & Screensaver`, add the wallpaper directory, and configure to taste.

Original script completed by ktmud at https://github.com/ktmud/bing-wallpaper
