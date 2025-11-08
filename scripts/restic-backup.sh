#!/bin/bash

# Output helpers
print() { echo -e "\033[32m---> $*\033[0m"; }
notify() {
    if [ -n "${NOTIFICATIONS_EXE:-}" ] && [ -x "${NOTIFICATIONS_EXE}" ]; then
        "${NOTIFICATIONS_EXE}" "$1" "$*"
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
    $0 -s <SOURCE_FOLDER> -r <RESTIC_REPOSITORY> -p <RESTIC_PASSWORD_FILE> [-c <RCLONE_CONFIG>] [-n <NOTIFICATIONS_EXE>]

Options:
    -s, --source       Source folder to be backed up (required)
    -r, --repo         Restic repository for snapshots (required)
    -p, --password     Restic password file (required)
    -c, --rclone       Rclone config file (optional, required if repository starts with "rclone:")
    -n, --notify       Executable for error notifications (optional), will be called with two arguments: <NOTIFICATIONS_EXE> <title> <details>
    -h, --help         Show this help message

Examples:
    $0 -s /home/user/Documents -r "rclone:google-drive:restic-backups" -p .restic-key -c /home/user/.config/rclone/rclone.conf -n notify.sh
    $0 -s /home/user/Documents -r /local/backup/repo -p .restic-key -n notify.sh
    $0 -s /home/user/Documents -r /local/backup/repo -p .restic-key
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

# Initialize variables
SOURCE_FOLDER=""
RESTIC_REPOSITORY=""
RESTIC_PASSWORD_FILE=""
RCLONE_CONFIG=""
NOTIFICATIONS_EXE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            SOURCE_FOLDER="$2"
            shift 2
            ;;
        -r|--repo)
            RESTIC_REPOSITORY="$2"
            shift 2
            ;;
        -p|--password)
            RESTIC_PASSWORD_FILE="$2"
            shift 2
            ;;
        -c|--rclone)
            RCLONE_CONFIG="$2"
            shift 2
            ;;
        -n|--notify)
            NOTIFICATIONS_EXE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required arguments
[ -z "$SOURCE_FOLDER" ] && error "Source folder is required (-s/--source)"
[ -z "$RESTIC_REPOSITORY" ] && error "Restic repository is required (-r/--repo)"
[ -z "$RESTIC_PASSWORD_FILE" ] && error "Password file is required (-p/--password)"

# Validate paths
[ -e "$RESTIC_PASSWORD_FILE" ] || error "Password file '$RESTIC_PASSWORD_FILE' not found"
[ -d "$SOURCE_FOLDER" ] || error "Source folder '$SOURCE_FOLDER' does not exist or is not a directory"

# Validate rclone config if repository uses rclone
if [[ "$RESTIC_REPOSITORY" == rclone:* ]]; then
    if [ -z "$RCLONE_CONFIG" ]; then
        error "Rclone config file is required when using an rclone repository (-c/--rclone)"
    fi
    [ -e "$RCLONE_CONFIG" ] || error "Rclone config file '$RCLONE_CONFIG' not found"
fi

# Validate notifications executable if provided
if [ -n "${NOTIFICATIONS_EXE:-}" ]; then
    if command -v "${NOTIFICATIONS_EXE}" >/dev/null 2>&1; then
        NOTIFICATIONS_EXE="$(command -v "${NOTIFICATIONS_EXE}")"
    elif [ -x "${NOTIFICATIONS_EXE}" ]; then
        NOTIFICATIONS_EXE="$(readlink -f "${NOTIFICATIONS_EXE}" 2>/dev/null || echo "${NOTIFICATIONS_EXE}")"
    else
        error "Notifications executable '${NOTIFICATIONS_EXE}' not found or not executable"
    fi
fi

export RESTIC_REPOSITORY
export RESTIC_PASSWORD_FILE
[ -n "$RCLONE_CONFIG" ] && export RCLONE_CONFIG

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
