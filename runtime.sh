#!/bin/bash

# A script which wraps the pibuilder.sh script with tasks that need to be
# performed before and after the script.

cd /opt/pibuilder

# Setup WiFi Settings from environment variables defined
if [ -n "$PI_WIFI_SSID" ]; then
	echo "PI_WIFI_SSID=$PI_WIFI_SSID" >> /opt/pibuilder/settings.sh
fi
if [ -n "$PI_WIFI_PASS" ]; then
	echo "PI_WIFI_PASS=$PI_WIFI_PASS" >> /opt/pibuilder/settings.sh
fi

# Generate an public/private key pair required for the image and user
mkdir /ssh-keys 
ssh-keygen -f /ssh-keys/zero -P "" -C "Key for Raspberry Pi"
cp /ssh-keys/zero* /target

# Draw in all files from local folder and find a way to include them into the target image
# TODO - how best to do this?

sh ./scripts/pibuilder.sh
cp /opt/pibuilder/cache/os.img /target/auto-raspbian-jessie.img