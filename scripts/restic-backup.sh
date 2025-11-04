#!/bin/bash

# Output helpers
print() { echo -e "\033[32m---> $*\033[0m"; }
notify() {
    # call notifier only if provided and executable
    if [ -n "${ERROR_NOTIFICATIONS:-}" ] && [ -x "${ERROR_NOTIFICATIONS}" ]; then
        "${ERROR_NOTIFICATIONS}" "$1" "$*"
    fi
}
error() {
    echo -e "\033[31m---> $*\033[0m"
    notify "Backup error" "$*"
    exit 1
}
input() { echo -ne "\033[33m---> $*\033[0m"; }
usage() {
    cat <<EOF
Usage
    $0 <SOURCE_FOLDER> <RESTIC_REPOSITORY> <RESTIC_PASSWORD_FILE> <RCLONE_CONFIG> <ERROR_NOTIFICATIONS>

    Source folder: folder to be backed up
    Restic repository: restic repository that contains the snapshots of the data (can be both local or remote using rclone)
    Restic password file: file that contains repository password
    Rclone config: rclone config file (contains remote repositories config)
    Error notifications: executable to pass arguments to notify errors (called with two arguments)

Example:
    $0 /home/user/Documents "rclone:google-drive:restic-backups" /home/user/scripts/.restic-key /home/user/.config/rclone/rclone.conf /home/user/notify.sh
EOF
    exit 2
}

# fail if any pipe exits with non-zero
set -euo pipefail

# must be run as root
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    error "This script should be run as root (with sudo)"
fi

# ensure required commands are available
for _cmd in restic rclone; do
    if ! command -v "$_cmd" >/dev/null 2>&1; then
        error "Required command '$_cmd' not found in PATH"
    fi
done

# args validation
if [ "$#" -ne 5 ]; then
    usage
fi

SOURCE_FOLDER="$1"
RESTIC_REPOSITORY="$2"
RESTIC_PASSWORD_FILE="$3"
RCLONE_CONFIG="$4"
ERROR_NOTIFICATIONS="$5"

# validate folders
[ -e "$RESTIC_PASSWORD_FILE" ] || error "Password file '$RESTIC_PASSWORD_FILE' not found"
[ -d "$SOURCE_FOLDER" ] || error "Source folder '$SOURCE_FOLDER' does not exist or is not a directory"
[ -e "$RCLONE_CONFIG" ] || error "Rclone config file '$RCLONE_CONFIG' not found"

export RESTIC_REPOSITORY
export RESTIC_PASSWORD_FILE
export RCLONE_CONFIG

ensure_repo() {
    print "Checking restic repository: $RESTIC_REPOSITORY"
    if restic cat config >/dev/null 2>&1; then
        print "Repository OK"
        return 0
    fi

    print "Repository not initialized or unreachable: $RESTIC_REPOSITORY"
    print "Initializing restic repository: $RESTIC_REPOSITORY"
    restic init || error "Failed to initialize repository $RESTIC_REPOSITORY"

    print "Verifying repository usability (snapshot list)"
    if ! restic cat config >/dev/null 2>&1; then
        error "Repository $RESTIC_REPOSITORY still not available after init"
    fi
    print "Repository initialized and verified"
}

print "


-----------------------------------------------------------------
RESTIC BACKUP $SOURCE_FOLDER -> $RESTIC_REPOSITORY ($(date))
-----------------------------------------------------------------
"

notify "Backup notification" "Starting restic backup for $SOURCE_FOLDER -> $RESTIC_REPOSITORY ($(date))"

print "Starting restic backup for $SOURCE_FOLDER -> $RESTIC_REPOSITORY"

# Ensure repo exists or init
ensure_repo "$RESTIC_REPOSITORY"

print "Backing up $SOURCE_FOLDER to $RESTIC_REPOSITORY"
restic backup "$SOURCE_FOLDER" -v || error "Backup failed"

print "Backup complete — pruning and checking"
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune -v || error "Prune failed"
restic check || error "Integrity check failed"

print "All tasks finished successfully"
