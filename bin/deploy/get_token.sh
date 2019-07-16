#!/bin/bash
###################################################################################
# Name : get openstack token using user and passwd
# Author: sw23
# Date: 13 Mar 2019
# Function : get openstack token using user and passwd. Please fill your openstack
#            USER and PASSWD in the config file.
###################################################################################


source ${SPARKRCOR_HOME}/config

PWD=${SPARKRCOR_HOME}/bin/deploy

read -s -p "Enter your OpenStack password : " PASSWD
echo ""

# generate a token pass

TOKEN=`curl -s -i \
  -H "Content-Type: application/json" \
  -d '
{ "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "'${USER}'",
          "domain": { "id": "default" },
          "password": "'${PASSWD}'"
        }
      }
    },
    "scope": {
      "project": {
        "name": "cosmic-spark-dev",
        "domain": { "id": "default" }
      }
    }
  }
}' \
  https://eta.internal.sanger.ac.uk:13000/v3/auth/tokens | grep X-Subject-Token | awk '{print $2}'`
  
CR=$'\r'

TOKEN="${TOKEN%$CR}"

if [ "${TOKEN}" == "" ]; then
	echo "Wrong password!"
	exit 1
fi

echo ${TOKEN} > ${PWD}/token
  
# X-Subject-Token is what we need.

