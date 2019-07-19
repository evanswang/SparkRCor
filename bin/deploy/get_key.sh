#!/bin/bash
###################################################################################
# Name : get_key
# Author: sw23
# Date: 13 Mar 2019
# Function : Check if the key pair is already available for Spark deployment. 
# Dependencies: 
#	Please fill your openstack KEY_NAME and KEY_FILE in the config file.
#	Please run get_token.sh before you run this script.
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
KEYS=`curl -s -X GET -H "X-Auth-Token: ${TOKEN}" \
  https://eta.internal.sanger.ac.uk:13774/v2.1/os-keypairs/${KEY_NAME}`

REMOTE_PUB_KEY=`echo $KEYS | python3 -m json.tool | grep public_key | awk -F "\"" '{print $4}'`

# check the key
ISVALID=`echo ${KEYS} | grep fingerprint`
# key not found
if [ "${KEYS}" != "" ]; then
	exit 1
fi
# key not matched
if [ "${PUB_KEY}" != "${REMOTE_PUB_KEY}" ]; then
	echo "The key name is found in OpenStack, but with different public key string"
	exit 1
fi

echo "Found the key in Openstack already"