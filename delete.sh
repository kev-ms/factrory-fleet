#!/bin/bash

flt delete central-tx-atx-501 &
flt delete central-tx-atx-502 &
flt delete central-tx-atx-503 &
flt delete central-tx-atx-504 &

rm ips

az group delete -y --no-wait -g jofultz-fleet

git pull
git restore -s origin/main config deploy
git commit -am "restore config and deploy"
git push
