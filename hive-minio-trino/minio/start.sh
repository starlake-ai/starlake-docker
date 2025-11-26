docker run -e MINIO_ROOT_USER=minio \
            -e MINIO_ROOT_PASSWORD=minio123 \
            -v /Users/hayssams/git/public/hive3-metastore/minio/data:/data \
            -p 9000:9000 -p 9001:9001 \
  quay.io/minio/minio server /data --console-address ":9001"