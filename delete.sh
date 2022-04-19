#!/bin/bash

flt delete central-tx-atx-501 &

rm ips

az group delete -y --no-wait -g jofultz-fleet

git pull
git commit -am "flt delete"
git push
