#!/bin/bash
set -e

# Substitute environment variables in hive.properties
# We use sed because envsubst might not be available in the minimal base image
# and we want to be explicit about what we replace.

if [ -f /etc/trino/catalog/hive.properties ]; then
    echo "Configuring hive.properties..."
    sed -i "s|\${HIVE_METASTORE_URI}|${HIVE_METASTORE_URI}|g" /etc/trino/catalog/hive.properties
    sed -i "s|\${MINIO_ACCESS_KEY}|${MINIO_ACCESS_KEY}|g" /etc/trino/catalog/hive.properties
    sed -i "s|\${MINIO_SECRET_KEY}|${MINIO_SECRET_KEY}|g" /etc/trino/catalog/hive.properties
    sed -i "s|\${S3_ENDPOINT}|${S3_ENDPOINT}|g" /etc/trino/catalog/hive.properties
fi

# Execute the original Trino entrypoint or command
exec /usr/lib/trino/bin/run-trino
