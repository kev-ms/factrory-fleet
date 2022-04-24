# Edge Vision Setup

> Create a Codespace with 16 cores to ensure enough capacity

## Setup Edge Vision in Codespaces

- Checkout branches

  ```bash

  git checkout factory-fleet
  git pull

  # checkout CLI branch
  git -C ../cli checkout factory-fleet
  git -C ../cli pull

  ```

- Start in the inner-loop directory

  ```bash

  cd "$REPO_BASE/inner-loop"

  ```

- Add Azure Extension
  - Run this once for each new Codespace you create

  ```bash

  az extension add -n azure-iot

  ```

- Set env vars
  - Run this once for each new Codespace you create

  ```bash

  # add these commands to ~/.zshrc
  export AKDC_RESOURCE_GROUP=factory-fleet
  export AKDC_STORAGE_NAME=factoryfleetstorage
  export AKDC_CLUSTER=central-tx-dfw-f01
  export AKDC_VOLUME=uploadvolume
  export AKDC_STORAGE_CONNECTION=$(az storage account show-connection-string -n $AKDC_STORAGE_NAME -g $AKDC_RESOURCE_GROUP -o tsv)
  export AKDC_SUBSCRIPTION=$(az account show --query id -o tsv)
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

- Create the k3d directories and shared mount

  ```bash

  sudo mkdir -p /k3d/var/lib/kubelet
  sudo mkdir -p /k3d/etc/kubernetes
  sudo chown -R $USER:$USER /k3d

  echo "/k3d/var/lib/kubelet /k3d/var/lib/kubelet none bind,shared" | sudo tee -a /etc/fstab
  sudo mount -a

  # check mount
  mount | grep k3d

  ```

- Update init.d to mount on boot

```bash

cat << EOF > mount
#! /bin/sh

### BEGIN INIT INFO
# Provides:          mount
# Required-Start:    \$local_fs \$remote_fs
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Mount fstab
### END INIT INFO

echo "\$1 \$(date)" >> /home/vscode/mount.log

case "\$1" in
  start|reload|restart|force-reload)
        mount -a
        ;;
  stop)
        echo "stop not implemented"
        ;;
  status)
        echo "status /etc/init.d/mount"
        ;;
  *)
        echo "Usage: \$N {start|stop|restart|force-reload|status}" >&2
        exit 1
        ;;
esac

exit 0

EOF


sudo mv mount /etc/init.d/mount
sudo chmod +x /etc/init.d/mount
sudo update-rc.d mount defaults

## todo - fix init.d
sudo sed -i "s/set -e/mount -a\n\nset -e/" /etc/init.d/ssh

```

- Create the Azure credentials file for the nodes

```bash

cat << EOF > /k3d/etc/kubernetes/azure.json
{
    "cloud":"AzurePublicCloud",
    "tenantId": "$AKDC_TENANT",
    "aadClientId": "$AKDC_SP_ID",
    "aadClientSecret": "$AKDC_SP_KEY",
    "subscriptionId": "$AKDC_SUBSCRIPTION",
    "resourceGroup": "$AKDC_RESOURCE_GROUP",
    "location": "centralus",
    "cloudProviderBackoff": false,
    "useManagedIdentityExtension": false,
    "useInstanceMetadata": true
}

EOF

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

- Install Azure Files CSI Driver

  ```bash

  kubectl apply -f azurefile-csi

  ```

- Check the pods

  ```bash

  # it takes ~2 minutes for all pods to start
  kic pods

  ```

- Create Persistent Volume and Claim

  ```bash

  kubectl create -f pvc-azure-file.yaml

  ```

- Deploy the App

  ```bash

  kubectl apply -f app

  ```

- Check the pods

  ```bash

  # it takes ~2 minutes for all pods to start
  kic pods

  ```

- Check the webmodule
  - Click on `Ports`
  - Open port 30080 (IMDb App)
- The webmodule renders HTML, but it doesn't display anything
