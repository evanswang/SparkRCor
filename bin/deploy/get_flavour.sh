#!/bin/bash

###################################################################################
# Name : get_flavour
# Author: sw23
# Date: 13 Mar 2019
# Function :  Get all flavours. Not a part of pipeline. Check flavour independently.
# Input: token
###################################################################################

source ${SPARKRCOR_HOME}/config

PWD=${SPARKRCOR_HOME}/bin/deploy

TOKEN=`cat ${PWD}/token`

curl -s -X GET -H "X-Auth-Token: ${TOKEN}"  https://eta.internal.sanger.ac.uk:13774/v2.1/flavors | python3 -m json.tool

echo