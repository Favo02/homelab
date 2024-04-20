#!/bin/bash

echo "


-----------------------------------------------------------------
RESTIC BACKUP ($(date))
-----------------------------------------------------------------
"

/home/server/scripts/notify.sh "Cron script" "Executing restic backup ($(date))"

DIRECTORY="/home/server/services"
export RESTIC_REPOSITORY="/home/server/backups"
export RESTIC_PASSWORD_FILE="/home/server/scripts/.restic-key"

# initialize repository
if ! restic cat config >/dev/null 2>&1; then
    echo 'repository not initialized, initializing...'
    restic init -v || /home/server/scripts/notify.sh "Error during backup" "Initializing repository failed"
fi

# backup folder
restic backup $DIRECTORY -v || /home/server/scripts/notify.sh "Error during backup" "Backing up failed"

# prune old snapshots
restic forget --keep-last 30 --prune -v || /home/server/scripts/notify.sh "Error during backup" "Pruning old snapshots failed"

# check integrity
restic check || /home/server/scripts/notify.sh "Error during backup" "Checking integrity failed"
