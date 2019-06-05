#!/bin/bash
# input parameter: hostname
# note: hostname cannot be duplicated

PWD=`pwd`

TOKEN=`cat ${PWD}/token`
 
# create a vm
curl -X POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" -d  '
{       
 "server": {
   "name": "'"$1"'",
   "imageRef": "104e5573-bbc7-4583-8f71-1f39e5775534",
   "flavorRef": "8103",
   "networks": [{
            "uuid" : "d0607c1a-02ff-45a9-8b11-b289ed224100"
        }],
   "security_groups": [{
            "name" : "cloudforms_ext_in"
        }],
   "key_name": "spark_key"
 }          
}' https://eta.internal.sanger.ac.uk:13774/v2.1/servers | python -m json.tool | grep "\"id\":" | awk -F "\"" '{print $4}'

# get server id: 89559644-c018-4686-8552-ad198babb0ca
