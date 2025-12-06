# Use a suitable base image
FROM ubuntu:latest

# Define arguments for easier version management
ARG HIVE_VERSION=3.1.3
ARG HADOOP_VERSION=3.3.4
ARG PG_DRIVER_VERSION=42.6.0

# Define environment variables
ENV HIVE_HOME=/opt/hive
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$HIVE_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Download URLs for Hive and PostgreSQL JDBC driver
ENV HIVE_URL=https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
ENV PG_DRIVER_URL=https://jdbc.postgresql.org/download/postgresql-$PG_DRIVER_VERSION.jar
ENV HADOOP_URL=https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

# 1. Install necessary dependencies (Java, download tools)
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk wget gnupg python3 procps gettext netcat-traditional && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget $HADOOP_URL -O /tmp/hadoop.tar.gz && \
    tar -xzvf /tmp/hadoop.tar.gz -C /opt && \
    mv /opt/hadoop-$HADOOP_VERSION $HADOOP_HOME && \
    rm /tmp/hadoop.tar.gz

    # 2. Download and Extract Hive
RUN mkdir -p /opt && \
    wget $HIVE_URL -O /tmp/hive.tar.gz && \
    tar -xzvf /tmp/hive.tar.gz -C /opt && \
    mv /opt/apache-hive-$HIVE_VERSION-bin $HIVE_HOME && \
    rm /tmp/hive.tar.gz

# 3. Download and Install PostgreSQL JDBC Driver
RUN wget $PG_DRIVER_URL -O $HIVE_HOME/lib/postgresql-$PG_DRIVER_VERSION.jar

# 4. Create Hive configuration directory and files
RUN mkdir -p $HIVE_HOME/conf

# Copy the configuration file template and entrypoint script
COPY hive-site.xml $HIVE_HOME/conf/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /user/hive/warehouse && chown -R 1000:1000 /user/hive/warehouse

RUN echo "Finding Java installation path..." && \
    # The default JDK path on Ubuntu 22.04 for OpenJDK 11 is /usr/lib/jvm/java-11-openjdk-amd64/
    JAVA_PATH=$(dirname $(dirname $(readlink -f /usr/bin/java))) && \
    echo "Found Java path: $JAVA_PATH" && \
    echo "export JAVA_HOME=$JAVA_PATH" >> /etc/profile && \
    echo "export PATH=$PATH:$JAVA_PATH/bin" >> /etc/profile

# 5. Expose the Metastore service port (default 9083)
EXPOSE 9083

# Set the entrypoint to handle schema initialization and service startup
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

