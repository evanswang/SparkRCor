#!/bin/bash
###################################################################################
# Name : get_fixed_ip
# Author: sw23
# Date: 13 Mar 2019
# Function : get fixed ips of the vms.
#
###################################################################################

source ${SPARKRCOR_HOME}/config

PWD=${SPARKRCOR_HOME}/bin/deploy

TOKEN=`cat ${PWD}/token`

VMID=$1

curl -s -X GET -H "X-Auth-Token: ${TOKEN}"  "https://eta.internal.sanger.ac.uk:13774/v2.1/servers/${VMID}" | python3 -m json.tool | grep "\"addr\":" | awk -F "\"" '{print $4}' 