#!/bin/bash
###################################################################################
# Name : post_key
# Author: sw23
# Date: 13 Mar 2019
# Function : Post a key pair to OpenStack for Spark deployment. 
# Dependencies: 
#	Please fill your openstack KEY_NAME and KEY_FILE in the config file.
#	Please get_token before you run this script.
###################################################################################

source ${SPARKRCOR_HOME}/config

PWD=${SPARKRCOR_HOME}/bin/deploy

# load token
TOKEN=`cat ${PWD}/token`

# read the public key
PUB_KEY=`cat ${KEY_FILE}`
if [ "${PUB_KEY}" == "" ]; then
	echo "Cannot find the public key file in ${KEY_FILE} !!!"
	echo
	exit 1
fi

# post a key pair to OpenStack for Spark deployment
KEYS=`curl -s -X POST -H "X-Auth-Token: ${TOKEN}" -i \
  -H "Content-Type: application/json" \
  -d "{
    \"keypair\": {
        \"name\": \"${KEY_NAME}\",
        \"public_key\": \"${PUB_KEY}\"
            }
}"\
  https://eta.internal.sanger.ac.uk:13774/v2.1/os-keypairs`

# check if the key
ISVALID=`echo ${KEYS} | grep fingerprint`

# check RET_CODE??

if [ "${ISVALID}" == "" ]; then
	echo "Cannot post the public key!"
	echo ${KEYS}
	exit 1
fi

echo "New key created in OpenStack"