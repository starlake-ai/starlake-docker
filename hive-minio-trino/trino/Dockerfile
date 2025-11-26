# Start with the official Trino image
FROM trinodb/trino:latest

# Define the directory for custom catalog configurations
ENV CATALOG_DIR=/etc/trino/catalog

# Create the catalog directory if it doesn't exist
RUN mkdir -p ${CATALOG_DIR}

# Copy the Delta Lake properties file into the correct location
# This adds the 'delta' catalog to the Trino server
#COPY delta.properties /etc/trino/catalog/delta.properties
COPY hive.properties /etc/trino/catalog/hive.properties
COPY log.properties /etc/trino/log.properties

# The official Trino image uses its entrypoint, so no need for CMD/ENTRYPOINT changes
# The image is now ready to run!