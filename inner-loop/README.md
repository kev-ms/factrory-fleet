# Edge Vision Setup

- You must create the Codespace from the akdc repo
- Create a Codespace with 16 cores to ensure enough capacity

## Setup Edge Vision in Codespaces

- Checkout branches

  ```bash

  git checkout factory-fleet
  git pull

  # checkout edge-gitops branch
  cd ../edge-gitops
  git factory-fleet
  git pull

  ```

- Start in the inner-loop directory

  ```bash

  cd /workspaces/edge-gitops/inner-loop

  ```

- Run the setup script

> setup.sh will eventually be integrated into the Codespace

  ```bash

  ../.devcontainer/setup.sh

  ```

- Start a new shell

> You can also exit and press ctl ` to create a new shell

  ```bash

  zsh

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
