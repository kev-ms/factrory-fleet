#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

az group create -g jofultz-fleet

flt create --ssl cseretail.com --branch jofultz-fleet -g jofultz-fleet -c central-tx-atx-512 &
flt create --ssl cseretail.com --branch jofultz-fleet -g jofultz-fleet -c east-ga-atl-512 &
flt create --ssl cseretail.com --branch jofultz-fleet -g jofultz-fleet -c west-wa-sea-512 &
flt create --ssl cseretail.com --branch jofultz-fleet -g jofultz-fleet -c corp-monitoring-jofultz &
