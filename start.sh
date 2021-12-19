#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
ORG_NAME="$1"
DOMAIN_NAME="$2"
NETWORK_NAME="$3"
CHANNEL_NAME="$4"
#set -ev

echo " $ORG_NAME $DOMAIN_NAME $NETWORK_NAME $CHANNEL_NAME"
# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

spin(){
spinner=('\' '|' '/' '-')
while [ 1 ]
do
for i in "${spinner[@]}"
do
echo -ne "\e[31m\r$i \e[32m$i \e[33m$i \e[34m$i \e[35m$i \e[36m$i \e[39m$i \e[31m$i \e[32m$i \e[33m$i \e[34m$i \e[35m$i \e[36m$i \e[39m$i \e[31m$i \e[32m$i \e[33m$i \e[34m$i \e[35m$i \e[36m$i \e[39m$i \e[31m$i \e[32m$i \e[33m$i \e[34m$i \e[35m$i \e[36m$i \e[39m$i"
sleep 0.1
done
done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}

docker-compose -f ./${ORG_NAME}-config/yaml_files/docker-compose-ca.yaml up -d
docker-compose -f ./${ORG_NAME}-config/yaml_files/docker-compose-kafka.yaml up -d
docker-compose -f ./${ORG_NAME}-config/yaml_files/docker-compose-cli.yaml up -d
# wait for Hyperledger Fabric to start

export FABRIC_START_TIMEOUT=14
echo "please wait ${FABRIC_START_TIMEOUT} second"
#sleep ${FABRIC_START_TIMEOUT}

echo -e "\e[35mCreating channel ==>\e[5m$CHANNEL_NAME\e[0m"
echo -e "\e[93########################################\e[0m"
spin &
pid=$!
sleep ${FABRIC_START_TIMEOUT}

echo -ne "\r"
kill -9 $pid

docker exec -e "ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem" cli${ORG_NAME}  peer channel create -o orderer0.${ORG_NAME}.$DOMAIN_NAME.com:7050 -c $CHANNEL_NAME -f /var/hyperledger/channels/$CHANNEL_NAME/$CHANNEL_NAME.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem >&magicScriptChannelErrorLog.txt
res=$?


verifyResult $res "Channel creation failed"
#cat log.txt

echo -e "\e[35mchannel created sucessfully\e[0m"
echo -e "\e[93#############################\e[0m"
###########################################
####
docker exec cli${ORG_NAME} cp $CHANNEL_NAME.block /var/hyperledger/channels/$CHANNEL_NAME/
####
docker exec -e "CORE_PEER_LOCALMSPID=${ORG_NAME}MSP" -e "CORE_PEER_MSPCONFIGPATH=/var/hyperledger/users/Admin@${ORG_NAME}.$DOMAIN_NAME.com/msp" peer0.${ORG_NAME}.$DOMAIN_NAME.com peer channel join -b var/hyperledger/channels/$CHANNEL_NAME/$CHANNEL_NAME.block >&magicScriptChannelErrorLog.txt
res=$?


verifyResult $res "peer0.${ORG_NAME}.$DOMAIN_NAME.com failed to join $CHANNEL_NAME"
#cat log.txt
####
echo -e "\e[35mpeer0.${ORG_NAME}.$DOMAIN_NAME.com joined channel \e[5m$CHANNEL_NAME\e[0m"
echo -e "\e[93#######################################################################\e[0m"

docker exec -e "CORE_PEER_LOCALMSPID=${ORG_NAME}MSP" -e "CORE_PEER_MSPCONFIGPATH=/var/hyperledger/users/Admin@${ORG_NAME}.$DOMAIN_NAME.com/msp" peer1.${ORG_NAME}.$DOMAIN_NAME.com peer channel join -b var/hyperledger/channels/$CHANNEL_NAME/$CHANNEL_NAME.block >&magicScriptChannelErrorLog.txt
res=$?


verifyResult $res "peer1.${ORG_NAME}.$DOMAIN_NAME.com failed to join $CHANNEL_NAME"
#cat log.txt

echo -e "\e[35mpeer1.${ORG_NAME}.$DOMAIN_NAME.com joined channel \e[5m$CHANNEL_NAME\e[0m"
echo -e "\e[93#######################################################################\e[0m"

docker exec -e "ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem" cli${ORG_NAME}  peer channel update -o orderer0.${ORG_NAME}.$DOMAIN_NAME.com:7050 -c $CHANNEL_NAME -f /var/hyperledger/channels/$CHANNEL_NAME/${ORG_NAME}MSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem >&magicScriptChannelErrorLog.txt
res=$?


verifyResult $res "anchorPeer upate failed"
#cat log.txt

#### chain code install
#docker exec -it cli peer chaincode install -n mycc -p github.com/chaincode -v v0
#docker exec -it cli peer chaincode install -n dlt_cc -p github.com/chaincode/common/dltchaincode/node -v v0 -l "node"

### chaincode instantiate
#docker exec -it cli peer chaincode instantiate -o orderer0.${ORG_NAME}.${DOMAIN_NAME}.com:7050 -C ${CHANNEL_NAME} -n mycc github.com/chaincode/common/dltchaincode/node -v v0 -l "node"
### chaincode invoke

sed -it 's/LAST_PORT=.*/LAST_PORT='7061'/' .env

echo "testing started"
sleep 3
# docker exec -it cli peer chaincode invoke -o orderer0.${ORG_NAME}.${DOMAIN_NAME}.com:7050 -n mycc -c '{"Args":["set", "a", "50"]}' -C ${CHANNEL_NAME}
echo "testing ended"
docker exec -i cli${ORG_NAME} apt-get -y update
docker exec -i cli${ORG_NAME} apt-get install -y jq
sudo chmod u+x -R ${ORG_NAME}-config
