# Observability

To monitor our fleet, we deploy a central monitoring cluster with fluent bit and prometheus configured to send logs and metrics to Grafana Cloud. The monitoring cluster runs WebValidate (WebV) to send requests to apps running on the other clusters in the fleet. The current design has one deployment of WebV for each app. For instance, the webv-heartbeat deployment sends requests to all of the heartbeat apps running on the fleet clusters.  Fluent bit is configured to forward WebV logs to Grafana Loki and prometheus is configured to scrape WebV metrics.  These logs and metrics are used to power a Grafana Cloud dashboard and provide insight into cluster and app availability and latency.

## Deploy a central monitoring cluster to your fleet

```bash

Name your fleet
export FLT_NAME=atx

# must be named corp-monitoring-[your fleet name]
flt create --gitops --ssl cseretail.com -g $FLT_NAME-fleet -c corp-monitoring-$FLT_NAME

```

## WebV

### Add WebV to apps/ directory

Add a WebV directory to the apps/ directory in your fleet branch.

### Update autogitops.json (if needed)

Update the contents of the apps/webv/autogitops/autogitops.json file (if needed).

### Add yaml file

Add a WebV yaml file to the appropriate environment folders to monitor the heartbeat application.

Use the template found [here] as a starting point.

### Update yaml file with appropriate server names

Update the yaml file with your fleet.

```yaml

          args:
          - --sleep
          - "5000"
          - --prometheus
          - --run-loop
          - --server
          - https://fleet-cluster-1.yourdomain.com
          - https://fleet-cluster-2.yourdomain.com
          - https://fleet-cluster-3.yourdomain.com
          - --files
          - heartbeat-benchmark.json
          - --zone
          - {{gitops.config.zone}}
          - --region
          - {{gitops.config.region}}
          - --log-format
          - Json

```

### Update targets and deploy WebV to corp-monitoring cluster

```bash

# make sure you are in the webv directory
cd apps/webv

# should be empty
flt targets list

# clear if needed
flt targets clear

# add corp monitoring cluster
flt targets add corp-monitoring-$FLT_NAME

flt targets deploy

```

## Fluent Bit

### Add fluent bit to apps/ directory

Add a fluent-bit directory to the apps/ directory in your fleet branch.

### Update autogitops.json

Need to update jobSuffix = $FLT_NAME.

### Add fluent-bit.yaml file

Use the template found [here] as a starting point.

If you want logs from an app other than heartbeat, imdb, or ai order accuracy, you will need to update the config map with a new output block and input block.

```yaml

  output.conf: |
    [OUTPUT]
        Name              grafana-loki
        Url               ${LOKI_URL}
        Match             kube.var.log.containers.webv*.*
        Labels            {job="webv-{{gitops.jobSuffix}}"}
        LabelKeys         StatusCode,Server
        RemoveKeys        StatusCode,Server

...

  input-kubernetes.conf: |
    [INPUT]
        Name              tail
        Tag               kube.*
        Path              /var/log/containers/webv*.log
        Parser            cri
        DB                /var/log/flb_kube.db
        Mem_Buf_Limit     5MB
        Skip_Long_Lines   Off
        Refresh_Interval  10

```

### Update targets and deploy fluent bit to corp-montioring cluster

```bash

# make sure you are in the webv directory
cd apps/webv

# should be empty
flt targets list

# clear if needed
flt targets clear

# add corp monitoring cluster
flt targets add corp-monitoring-$FLT_NAME

flt targets deploy

```

## Prometheus

### Add prometheus to apps/ directory

Add a prometheus directory to the apps/ directory in your fleet branch.

### Update autogitops.json if needed

Update the contents of the apps/prometheus/autogitops/autogitops.json file (if needed).

### Add prometheus.yaml file

Use the template found [here] as a starting point.

If you want metrics from an app other than heartbeat, imdb, or ai order accuracy, you will need to update the prometheus config map scrape config list.

```yaml

    scrape_configs:
      - job_name: 'webv-heartbeat'
        static_configs:
          - targets: [ 'webv-heartbeat.webv.svc.cluster.local:8080' ]
        metric_relabel_configs:
        - source_labels: [ __name__ ]
          regex: "WebVDuration_bucket|WebVDuration_sum|WebVSummary_sum"
          action: drop
      - job_name: 'webv-aioa'
        static_configs:
          - targets: [ 'webv-aioa.webv.svc.cluster.local:8080' ]
        metric_relabel_configs:
        - source_labels: [ __name__ ]
          regex: "WebVDuration_bucket|WebVDuration_sum|WebVSummary_sum"
          action: drop
      - job_name: 'webv-imdb'
        static_configs:
          - targets: [ 'webv-imdb.webv.svc.cluster.local:8080' ]
        metric_relabel_configs:
        - source_labels: [ __name__ ]
          regex: "WebVDuration_bucket|WebVDuration_sum|WebVSummary_sum"
          action: drop

```

### Update targets and deploy prometheus to corp-montioring cluster

```bash

# make sure you are in the webv directory
cd apps/webv

# should be empty
flt targets list

# clear if needed
flt targets clear

# add corp monitoring cluster
flt targets add corp-monitoring-$FLT_NAME

flt targets deploy

```

## Create Grafana Cloud Dashboard

```bash

# generate json based on dashboard-template
cp dashboard-template.json dashboard.json
sed -i "s/%%FLEET_NAME%%/${FLT_NAME}/g" dashboard.json

```

Copy the content in dashboard.json and import as a new dashboard in Grafana Cloud.

## Create Alert for New Fleet

* Go to Grafana Cloud > Alerting > Alert Rules.
* Create a new alert (+ New Alert Rule).
  * Name the rule $FLT_NAME App Issue
  * Rule type: Grafana managed alert
  * Folder: Platform
* Select grafanacloud.retailedge.prom as the source

TODO: Insert screen shot for Alert Config
