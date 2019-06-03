#!/bin/bash

# Input parameter: token

PWD=`pwd`

TOKEN=`cat ${PWD}/token`

curl -s -X GET -H "X-Auth-Token: ${TOKEN}"  https://eta.internal.sanger.ac.uk:13774/v2.1/flavors

echo