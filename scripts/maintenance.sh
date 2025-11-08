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
    notify "Maintenance error" "$*"
    exit 1
}
usage() {
    cat <<EOF
Usage
    $0 [-n <NOTIFICATIONS_EXE>]

Options:
    -n, --notify       Executable for notifications (optional), will be called with two arguments: <NOTIFICATIONS_EXE> <title> <details>
    -h, --help         Show this help message

Examples:
    $0 -n notify.sh
    $0
EOF
    exit 2
}

# fail if any pipe exits with non-zero
set -euo pipefail

# must be run as root
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    error "This script should be run as root (with sudo)"
fi

# Initialize variables
NOTIFICATIONS_EXE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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

print "


-----------------------------------------------------------------
SYSTEM MAINTENANCE ($(date))
-----------------------------------------------------------------
"

notify "System Maintenance" "Cleaning up, updating, rebooting ($(date))"

print "Clearing Docker leftovers"
if ! docker system prune -a -f --volumes; then
    error "Docker system prune failed"
fi
print "Docker cleanup complete"

print "Updating package lists"
if ! apt-get update; then
    error "apt-get update failed"
fi
print "Package lists updated"

print "Upgrading packages"
if ! apt-get upgrade -y; then
    error "apt-get upgrade failed"
fi
print "Packages upgraded"

print "All maintenance tasks completed successfully, rebooting system"
/sbin/reboot
