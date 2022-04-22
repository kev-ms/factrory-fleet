#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

export AKDC_RG=factory-fleet
export AKDC_LOCATION=centralus
export AKDC_SHARE_NAME=uploadvolume
export AKDC_STORAGE_NAME=factoryfleetstorage

az group create -l $AKDC_LOCATION -g $AKDC_RG

# Create a storage account
az storage account create -n $AKDC_STORAGE_NAME -g $AKDC_RG -l $AKDC_LOCATION --sku Standard_LRS

# Export the connection string as an environment variable, this is used when creating the Azure file share
export AKDC_STORAGE_CONNECTION=$(az storage account show-connection-string -n $AKDC_STORAGE_NAME -g $AKDC_RG -o tsv)

# Create the file share
az storage share create -n $AKDC_SHARE_NAME --connection-string $AKDC_STORAGE_CONNECTION

# Get storage account key
export AKDC_STORAGE_KEY=$(az storage account keys list --resource-group $AKDC_RG --account-name $AKDC_STORAGE_NAME --query "[0].value" -o tsv)

flt create --gitops --ssl cseretail.com --branch factory-fleet -l northcentralus -g factory-fleet --cores 16 --verbose -c central-tx-dfw-f01
