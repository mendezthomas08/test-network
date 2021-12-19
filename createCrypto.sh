#!/bin/bash

ORG_NAME="$1"
DOMAIN_NAME="$2"
CA_PASSWORD="$3"
STATE=singapore
COUNTRY=SG

  echo
	echo "Enroll the CA admin"
  echo


export FABRIC_CA_CLIENT_HOME=${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/

  fabric-ca-client enroll -u https://admin:${CA_PASSWORD}@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

  echo
	echo "Register peer0"
  echo
	fabric-ca-client register -d --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com --id.name peer0.${ORG_NAME}.${DOMAIN_NAME}.com --id.secret peer0pw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

  echo "Register peer1"
  echo
  fabric-ca-client register -d --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com --id.name peer1.${ORG_NAME}.${DOMAIN_NAME}.com --id.secret peer1pw --id.type peer --csr.cn ${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --myhost ${DOMAIN_NAME}.com --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem
  echo

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register -d --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com --id.name Admin@${ORG_NAME}.${DOMAIN_NAME}.com --id.secret ${ORG_NAME}adminpw --id.type client --id.attrs '"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"' --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem
  echo
  echo "Register the orderer admin"
  echo
  fabric-ca-client register -d --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com --id.name Admin@${DOMAIN_NAME}.com --id.secret ordereradminpw --id.type client --id.attrs '"hf.Registrar.Roles=orderer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"' --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem
   echo
  echo "Register the orderer0"
  echo
  fabric-ca-client register -d --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com --id.name orderer0.${ORG_NAME}.${DOMAIN_NAME}.com --id.secret orderer0pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem
  echo "Register the orderer1"
  echo
  fabric-ca-client register -d --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com --id.name orderer1.${ORG_NAME}.${DOMAIN_NAME}.com --id.secret orderer1pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

    echo "Register the orderer2"
  echo
  fabric-ca-client register -d --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com --id.name orderer2.${ORG_NAME}.${DOMAIN_NAME}.com --id.secret orderer2pw --id.type orderer --id.attrs '"hf.Registrar.Roles=orderer"' --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

  echo
  echo "## Generate the peer0 msp"
  echo
	fabric-ca-client enroll -u https://peer0.${ORG_NAME}.${DOMAIN_NAME}.com:peer0pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp --csr.hosts peer0.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0.${ORG_NAME}.${DOMAIN_NAME}.com:peer0pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls --enrollment.profile tls --csr.hosts peer0.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/keystore/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.key


echo "## Generate the peer1 msp"
  echo
  fabric-ca-client enroll -u https://peer1.${ORG_NAME}.${DOMAIN_NAME}.com:peer1pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp --csr.hosts peer1.${ORG_NAME}.${DOMAIN_NAME}.com  --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem


 echo "## Generate the peer1-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer1.${ORG_NAME}.${DOMAIN_NAME}.com:peer1pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls --enrollment.profile tls --csr.hosts peer1.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

    cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/keystore/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.key


  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem


  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/tlsca/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem


  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/ca/ca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem








  echo
  echo "## Generate the org admin msp"
  echo
	fabric-ca-client enroll -u https://Admin@${ORG_NAME}.${DOMAIN_NAME}.com:${ORG_NAME}adminpw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp --csr.hosts ${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

   echo
  echo "## Generate the org admin tls"
  echo
  fabric-ca-client enroll -u https://Admin@${ORG_NAME}.${DOMAIN_NAME}.com:${ORG_NAME}adminpw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/tls --enrollment.profile tls --csr.hosts ${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com//tls/ca.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com//tls/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com//tls/client.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com//tls/keystore/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com//tls/client.key
   echo
  echo "## Generate the orderer0 msp"
  echo
  fabric-ca-client enroll -u https://orderer0.${ORG_NAME}.${DOMAIN_NAME}.com:orderer0pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp --csr.hosts orderer0.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

 echo
  echo "## Generate the orderer0 -tls"
  echo
fabric-ca-client enroll -u https://orderer0.${ORG_NAME}.${DOMAIN_NAME}.com:orderer0pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls --enrollment.profile tls --csr.hosts orderer0.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/keystore/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.key

#####################
 echo "## Generate the orderer1 msp"
  echo
  fabric-ca-client enroll -u https://orderer1.${ORG_NAME}.${DOMAIN_NAME}.com:orderer1pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp --csr.hosts orderer0.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

 echo
  echo "## Generate the orderer1  -tls"
  echo
fabric-ca-client enroll -u https://orderer1.${ORG_NAME}.${DOMAIN_NAME}.com:orderer1pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls --enrollment.profile tls --csr.hosts orderer1.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/keystore/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.key

#####################

echo "## Generate the orderer2  msp"
  echo
  fabric-ca-client enroll -u https://orderer2.${ORG_NAME}.${DOMAIN_NAME}.com:orderer2pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp --csr.hosts orderer2.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

 echo
  echo "## Generate the orderer2  -tls"
  echo
fabric-ca-client enroll -u https://orderer2.${ORG_NAME}.${DOMAIN_NAME}.com:orderer2pw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/tls --enrollment.profile tls --csr.hosts orderer2.${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/tls/ca.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/tls/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/tls/keystore/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/tls/server.key

#####################


echo
  echo "## Generate the orderer admin msp"
  echo
  fabric-ca-client enroll -u https://Admin@${DOMAIN_NAME}.com:ordereradminpw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp --csr.hosts ${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem


 echo "## Generate the orderer admin  tls"
  echo
  fabric-ca-client enroll -u https://Admin@${DOMAIN_NAME}.com:ordereradminpw@localhost:7054 --caname ca.${ORG_NAME}.${DOMAIN_NAME}.com -M ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls --enrollment.profile tls --csr.hosts ${ORG_NAME}.${DOMAIN_NAME}.com --csr.names O=${ORG_NAME},ST=${STATE},C=${COUNTRY} --tls.certfiles ${PWD}/${ORG_NAME}-config/crypto-config/fabric-ca/tls-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls/tlscacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls/ca.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls/client.crt
  cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls/keystore/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls/client.key



cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/tlsca/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/tlsca/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/tlsca/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/tlsca/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem




mv ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/ca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem


cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem


mv ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/ca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem




mv ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/ca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/peer0.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/ca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/peers/peer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/peer1.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem




cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/tls/ca.crt ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/signcerts/Admin@${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/signcerts/Admin@${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/cacerts/ca.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/tlsca/tlsca.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/cacerts/ca.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/ca/ca.${DOMAIN_NAME}.com-cert.pem






cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/cacerts/ca.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/msp/cacerts/ca.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/tlsca/tlsca.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/ca.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer0.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem



cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/tlsca/tlsca.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/ca.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer1.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem





cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/tlsca/tlsca.${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/signcerts/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem

mv ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/* ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/ca.${DOMAIN_NAME}.com-cert.pem

cp ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/orderers/orderer2.${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${DOMAIN_NAME}.com-cert.pem

rm -r ${PWD}/${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/users/Admin@${DOMAIN_NAME}.com/msp/intermediatecerts
rm -r ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/users/Admin@${ORG_NAME}.${DOMAIN_NAME}.com/msp/intermediatecerts
rm -r ${PWD}/${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/intermediatecerts
