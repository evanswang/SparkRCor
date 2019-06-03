#!/bin/bash

PWD=`pwd`

TOKEN=`cat ${PWD}/token`
 
# create a vm
# input parameter
#   floating ip
#   fixed ip
#   server ip
curl -X POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" -d  '
{
    "addFloatingIp" : {
        "address": "'"$1"'",
        "fixed_address": "'"$2"'"
    }
}' "https://eta.internal.sanger.ac.uk:13774/v2.1/servers/$3/action"

# floating ip: 172.27.19.6
# fixed ip: 192.168.0.15