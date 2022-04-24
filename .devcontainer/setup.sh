#!/bin/bash

# setup for factory AI app

# add the iot extension
az extension add -n azure-iot

# login to Azure
flt az-login

# create shared directories / mounts
sudo mkdir -p /k3d/var/lib/kubelet
sudo mkdir -p /k3d/etc/kubernetes
sudo chown -R "$USER":"$USER" /k3d

if [ "$(grep k3d /etc/fstab)" = "" ]
then
      echo "/k3d/var/lib/kubelet /k3d/var/lib/kubelet none bind,shared" | sudo tee -a /etc/fstab
fi

sudo mount -a

# create init.d script
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

case "\$1" in
  start|reload|restart|force-reload)
        sudo mount -a
        ;;
  stop)
        echo "stop not implemented"
        ;;
  status)
        sudo mount | grep k3d
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

if [ "$(grep AKDC_STORAGE_KEY ~/.zshrc)" = "" ]
then
      {
            echo ""
            echo "export AKDC_RESOURCE_GROUP=$AKDC_RESOURCE_GROUP"
            echo "export AKDC_STORAGE_NAME=$AKDC_STORAGE_NAME"
            echo "export AKDC_CLUSTER=$AKDC_CLUSTER"
            echo "export AKDC_SUBSCRIPTION=$(az account show --query id -o tsv)"
            echo "export AKDC_VOLUME=$AKDC_VOLUME"
            echo "export AKDC_STORAGE_KEY=$(az storage account keys list --resource-group "$AKDC_RESOURCE_GROUP" --account-name "$AKDC_STORAGE_NAME" --query "[0].value" -o tsv)"
            echo "export AKDC_STORAGE_CONNECTION=$(az storage account show-connection-string -n "$AKDC_STORAGE_NAME" -g "$AKDC_RESOURCE_GROUP" -o tsv)"
      } >> "$HOME/.zshrc"
fi

# save the iot hub info
echo "IOTHUB_CONNECTION_STRING=$(az iot hub connection-string show --hub-name "$AKDC_RESOURCE_GROUP" -o tsv)" > ~/.ssh/iot.env
echo "IOTEDGE_DEVICE_CONNECTION_STRING=$(az iot hub device-identity connection-string show --hub-name "$AKDC_RESOURCE_GROUP" --device-id "$AKDC_CLUSTER" -o tsv)" >> ~/.ssh/iot.env
