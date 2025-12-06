DOCKER_ID=`docker ps | grep trino | cut -d' ' -f 1`
docker exec -it $DOCKER_ID bash