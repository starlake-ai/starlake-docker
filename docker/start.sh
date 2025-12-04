#!/bin/bash

set -e

SILENT=false
DEFAULT_PORT=80

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--silent)
            SILENT=true
            shift
            ;;
        -p|--port)
            SL_PORT="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [-s|--silent] [-p|--port PORT]"
            exit 1
            ;;
    esac
done

# If not silent and port not provided, ask the user
if [ "$SILENT" = false ] && [ -z "$SL_PORT" ]; then
    read -p "Enter port to start on [${DEFAULT_PORT}]: " SL_PORT
    SL_PORT=${SL_PORT:-$DEFAULT_PORT}
fi

# Use default if still not set
SL_PORT=${SL_PORT:-$DEFAULT_PORT}

echo "Starting Starlake on port ${SL_PORT}..."

export SL_PORT

docker compose up --build

