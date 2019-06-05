#!/bin/bash

PWD=${SPARKRCOR_HOME}/bin/deploy

# generate a token pass

TOKEN=`curl -i \
  -H "Content-Type: application/json" \
  -d '
{ "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "youruser",
          "domain": { "id": "default" },
          "password": "yourpass"
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

echo ${TOKEN} > ${PWD}/token
  
# X-Subject-Token is what we need.