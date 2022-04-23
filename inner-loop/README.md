# Edge Vision Setup

## Setup Edge Vision in Codespaces

- Start in the inner-loop directory

  ```bash

  cd "$REPO_BASE/inner-loop"

  ```

- Add Azure Extension

  ```bash

  az extension add -n azure-iot

  ```

- Set env vars
  - Run this once for each new Codespace you create

  ```bash

  # add these commands to ~/.zshrc
  export AKDC_RESOURCE_GROUP=factory-fleet
  export AKDC_STORAGE_CONNECTION=$(az storage account show-connection-string -n $AKDC_STORAGE_NAME -g $AKDC_RESOURCE_GROUP -o tsv)
  export AKDC_STORAGE_NAME=factoryfleetstorage
  export AKDC_CLUSTER=central-tx-dfw-f01
  export AKDC_SUBSCRIPTION=$(az account show --query id -o tsv)
  export AKDC_VOLUME=uploadvolume
  export AKDC_STORAGE_KEY=$(az storage account keys list --resource-group $AKDC_RESOURCE_GROUP --account-name $AKDC_STORAGE_NAME --query "[0].value" -o tsv)

  {
    echo ""
    echo "export AKDC_RESOURCE_GROUP=$AKDC_RESOURCE_GROUP"
    echo "export AKDC_STORAGE_NAME=$AKDC_STORAGE_NAME"
    echo "export AKDC_CLUSTER=$AKDC_CLUSTER"
    echo "export AKDC_SUBSCRIPTION=$AKDC_SUBSCRIPTION"
    echo "export AKDC_VOLUME=$AKDC_VOLUME"
    echo "export AKDC_STORAGE_KEY=$AKDC_STORAGE_KEY"
    echo "export AKDC_STORAGE_CONNECTION=$AKDC_STORAGE_CONNECTION"
  } >> $HOME/.zshrc


  # save the iot hub info
  echo "IOTHUB_CONNECTION_STRING=$(az iot hub connection-string show --hub-name $AKDC_RESOURCE_GROUP -o tsv)" > ~/.ssh/iot.env
  echo "IOTEDGE_DEVICE_CONNECTION_STRING=$(az iot hub device-identity connection-string show --hub-name $AKDC_RESOURCE_GROUP --device-id $AKDC_CLUSTER -o tsv)" >> ~/.ssh/iot.env

  ```

- Check the values

  ```bash

  env | grep AKDC | sort

  cat ~/.ssh/iot.env

  ```

- Mount the Azure Files share

  ```bash

  sudo mkdir -p /upload
  sudo mount -v -t cifs //$AKDC_STORAGE_NAME.file.core.windows.net/$AKDC_VOLUME /upload \
  -o username=$AKDC_STORAGE_NAME,password=$AKDC_STORAGE_KEY,dir_mode=0777,file_mode=0777,cache=strict,actimeo=30

  # check the mount
  cat /upload/status

  ```

  - Create a new k3d cluster

    ```bash

    kic cluster create

    ```

- Create Kubernetes Secrets

  ```bash

  kubectl create secret generic azure-secret \
  --from-literal=azurestorageaccountname=$AKDC_STORAGE_NAME \
  --from-literal=azurestorageaccountkey=$AKDC_STORAGE_KEY

  kubectl create secret generic azure-env --from-env-file ~/.ssh/iot.env

  ```

- Deploy the App

  ```bash

  kubectl apply -f .

  ```

- Check the pods

  ```bash

  # it takes ~2 minutes for all pods to start
  kubectl get pods

  ```

- Check the webmodule
  - Click on `Ports`
  - Open port 30080 (IMDb App)
- The webmodule renders HTML, but it doesn't display anything
