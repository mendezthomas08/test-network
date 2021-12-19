#!/bin/bash

npm install -g composer-cli@0.19.12

npm install -g composer-rest-server@0.19.12

npm install -g generator-hyperledger-composer@0.19.12

npm install -g yo

npm install -g composer-playground@0.19.12

npm install -g pm2

mkdir ~/fabric-dev-servers 
cd ~/fabric-dev-servers

curl -O https://raw.githubusercontent.com/hyperledger/composer-tools/master/packages/fabric-dev-servers/fabric-dev-servers.tar.gz

tar -xvf fabric-dev-servers.tar.gz

cd ~/fabric-dev-servers
export FABRIC_VERSION=hlfv11
./downloadFabric.sh

git clone https://github.com/mahoney1/fabric-samples.git

curl -sSL https://goo.gl/6wtTN5 | bash -s 1.4.7  1.4.7  0.4.21

sudo apt-get -y update
sudo apt-get install -y jq
#git clone https://github.com/dltsg/dlt-network-base.git
docker pull hyperledger/fabric-kafka:0.4.21
docker pull hyperledger/fabric-zookeeper:0.4.21
docker pull hyperledger/fabric-couchdb:0.4.21
