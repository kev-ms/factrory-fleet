#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

flt create --ssl cseretail.com --branch jofultz-fleet -g jofultz-fleet -c central-tx-atx-501
