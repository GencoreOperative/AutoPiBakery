#!/bin/bash

# Runtime will act as the entrypoint for the Docker image. It wraps the
# pibuilder.sh script and performs tasks that should be executed once per 
# run. This includes consuming the WiFi settings and generating SSH keys.

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
ssh-keygen -f /ssh-keys/key -P "" -C "Key for Raspberry Pi"
cp /ssh-keys/* /output
echo "PI_SSH_KEY=/ssh-keys/key.pub" >> $SETTINGS

# Run the pibuilder.sh script which generates the image
sh ./scripts/pibuilder.sh

# Copy the image to the mounted output folder
cp /opt/pibuilder/cache/os.img /output/auto-raspbian-jessie.img