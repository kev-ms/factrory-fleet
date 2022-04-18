# Observability Base

Walkthrough of the components needed before fleet creation to enable the observability stack.

## Prerequisites

* Grafana Cloud Account
* Azure subscription
* Managed Identity (MI) for the fleet

### Key Vault Secrets

* If not created already, create a Key Vault named kv-tld.
* Grant the MI access to the Key Vault

#### Fluent bit secret (Loki URL)

* Go to <https://grafana.com> and log in
* Click on `My Account`
  * You will get redirected to this URL <https://grafana.com/orgs/yourUserName>
* In the left nav bar, click on `API Keys` (under Security)
* Click on `+ Add API Key`
  * Name your API Key (i.e. yourName-publisher)
  * Select `MetricsPublisher` as the role
  * Click on `Create API Key`
  * Click on `Copy to Clipboard` and save the value wherever you save your PATs
    * WARNING - you will not be able to get back to this value!!!

```bash

GC_PAT="<Paste your Grafana Cloud PAT here>"

```

* Export Loki User ID
  * Go to the `Grafana Cloud Portal`: <https://grafana.com/orgs/yourUserName>
  * Click `Details` in the `Loki` section
    * Copy your `User` value from the Grafana Data Source Settings

```bash

GC_LOKI_USER="<Paste value here>"

```

Save as Key Vault secret

```bash

az keyvault secret set --vault-name kv-tld --name fluent-bit-secret --value "https://${GC_LOKI_USER}:${GC_PAT}@logs-prod-us-central1.grafana.net/loki/api/v1/push"

```

#### Prometheus secret (password)

* Go to the `Grafana Cloud Portal`: <https://grafana.com/orgs/yourUserName>
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

### Execution

The Key Vault secret values are retrieved (via MI) during fleet creation and stored as kubernetes secrets on each cluster in the fleet (in [fleet-vm.templ](https://github.com/retaildevcrews/akdc/blob/main/bin/.flt/fleet-vm.templ) and [akdc-pre-flux.sh](https://github.com/retaildevcrews/akdc/blob/main/vm/setup/akdc-pre-flux.sh#L23)). Additionally, the fluent-bit and prometheus namespaces are bootstrapped on each of the clusters (prior to secret creation).
