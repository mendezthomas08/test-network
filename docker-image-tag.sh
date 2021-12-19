#!/bin/bash
#
VERSION=1.4.7

 

echo "${VERSION}"

 

#if  [ $VERSION == "1.4.1" ] || [ $VERSION == "1.4.2" ] || [ $VERSION == "x86_64-1.1.0" ]  ; then
docker tag hyperledger/fabric-ca:${VERSION} hyperledger/fabric-ca
docker tag hyperledger/fabric-javaenv:${VERSION} hyperledger/fabric-javaenv
docker tag hyperledger/fabric-tools:${VERSION} hyperledger/fabric-tools
docker tag hyperledger/fabric-ccenv:${VERSION} hyperledger/fabric-ccenv
docker tag hyperledger/fabric-orderer:${VERSION} hyperledger/fabric-orderer
docker tag hyperledger/fabric-peer:${VERSION} hyperledger/fabric-peer
#fi
echo "level 1 success"
if [ $VERSION == "x86_64-1.1.0" ]; then
docker tag hyperledger/fabric-zookeeper:x86_64-0.4.6 hyperledger/fabric-zookeeper
docker tag hyperledger/fabric-kafka:x86_64-0.4.6 hyperledger/fabric-kafka
docker tag hyperledger/fabric-couchdb:x86_64-0.4.6 hyperledger/fabric-couchdb
docker tag hyperledger/fabric-baseimage:x86_64-0.4.6 hyperledger/fabric-baseimage
elif [ $VERSION == "1.4.1" ] || [ $VERSION == "1.4.2" ]; then
docker tag hyperledger/fabric-zookeeper:0.4.15 hyperledger/fabric-zookeeper
docker tag hyperledger/fabric-kafka:0.4.15 hyperledger/fabric-kafka
docker tag hyperledger/fabric-couchdb:0.4.15 hyperledger/fabric-couchdb

elif [ $VERSION == "1.4.7" ]; then
docker tag hyperledger/fabric-zookeeper:0.4.21 hyperledger/fabric-zookeeper
docker tag hyperledger/fabric-kafka:0.4.21 hyperledger/fabric-kafka
docker tag hyperledger/fabric-couchdb:0.4.21 hyperledger/fabric-couchdb
fi
