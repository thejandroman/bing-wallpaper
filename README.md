[![Build Status](https://travis-ci.org/thejandroman/bing-wallpaper.svg?branch=travis)](https://travis-ci.org/thejandroman/bing-wallpaper)

Bing Wallpaper for Mac and Ubuntu
=================================

Information
-----------
A script which downloads the latest picture of the day from Bing.com and saves
it to a directory.

The script was tested on:

- Mac OS X 10.8 - 10.12
- Ubuntu 12.04 - 16.04
- Fedora 28

How to use?
-----------
* Just run the **bing-wallpaper.sh** script from the terminal. The script will
download today's bing image.
* To see available options run the script with the `--help` flag:

```
$ ./bing-wallpaper.sh --help
Usage:
  bing-wallpaper.sh [options]
  bing-wallpaper.sh -h | --help
  bing-wallpaper.sh --version

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
                                 Supported resolutions: 1920x1200 1920x1080 800x480 400x240
  -w --set-wallpaper             Set downloaded picture as wallpaper.
  -h --help                      Show this screen.
  --version                      Show version.
```

Configuration on Mac
--------------------
* Open Mac's `System Preferences` -> `Desktop & Screensaver`, add the wallpaper
directory, and configure to taste.

* To have the script run everyday automatically you will need to setup
launchd. I have provided a sample plist file, found in the Tools
directory, which can be copied to **$HOME/Library/LaunchAgents** and
loaded with the command `launchctl load
$HOME/Library/LaunchAgents/com.ideasftw.bing-wallpaper.plist`. Modify
the plist as needed to point to **bing-wallpaper.sh**.

Configuration on Ubuntu
-----------------------
**TL;DR:**

* To install Gnome background slideshow, in the terminal run:

```
$ git clone git@github.com:thejandroman/bing-wallpaper.git
$ bing-wallpaper/Tools/gnome-bing-slideshow/deploy-gnome-settings.sh
```

* Register `bing-wallpaper/bing-random-pic.sh` to run regularly.

* Change the background properties to use the new slideshow.

**How to register bing-wallpaper.sh or bing-random-pic.sh to run regularly.**

There are two ways to run the scipts regularly: cron jobs and startup
applications.
* Cron jobs:
  * Change the path of **bing-wallpaper.sh** in **Tools/bing-cron** to the
    desired script location. If left unchanged the default value is
    **~/Pictures/bing-wallpaper.sh**.
  * From the terminal run `crontab /path/to/bing-cron` to setup the cronjob.
* Startup programs:
  * From HUD, search for startup applications.
  * Add **bing-random-pic.sh** or **bing-wallpaper.sh**.
