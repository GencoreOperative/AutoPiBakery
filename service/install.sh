#!/bin/bash

exec 2> /var/log/rc.local.log # send stderr from rc.local to a log file
exec 1>&2

set -x
set -e

SERVICE=user.service
TARGET=/etc/systemd/system/${SERVICE}

echo "Installing User Application Service"
cp /opt/${SERVICE} ${TARGET}
echo "Service installed"
ls -las ${TARGET}

echo "Starting User Application Service"
systemctl start ${SERVICE}
echo "Enabling User Application Service"
systemctl enable ${SERVICE}