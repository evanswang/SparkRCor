#!/bin/bash

PWD=`pwd`

TOKEN=`cat ${PWD}/token`

curl -s -X GET -H "X-Auth-Token: ${TOKEN}"  https://zeta.internal.sanger.ac.uk:13774/v2.1/servers | python -m json.tool 