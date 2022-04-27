#!/bin/bash

######################################
### Do not run this script in main ###
######################################

# from main branch
# git checkout -b your-fleet
# git push -u origin your-fleet
# update and run this script
# make sure to check in the ips file generated

# change to this directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

# duplicate this line for each cluster
# change yourClusterName on each line
# do not change your-fleet on each line
flt create --gitops --ssl cseretail.com -g af-prom -c central-tx-aff-101
flt create --gitops --ssl cseretail.com -g af-prom -c east-ny-aff-102
flt create --gitops --ssl cseretail.com -g af-prom -c west-wa-aff-103
