#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

flt create --branch pg-fleet --gitops -g pg-fleet --ssl cseretail.com -c central-ar-lr-101
flt create --branch pg-fleet --gitops -g pg-fleet --ssl cseretail.com -c east-tn-nashville-101
flt create --branch pg-fleet --gitops -g pg-fleet --ssl cseretail.com -c west-wa-spokane-101
flt create --gitops --ssl cseretail.com -g pg-fleet -c corp-monitoring-pg
