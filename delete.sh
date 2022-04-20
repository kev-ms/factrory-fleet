#!/bin/bash

echo "uncomment delete.sh commands to run it"

flt delete central-tx-atx-512 &
flt delete east-ga-atl-512 &
flt delete west-wa-sea-512 &
flt delete corp-monitoring-jofultz &

rm ips

az group delete -y --no-wait -g jofultz-fleet

git pull
git commit -am "flt delete"
git push
