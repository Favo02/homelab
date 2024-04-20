#!/bin/bash

echo "


-----------------------------------------------------------------
UPDATE AND REBOOT ($(date))
-----------------------------------------------------------------
"

/home/server/scripts/notify.sh "Cron script" "Executing update reboot ($(date))"

apt-get update
apt-get upgrade -y

/sbin/reboot
