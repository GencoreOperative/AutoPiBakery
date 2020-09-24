#!/bin/bash

# A script which wraps the pibuilder.sh script with tasks that need to be
# performed before and after the script.

cd /opt/pibuilder

SETTINGS="/opt/pibuilder/settings.sh"

# Setup WiFi Settings from environment variables defined
if [ -n "$PI_WIFI_SSID" ]; then
	echo "PI_WIFI_SSID=$PI_WIFI_SSID" >> $SETTINGS
fi
if [ -n "$PI_WIFI_PASS" ]; then
	echo "PI_WIFI_PASS=$PI_WIFI_PASS" >> $SETTINGS
fi

# Generate an public/private key pair required for the image and user
mkdir /ssh-keys 
ssh-keygen -f /ssh-keys/key -P "" -C "Key for Raspberry Pi"
cp /ssh-keys/* /output
echo "PI_SSH_KEY=/ssh-keys/key.pub" >> $SETTINGS

# If there are local files to include, copy them to the image
if [  -f /input/start.sh ]; then
	# We need to patch the pibuilder script to perform these steps
	#DATA=/media/rpi_root/opt/data
	#cp /input/* $DATA
	#chmod +x $DATA/start.sh
	#echo "$DATA/start.sh" >> /media/rpi_root/etc/rc.local
fi

sh ./scripts/pibuilder.sh
cp /opt/pibuilder/cache/os.img /output/auto-raspbian-jessie.img