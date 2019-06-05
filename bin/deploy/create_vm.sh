#!/bin/bash
###################################################################################
# Name : create a vm
# Author: sw23
# Date: 13 Mar 2019
# Function : get openstack token using user and passwd. 
# Input : Please fill the HOSTS with all your host names in the config file. The 
#         host names must be unique.
#         Plsese fill the TEMPT_ID with your spark vm image id.
#
###################################################################################

source ${SPARKRCOR_HOME}/config

PWD=${SPARKRCOR_HOME}/bin/deploy

TOKEN=`cat ${PWD}/token`
 
# create a vm
curl -X POST -H "X-Auth-Token: ${TOKEN}" -H "Content-Type: application/json" -d  '
{       
 "server": {
   "name": "'"$1"'",
   "imageRef": "'${TEMPT_ID}'",
   "flavorRef": "'${FLAVOR}'",
   "networks": [{
            "uuid" : "'${NET_ID}'"
        }],
   "security_groups": [{
            "name" : "'${SECURITY_GROUP}'"
        }],
   "key_name": "'${KEY}'"
 }          
}' https://eta.internal.sanger.ac.uk:13774/v2.1/servers | python3 -m json.tool | grep "\"id\":" | awk -F "\"" '{print $4}'

# get server id: 89559644-c018-4686-8552-ad198babb0ca
