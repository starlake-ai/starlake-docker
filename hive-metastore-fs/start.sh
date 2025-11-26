mkdir -p warehouse
docker run \
  -v /Users/hayssams/git/public/starlake-docker/hive-metastore-fs/warehouse:/user/hive/warehouse \
  -e POSTGRES_HOST=host.docker.internal \
  -e POSTGRES_USER=hive_user \
  -e POSTGRES_PASSWORD=hive_password \
  -e POSTGRES_DB=hive_metastore \
  -p 9083:9083 \
  hive-metastore-postgres