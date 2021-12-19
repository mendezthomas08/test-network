#!/bin/bash


ORG_NAME=myOrg
DOMAIN_NAME=example
CHANNEL_NAME=mychannel
BPID=bp01
BP_NAME=bpName01
BP_DESCRIPTION=bpDescription
SECRET=$1



token=$(curl --header "Content-Type: application/json" \
  --request POST \
  --data '{
        "username":"smartflow.system@anz.com",
        "orgName": "'$ORG_NAME'",
        "role": "client",
        "attrs": [],
        "secret": "'$SECRET'"
}
' \
 -k  http://localhost:4000/users/register | jq -r  '.token')

echo "token: $token"

echo -e "\nInvoking Chaincode parentcc......"

curl --header "Content-Type: application/json" -H "Authorization: Bearer $token"  \
  --request POST \
  --data '{
        "peers": [
                "peer0.'$ORG_NAME'.'$DOMAIN_NAME'.com"
        ],
        "fcn": "invokeAnotherChaincode",
        "args": ["childcc","mychannel","{\"fcn\": \"createBP\",\"params\": [\"'$BPID'\",\"'$BP_NAME'\",\"'$BP_DESCRIPTION'\"]}"]
}
' \
 -k  http://localhost:4000/channels/mychannel/chaincodes/parentcc



echo -e "\n Querying Chaincode............."

sleep 3 

docker exec cli${ORG_NAME} peer chaincode query -C mychannel -n childcc -c '{"Args":["queryBP","'$BPID'"]}'
