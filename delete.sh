#!/bin/bash

# duplicate this line for each cluster
flt delete kshahtest-central

rm ips

az group delete -y --no-wait -g kshahtest-fleet

echo "To delete your branch upstream, use"
echo -e "\n\t git push origin --delete <your-fleet> \n"
