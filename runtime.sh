#!/bin/bash

# A script which will run after the Docker image is build but before the
# pibuilder.sh script.

cd /opt/pibuilder

# Setup WiFi Settings from environment variables defined
if [ -n "$PI_WIFI_SSID" ]; then
	echo "PI_WIFI_SSID=$PI_WIFI_SSID" >> /opt/pibuilder/settings.sh
fi
if [ -n "$PI_WIFI_PASS" ]; then
	echo "PI_WIFI_PASS=$PI_WIFI_PASS" >> /opt/pibuilder/settings.sh
fi

# Draw in all files from local folder and find a way to include them into the target image
# TODO - how best to do this?

sh ./scripts/pibuilder.sh
cp /opt/pibuilder/cache/os.img /target/auto-raspbian-jessie.img