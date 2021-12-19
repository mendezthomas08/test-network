#!/bin/bash


ORG_NAME=$1
DOMAIN_NAME=$2
CHANNEL_NAME=$3
SECRET=$4



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

echo -e "\nInstalling Chaincode childcc......"
curl --header "Content-Type: application/json" -H "Authorization: Bearer $token"  \
  --request POST \
  --data '{
        "peers": [
                "peer0.'$ORG_NAME'.'$DOMAIN_NAME'.com",
                "peer1.'$ORG_NAME'.'$DOMAIN_NAME'.com"
        ],
        "chaincodeName":"childcc",
        "chaincodePath":"../../chaincode/childcc/node",
        "chaincodeType": "node",
        "chaincodeVersion":"v0"
}
' \
 -k  http://localhost:4000/chaincodes
echo -e "\n\nInstantiating Chaincode childcc ......"


curl --header "Content-Type: application/json" -H "Authorization: Bearer $token" \
  --request POST \
  --data '{
        "peers": ["peer0.'$ORG_NAME'.'$DOMAIN_NAME'.com"],
        "chaincodeName": "childcc",
        "chaincodeVersion": "v0",
        "chaincodeType": "node",
        "args": [""],
                "policy":{
                "identities": [
                        {"role": {
                                        "name": "member",
                                        "mspId": "'$ORG_NAME'MSP"
                                }
                        }

                ],
                "policy": {
                        "1-of":[
                                {
                                        "signed-by": 0
                                }

                        ]
                }
        }
}
' \
 -k  http://localhost:4000/channels/${CHANNEL_NAME}/chaincodes

echo -e "\nInstalling Chaincode parentcc......"
curl --header "Content-Type: application/json" -H "Authorization: Bearer $token"  \
  --request POST \
  --data '{
        "peers": [
                "peer0.'$ORG_NAME'.'$DOMAIN_NAME'.com",
                "peer1.'$ORG_NAME'.'$DOMAIN_NAME'.com"
        ],
        "chaincodeName":"parentcc",
        "chaincodePath":"../../chaincode/parentcc/node",
        "chaincodeType": "node",
        "chaincodeVersion":"v0"
}
' \
 -k  http://localhost:4000/chaincodes
echo -e "\n\nInstantiating Chaincode parentcc ......"


curl --header "Content-Type: application/json" -H "Authorization: Bearer $token" \
  --request POST \
  --data '{
        "peers": ["peer0.'$ORG_NAME'.'$DOMAIN_NAME'.com"],
        "chaincodeName": "parentcc",
        "chaincodeVersion": "v0",
        "chaincodeType": "node",
        "args": [""],
                "policy":{
                "identities": [
                        {"role": {
                                        "name": "member",
                                        "mspId": "'$ORG_NAME'MSP"
                                }
                        }

                ],
                "policy": {
                        "1-of":[
                                {
                                        "signed-by": 0
                                }

                        ]
                }
        }
}
' \
 -k  http://localhost:4000/channels/${CHANNEL_NAME}/chaincodes


