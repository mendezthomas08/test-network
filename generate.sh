#!/bin/bash
#
function printHelp() {
  echo -e "\e[34m#############################################################################################\e[0m"
  echo -e "\e[31mUsage: \e[0m"
  echo -e "\e[32m\e[1mgenerate.sh [<org name>] [<Domain Name>] [<Network Name>] [<Channel Name>]\e[0m"
  echo -e "\e[35m[<org name>]\e[0m= name of the org\e[0m"
  echo -e "\e[35m[<Domain Name>]\e[0m= domain name of the org\e[0m"
  echo -e "\e[35m[<Network Name>]\e[0m= swarm overlay network name\e[0m"
  echo -e "\e[35m[<Channel Name>]\e[0m= name of the channel\e[0m"
  echo -e "\e[34m#############################################################################################\e[0m"
}

if [ "$#" = 0 ]; then
 printHelp
 exit 1
fi


ORG_NAME="$1"
DOMAIN_NAME="$2"
NETWORK_NAME="$3"
CHANNEL_NAME="$4"
CA_PASSWORD="$5"
#export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/bin:${PWD}:$PATH
export PATH=${PWD}/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/${ORG_NAME}-config/yaml_files
#
echo -e "\e[34m###########################################################\e[0m" 
echo -e "\e[32m creating Driver overlay ${NETWORK_NAME}\e[0m"
echo -e "\e[34m###########################################################\e[0m"
docker network create --attachable --driver overlay ${NETWORK_NAME}
# 
echo "$FABRIC_CFG_PATH"
# 
CURRENT_DIR=$PWD
#mkdir -p ${ORG_NAME}-config
#mkdir -p ${ORG_NAME}-config/yaml_files
mkdir -p ${ORG_NAME}-config/yaml_files/fabric-ca-server
mkdir -p orderer-crypto
cp common-artifacts/base-crypto-config.yaml ${ORG_NAME}-config/yaml_files/crypto-config.yaml
cp common-artifacts/base-configtx.yaml ${ORG_NAME}-config/yaml_files/configtx.yaml
# 
# 
# 
cd ${ORG_NAME}-config/yaml_files
sed -i "s/ORG_NAME/${ORG_NAME}/g" crypto-config.yaml
sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" crypto-config.yaml
#rm crypto-config.yamlt
#
#
sed -i "s/ORG_NAME/${ORG_NAME}/g" configtx.yaml
sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" configtx.yaml
#rm configtx.yamlt
#
cd ../../
NODE_PATH=$(which node)
echo $NODE_PATH
sed -i 's/CORE_PEER_NETWORKID=.*/CORE_PEER_NETWORKID='$NETWORK_NAME'/' .env
sed -i 's/COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME='$NETWORK_NAME'/' .env
#sed -i 's|NODE_PATH=.*|NODE_PATH='$NODE_PATH'|' .env
#
cp common-artifacts/base-docker-compose-kafka.yaml ${ORG_NAME}-config/yaml_files/docker-compose-kafka.yaml
cp common-artifacts/base-docker-compose-base.yaml ${ORG_NAME}-config/yaml_files/docker-compose-base.yaml
cp common-artifacts/base-docker-compose-cli.yaml ${ORG_NAME}-config/yaml_files/docker-compose-cli.yaml
cp common-artifacts/base-docker-compose-ca.yaml ${ORG_NAME}-config/yaml_files/docker-compose-ca.yaml
cp common-artifacts/fabric-ca-server-config.yaml ${ORG_NAME}-config/yaml_files/fabric-ca-server-config.yaml
cd ${ORG_NAME}-config/yaml_files

sed -i "s/ORG_NAME/${ORG_NAME}/g" docker-compose-kafka.yaml
sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" docker-compose-kafka.yaml
sed -i "s/NETWORK_NAME/${NETWORK_NAME}/g" docker-compose-kafka.yaml
sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" docker-compose-base.yaml
sed -i "s/NETWORK_NAME/${NETWORK_NAME}/g" docker-compose-base.yaml
sed -i "s/CHANNEL_NAME/${CHANNEL_NAME}/g" docker-compose-base.yaml
sed -i "s/ORG_NAME/${ORG_NAME}/g" docker-compose-cli.yaml
sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" docker-compose-cli.yaml
sed -i "s/NETWORK_NAME/${NETWORK_NAME}/g" docker-compose-cli.yaml
sed -i "s/ORG_NAME/${ORG_NAME}/g" docker-compose-ca.yaml
sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" docker-compose-ca.yaml
sed -i "s/NETWORK_NAME/${NETWORK_NAME}/g" docker-compose-ca.yaml
sed -i "s/adminpw/${CA_PASSWORD}/g" docker-compose-ca.yaml
sed -i "s/pass: adminpw/pass: ${CA_PASSWORD}/g" fabric-ca-server-config.yaml
sed -i "s/ORG_NAME/${ORG_NAME}/g" fabric-ca-server-config.yaml
#sed -it "s/DOMAIN_NAME/${DOMAIN_NAME}/g" network-config.yaml
#sed -it "s/CHANNEL_NAME/${CHANNEL_NAME}/g" network-config.yaml
#
#rm docker-compose-kafka.yamlt
#rm docker-compose-base.yamlt
#rm docker-compose-cli.yamlt
#rm docker-compose-ca.yamlt
# 
# 
#
cd ../../
# create folders
mkdir -p ${ORG_NAME}-config/channels/${CHANNEL_NAME}
#mkdir -p ${ORG_NAME}-config/crypto-config

# remove previous crypto material and config transactions
#rm -fr ./config/*
#rm -fr ./crypto-config/*
./createFolders.sh ${ORG_NAME} ${DOMAIN_NAME}
mv ${ORG_NAME}-config/yaml_files/fabric-ca-server-config.yaml ${ORG_NAME}-config/crypto-config/fabric-ca/
# generate crypto material
#cryptogen generate --config=./yaml_files/crypto-config.yaml
docker-compose -f ./${ORG_NAME}-config/yaml_files/docker-compose-ca.yaml up -d
sleep 8
./createCrypto.sh ${ORG_NAME} ${DOMAIN_NAME} ${CA_PASSWORD}

cd ${ORG_NAME}-config/
#mv -f crypto-config/ ${ORG_NAME}-config/
# generate genesis block for orderer
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channels/${CHANNEL_NAME}/orderer.block  # Change folder to one level higher. For 1.4.2, we specify channelID (sys_dltledgers_chnl)
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channels/${CHANNEL_NAME}/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channels/${CHANNEL_NAME}/${ORG_NAME}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg ${ORG_NAME}MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for ${ORG_NAME}MSP..."
  exit 1
fi
cp -R crypto-config/ordererOrganizations ../orderer-crypto/
cd ../
CURRENT_DIR=$PWD
#cd ${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/ca/
#PRIV_KEY=$(ls *_sk)
#cd "$CURRENT_DIR"
#cd "$CURRENT_DIR"
#cd ${ORG_NAME}-config/yaml_files/
#sed -i "s/CA_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-ca.yaml
#sed -i "s/CA_PORT/7054/g" docker-compose-ca.yaml
