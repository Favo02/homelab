#!/bin/bash

echo "


-----------------------------------------------------------------
CLEARING DOCKER LEFTOVERS ($(date))
-----------------------------------------------------------------
"

/home/server/scripts/notify.sh "Cron script" "Executing docker system prune ($(date))"

docker system prune -a -f --volumes

