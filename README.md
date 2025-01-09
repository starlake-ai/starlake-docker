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
cd starlake-docker
```

3. Run the following command to start Starlake UI
```bash
docker-compose up
```

To run on a different port, you can specify the port using the `SL_UI_PORT` environment variable. For example, to run on port 8080, run the following command
```bash  
SL_UI_PORT=8080 docker-compose up
```

4. Open your browser and navigate to `http://localhost` or if you chose a different port `http://localhost:$SL_UI_PORT` to access Starlake UI

That's it! You have successfully started Starlake UI on Docker.

## Stopping Starlake UI
To stop Starlake UI, run the following command in the same directory
```bash
docker-compose down
```
