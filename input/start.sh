#!/bin/bash

echo "Installing User Application Service"
cp /opt/app/myscript.service /etc/systemd/system/myscript.service
echo "Service installed"
ls -las /etc/systemd/system/myscript.service

echo "Starting User Application Service"
systemctl start myscript.service
echo "Enabling User Application Service"
systemctl enable myscript.service