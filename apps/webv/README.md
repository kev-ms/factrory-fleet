# Web Validate (WebV) Setup

## Update yaml file with appropriate server names

Before deploying webv to your fleet, you need to update the server arguments with names specific to your fleet.

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

## Montioring other apps

To generate logs and metrics to report on apps other than heartbeat or imdb that are deployed to your fleet, you will need to create additional WebV deployments (one per app) and update the test file argument (--files) as appropriate. See [WebV documentation](https://github.com/microsoft/webvalidate) for more configuration options and details.
