#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

flt create --ssl cseretail.com --branch jofultz-fleet -g jofultz-fleet \
    -c central-tx-atx-510 \
    -c east-ga-atl-510 \
    -c west-wa-sea-510 \
    -c corp-monitoring-jofultz
