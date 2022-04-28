#!/bin/bash

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

az group create -l centralus -g micro-fleet -o table

flt create --gitops --ssl cseretail.com -g micro-fleet -c central-tx-atx-m01 &
flt create --gitops --ssl cseretail.com -g micro-fleet -c east-ga-atl-m01 &
flt create --gitops --ssl cseretail.com -g micro-fleet -c west-wa-sea-m01 &
