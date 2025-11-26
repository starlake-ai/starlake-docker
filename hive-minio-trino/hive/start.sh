mkdir -p warehouse
docker run \
  -v /Users/hayssams/git/public/hive3-metastore/hive/warehouse:/Users/hayssams/git/public/hive3-metastore/hive/warehouse \
  -e POSTGRES_HOST=host.docker.internal \
  -e POSTGRES_USER=hive \
  -e POSTGRES_PASSWORD=hive123 \
  -e POSTGRES_DB=hive_metastore \
  -p 9083:9083 \
  hive-metastore-postgres