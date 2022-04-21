# Commands

## Run Fluentbit Docker

> !! Rudimentary document. Not complete.

First modify the `atx_fb.conf` file accordingly then follow steps in terminal:

```bash

# Get Loki password from ~/.ssh/fluent-bit.key
export LOKI_PASSWORD=$(cat ~/.ssh/fluent-bit.key | awk -F [:,@] '{print $3}')

# Mount docker log dir, config files and run FB docker (notice the -d detached mode)

docker run -itd --rm --network akdc \
    -v $(pwd)/atx_fb.conf:/fluent-bit/etc/fluent-bit.conf:ro \
    -v $(pwd)/parsers.conf:/fluent-bit/etc/parsers.conf:ro \
    -e LOKI_PASSWORD=$LOKI_PASSWORD \
    -v /var/lib/docker/containers:/var/lib/docker/containers:ro \
    --name fb fluent/fluent-bit:1.8-debug

```

## Run Prometeus

Modify the `prometheus.yml` file accordingly (see [notes](#prometheusyml-file-notes)).

To create prometheus container:

```bash

docker run -p 9090:9090 --rm -itd --name prometheus --network akdc -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml:ro -v $HOME/.ssh/prometheus.key:/secrets/prometheus.key:ro prom/prometheus --config.file=/etc/prometheus/prometheus.yml --sleep 5000
```

### `prometheus.yml` file notes:

- Modify `origin_prometheus` to make sure this Prom instance name is unique
- Notice the `password_file` where we will be mounting the key file
- `webv-heartbeat` job has a URL 'webv-heartbeat:8080'
  - It is based on webv docker container name
  - Also assumes both prom and webv container belongs in the same network (akdc docker network)
  - If Prom can't find WebV url, check their network with `docker inspect`
  - If in different network add them to the same network with `docker network connect <network-name> <container-name>`
    Or restart them with same network
