#!/bin/bash
#licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
ORG_NAME="$1"
DOMAIN_NAME="$2"
CHANNEL_NAME="$3"
BASE_ORG="$4"

function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31m\e[4mUsage:\e[0m"
  echo -e "\e[32m\e[1mfabricNetworkConfigEdit.sh [<org name>] [<domain name>] [<Channel Name>]  [<BaseOrg Name>]  [<BaseServer IP>]\e[0m"
  echo -e "\e[35m[<org name>]\e[0m= name of the newly creating org\e[0m"
  echo -e "\e[35m[<domain name>]\e[0m= domain name of the newly creating org\e[0m"
  echo -e "\e[35m[< Channel Name>]\e[0m= channel name\e[0m"
  echo -e "\e[35m[< BaseOrg Name>]\e[0m= Org name from which server you are calling from\e[0m"
  echo -e "\e[35m[< BaseServer IP>]\e[0m= server IP of the base org\e[0m"
  echo -e "\e[34m#############################################################################################\e[0m"
}

if [ "$#" = 0 ]; then
 printHelp
 exit 1
fi

 echo  "CREATING YAML============"

cat << EOF > ${BASE_ORG}-config/fabricSDK/artifacts/channelpeer-config.yaml
    peers:
      peer0.${ORG_NAME}.${DOMAIN_NAME}.com:
        endorsingPeer: true
        chaincodeQuery: true
        ledgerQuery: true
        eventSource: true
      peer1.${ORG_NAME}.${DOMAIN_NAME}.com:
        endorsingPeer: false
        chaincodeQuery: true
        ledgerQuery: true
        eventSource: false
EOF

cd ${BASE_ORG}-config/fabricSDK/artifacts
#npm install js-yaml

node yamlEditorSameServer2.js ${CHANNEL_NAME}
rm channelpeer-config.yaml

