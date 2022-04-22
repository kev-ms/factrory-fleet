# Fluent Bit (with Loki) Setup

## Create Fluent Bit Secret

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

Save as Key Vault secret

```bash

az keyvault secret set --vault-name kv-tld --name fluent-bit-secret --value ${GC_PAT}

```

## Update Fluent Bit Config

Before running fluent bit on your corp monitoring cluster, you need to update the values in /apps/fluent-bit/autogitops/config.json to match your fleet and Grafana Cloud instance.

The following values need to be set:

* jobSuffix
* lokiUrl
* lokiUser

### jobSuffix

This value is the name of your fleet and will be used to uniquely identify the logs from this instance in Loki queries. For example, if your fleet name is atx-fleet, jobSuffix should be "atx".

### lokiUser and lokiURL

These values are located in the Grafana Cloud Portal.

* Go to the `Grafana Cloud Portal`: <https://grafana.com/orgs/yourUserName>
* Click `Details` in the `Loki` section
* Under Grafana Data Source Settings:
  * Set lokiUrl to the `URL` value
  * Set lokiUser to the `User` value should be used for lokiUser
