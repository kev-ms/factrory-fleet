#!/bin/bash

echo "uncomment delete.sh commands to run it"
exit 0

flt dns delete central-tx-atx-512 &
flt dns delete east-ga-atl-512 &
flt dns delete west-wa-sea-512 &
flt dns delete corp-monitoring-jofultz &
flt delete jofultz-fleet &

rm ips
git restore -s origin main config deploy

git pull
git commit -am "flt delete"
git push
