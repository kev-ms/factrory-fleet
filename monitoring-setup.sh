#!/bin/bash

set -e

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit


if [ -d ./bootstrap-monitoring ]
then
    kubectl apply -f ./bootstrap-monitoring
    kubectl apply -R -f ./bootstrap-monitoring
fi
