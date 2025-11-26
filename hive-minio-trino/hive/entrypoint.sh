#!/bin/bash
set -e

JAVA_PATH=$(dirname $(dirname $(readlink -f /usr/bin/java)))
echo "Found Java path: $JAVA_PATH"
export JAVA_HOME=$JAVA_PATH
export PATH=$PATH:$JAVA_PATH/bin

# Replace environment variables in the configuration file
envsubst < $HIVE_HOME/conf/hive-site.xml > /tmp/hive-site.xml
mv /tmp/hive-site.xml $HIVE_HOME/conf/hive-site.xml
echo "Waiting for PostgreSQL at ${POSTGRES_HOST}:${POSTGRES_PORT:-5432}..."
# Wait for PostgreSQL to be ready
while ! nc -z ${POSTGRES_HOST} ${POSTGRES_PORT:-5432}; do
  sleep 1
done
echo "PostgreSQL is ready!"
# Check if the schema has been initialized
SCHEMA_CHECK_FILE="/Users/hayssams/git/public/hive3-metastore/hive/warehouse/.schema_initialized"
if [ ! -f "$SCHEMA_CHECK_FILE" ]; then
    echo "Initializing Hive Metastore schema..."
    $HIVE_HOME/bin/schematool -dbType postgres -initSchema
    if [ $? -ne 0 ]; then
        echo "Schema initialization failed!"
        exit 1
    fi
    echo "Schema initialization successful."
    touch "$SCHEMA_CHECK_FILE"
else
    echo "Schema already initialized. Skipping schematool -initSchema."
fi
echo "Starting Hive Metastore service..."
# Start the Metastore service
export HIVE_OPTS="-Dhive.log.level=DEBUG"
exec $HIVE_HOME/bin/hive --service metastore
