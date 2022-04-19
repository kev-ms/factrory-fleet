#!/bin/bash

flt delete central-tx-atx-501

rm ips

az group delete -y --no-wait -g jofultz-fleet

git pull
git restore -s origin/main config deploy
git commit -am "restore config and deploy"
git push
