#!/bin/bash

flt delete central-ar-lr-101
flt delete east-tn-nashville-101
flt delete west-wa-spokane-101

rm ips

az group delete -y --no-wait -g pg-fleet