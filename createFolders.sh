#!/bin/bash

ORG_NAME="$1"
DOMAIN_NAME="$2"

mkdir -p ${ORG_NAME}-config/crypto-config/
cd ${ORG_NAME}-config/crypto-config
mkdir -p fabric-ca

mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/ca
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/msp/admincerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/msp/cacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/keystore
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/keystore
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/keystore
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/tls
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/tlsca
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/admincerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/cacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/keystore
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/signcerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls

mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/ca
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/keystore
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/keystore
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/tlsca
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/keystore
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts
mkdir -p peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/tls
