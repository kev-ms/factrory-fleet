#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

set -e

az group create -l centralus -g pg-fleet -o table

flt create --gitops -g pg-fleet --ssl cseretail.com -c central-ar-lr-101 &
flt create --gitops -g pg-fleet --ssl cseretail.com -c east-tn-nashville-101 &
flt create --gitops -g pg-fleet --ssl cseretail.com -c west-wa-spokane-101 &
flt create --gitops --ssl cseretail.com -g pg-fleet -c corp-monitoring-pg &
