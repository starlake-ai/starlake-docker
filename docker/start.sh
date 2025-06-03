#!/bin/bash

set -e
set -u
set -o pipefail

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function usage() {
    echo "Usage: $0 (-o [orchestrator])"
    echo ""
    echo "-o [orchestrator] : run docker-compose with the specified orchestrator (airflow, dagster or snowflake), *airflow* by default"
}

function printError() {
    echo -e "${RED}$1${NC}" 1>&2
}

function printInfo() {
    echo -e "${GREEN}$1${NC}" 1>&2
}

function clean() {
    IFS=$SAVEIFS
    exit $1
}

ARCH=$(docker info --format '{{.Architecture}}')
echo "Detected architecture: $ARCH"

# Default orchestrator
ORCHESTRATOR="airflow"

# Parse command line options
while getopts "o:" opt; do
    case ${opt} in
    o) 
        ORCHESTRATOR=${OPTARG} 
        ;;
    \?)
        printError "Invalid option: ${OPTARG}"
        echo ""
        usage
        clean 1
        ;;
    :)
        printError "Invalid option: ${OPTARG} requires an argument"
        echo ""
        usage
        clean 1
        ;;
    esac
done

# Check if the orchestrator is valid
if [[ "$ORCHESTRATOR" != "airflow" && "$ORCHESTRATOR" != "dagster" && "$ORCHESTRATOR" != "snowflake" ]]; then
    printError "Invalid orchestrator: $ORCHESTRATOR"
    echo ""
    usage
    clean 1
fi
printInfo "Starting docker-compose with orchestrator: $ORCHESTRATOR"

if [[ "$ORCHESTRATOR" == "dagster" ]]; then
    DOCKER_COMPOSE_FILE="docker-compose-dagster.yml"
elif [[ "$ORCHESTRATOR" == "snowflake" ]]; then
    DOCKER_COMPOSE_FILE="docker-compose-snowflake.yml"
else
    DOCKER_COMPOSE_FILE="docker-compose.yml"
fi

# Delete the old .env file
rm -f .env.dynamic

# Add basic variables
cat <<EOF >> .env.dynamic
EOF

# Add _JAVA_OPTIONS only for aarch64 or arm64
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
  echo "_JAVA_OPTIONS=-XX:UseSVE=0" >> .env.dynamic
fi

# Run docker-compose specifying the environment file
docker-compose --env-file .env.dynamic -f ${DOCKER_COMPOSE_FILE} up