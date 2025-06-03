# Starlake

Starlake is a YAML based integrated declarative data stack that make files ingestion and SQL / Python transformations pipelines easy to build, maintain, and monitor.
It also provides a rich and intuitive UI to build and manage your data pipelines.
The core project is open source and can be found at [starlake-ai/starlake](https://github.com/starlake-ai/starlake)

## Running Starlake UI on Docker

Running Starlake on Docker is as easy as running a single command.
This guide will walk you through the steps to run Starlake on Docker.

1. Clone this repository
```bash
git clone https://github.com/starlake-ai/starlake-docker.git
```

2. Change directory to the cloned repository
```bash
cd starlake-docker/docker
```

3. Run the following command to start Starlake UI with Airflow on Docker
```bash
./start.sh
```

to run Starlake UI with Dagster on Docker, run the following command
```bash
./start.sh -o dagster
```

to run Starlake UI with Snowflake orchestrator, run the following command
```bash
./start.sh -o snowflake
```


To run on a different port, set the `SL_PORT` environment variable. For example, to run on port 8080, run the following command
```bash
SL_PORT=8080 docker-compose up
```

4. Open your browser and navigate to `http://localhost` or if you chose a different port `http://localhost:$SL_PORT` to access Starlake UI

That's it! You have successfully started Starlake UI on Docker.

> **Note**
> 
> Whenever you update using git pull, run docker-compose with the __--build__ flag:
> ``` docker compose up --build ```

## Mounting external projects

If you have any starlake container projects and want to mount it:
- run `setup_mac_nfs.sh` if you are on mac in order to expose your folder via NFS.
  Modify the root folder to share if necessary. By default it is set to /user.
  This change is not specific to starlake and may be used in other container.
- comment `- external_projects_data:/external_projects`
- uncomment `- starlake-prj-nfs-mount:/external_projects`
- go to the end of the file and modify the path of the volume to point to the starlake container folder

Starlake container folder should contain the starlake project folder:

```
 my_container_to_mount
   |
    - sl_project_1
        |
         - metadata
         - ...
   |
    - sl_project_2
        |
         - metadata
         - ...
```

If you have many container projects, create as many volume as needed.

### Limit

- Currently, we cannot mount the starlake projects directory directly under the mounted `/external_projects`. Subfolders of the mounted external project can't be accessed correctly.
- This feature has been tested only on mac at the moment


## Stopping Starlake UI
To stop Starlake UI, run the following command in the same directory
```bash
docker compose down
```





