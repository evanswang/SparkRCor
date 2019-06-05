#!/bin/bash

PWD=`pwd`

TOKEN=`cat ${PWD}/token`

VMID=$1

curl -s -X GET -H "X-Auth-Token: ${TOKEN}"  "https://eta.internal.sanger.ac.uk:13774/v2.1/servers/${VMID}" | python -m json.tool | grep "\"addr\":" | awk -F "\"" '{print $4}' 