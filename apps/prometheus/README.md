# Prometheus Setup

## Grafana Cloud Configuration

The prometheus deployment expects to retrieve the value for the Grafana Cloud API Key from a kubernetes secret. To acheive this, we store the value as a secret in Key Vault. Each member of the fleet retrieves the value from Key Vault during setup and creates the needed secret on the cluster.

### Prometheus secret (password)

* Go to <https://grafana.com> and log in
* Click on `My Account`
  * You will get redirected to this URL <https://grafana.com/orgs/yourUserName>
* Click on `Details` in the `Prometheus` section
* Click on `Generate now` under the `Password / API Key` section to generate a new password
  * Name your API Key (i.e. yourName-publisher)
  * Select `MetricsPublisher` as the role
  * Click on `Create API Key`
  * Click on `Copy to Clipboard` and save the value wherever you save your PATs
    * WARNING - you will not be able to get back to this value!!!
* In the Section `Prometheus remote_write Configuration`
  * Copy the value of the password in the config

```bash

GC_PROM_PASSWORD="<Paste value here>"

```

Save as Key Vault secret

```bash

az keyvault secret set --vault-name kv-tld --name prometheus-secret --value $GC_PROM_PASSWORD

```

### Update Prometheus Config

Before deploying prometheus to your corp monitoring cluster, you need to update the values in /apps/prometheus/autogitops/config.json to match your Grafana Cloud instance.

The following values need to be set:

* prometheusURL
* prometheusUser

#### prometheusURL and prometheusUser

These values are located in the Grafana Cloud Portal.

* Go to the `Grafana Cloud Portal`: <https://grafana.com/orgs/yourUserName>
* Click `Details` in the `Prometheus` section
* Under Grafana Data Source Settings:
  * Set prometheusURL to the `Remote Write Endpoint` value
  * Set prometheusUser to the `Username / Instance ID` value

## Prometheus Configuration

The "origin_prometheus" value in the prometheus configuration is important as it serves as a way to uniquely identify the source of the metrics when querying in Grafana Cloud. By default, this will be set to the name of the store that prometheus is deployed to.

```yaml

    global:
      scrape_interval: 5s
      evaluation_interval: 5s
      external_labels:
        origin_prometheus: {{gitops.config.store}}

```

The scrape configs specify what targets to scrape metrics from and which metrics to keep or drop. There is a scrape job named "webv-heartbeat" that scrapes metrics from the webv-heartbeat app running on the cluster. The metrics WebVDuration_bucket, WebVDuration_sum, and WebVSummary_sum are configured to be dropped since they are not being used by our dashboard queries.

```yaml

    scrape_configs:
      - job_name: 'webv-heartbeat'
        static_configs:
          - targets: [ 'webv-heartbeat.webv.svc.cluster.local:8080' ]
        metric_relabel_configs:
        - source_labels: [ __name__ ]
          regex: "WebVDuration_bucket|WebVDuration_sum|WebVSummary_sum"
          action: drop

```

For more information on Prometheus configuration, see their [documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/).
