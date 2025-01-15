#!/bin/sh

set -e

check_command() {
    if ! "$@"; then
        echo "Health check failed for: $*" >&2
        exit 1
    fi
}

# Health check commands
check_command rpcinfo -p localhost 1>/dev/null
check_command mountpoint -q /projects
check_command mountpoint -q /external_projects

# If all checks pass
echo "Health check passed"
exit 0