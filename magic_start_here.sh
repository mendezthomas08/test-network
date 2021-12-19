#!/bin/bash
function printHelp() {
  echo -e "\e[34m######################################################################################################\e[0m"
  echo -e "Usage: "
  echo -e "\e[32mmagic_start_here.sh <mode> [<org name>] [<doamin name>] [<Network Name>] [<Channel Name>]\e[0m"
  echo "<mode> - one of 'up', 'down'"
  echo "for testing run the following"
  echo -e "\e[33m./magic_start_here.sh up dltorg dlt-domain dlt-network dltchannel\e[0m"
  echo -e "\e[34m######################################################################################################\e[0m"
}

#
# Ask user for confirmation to proceed
function askProceed() {
  read -p "Continue? [Y/n] " ans
  case "$ans" in
  y | Y | "")
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    exit 1
    ;;
  *)
    echo "invalid response"
    askProceed
    ;;
  esac
}


function enterParam() {
  read -p "Enter card Name:" cardname
  read -p "Enter Port:" port
if test -z "$cardname"
then
 echo -e "\e[31minvalid cardName or Port, Please re-enter\e[0m"
    enterParam
elif test -z "$port"
then
  echo -e "\e[31minvalid port, please re-enter\e[0m"
  enterParam
else
re='^[0-9]+$'
if ! [[ $port =~ $re ]] ; then
   echo "error: port is not a number,please re-enter"
  enterParam
fi
 CARD_NAME=$cardname
 REST_PORT=$port
fi
}

MODE="$1"
ORG_NAME="$2"
DOMAIN_NAME="$3"
NETWORK_NAME="$4"
CHANNEL_NAME="$5"
FABRIC_PORT="4000"
CA_PASSWORD="$(echo `expr $(date +%s) + $(date +%N)` | sha256sum | head -c 24)"
shift
# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$MODE" == "up" ]; then
  EXPMODE="Starting"
elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping"
else
  printHelp
  exit 1
fi


if [ "${MODE}" == "up" ]; then
  ./generate.sh ${ORG_NAME} ${DOMAIN_NAME} ${NETWORK_NAME} ${CHANNEL_NAME} ${CA_PASSWORD}
  echo -e "\e[34m############################################################\e[0m"
  echo -e "\e[32mgenerated all configurations\e[0m"
  echo -e "\e[34m############################################################\e[0m"
  ./start.sh ${ORG_NAME} ${DOMAIN_NAME} ${NETWORK_NAME} ${CHANNEL_NAME}
  echo -e "\e[34m############################################################\e[0m"
  echo -e "\e[32mnetwork started\e[0m"
  echo -e "\e[34m############################################################\e[0m"
  NETWORKSECRET=$(echo `expr $(date +%s) + $(date +%N)` | sha256sum | head -c 64)

  ./fabricconfiguration.sh ${ORG_NAME} ${DOMAIN_NAME} ${NETWORK_NAME} ${CHANNEL_NAME} ${CA_PASSWORD} ${FABRIC_PORT} ${NETWORKSECRET}
  echo -e "\e[34m############################################################\e[0m"
  echo -e "\e[32mfabricSDK api is available in Port ${FABRIC_PORT}\e[0m"
  echo -e "\e[34m############################################################\e[0m"


  base64tlscert=$(cat ${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem | base64)

   base64cacert=$(cat ${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/cacerts/ca.${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem | base64)

   base64admincert=$(cat ${ORG_NAME}-config/crypto-config/peerOrganizations/${ORG_NAME}.${DOMAIN_NAME}.com/msp/admincerts/Admin@${ORG_NAME}.${DOMAIN_NAME}.com-cert.pem | base64)

   base64ordererCacert=$(cat ${ORG_NAME}-config/crypto-config/ordererOrganizations/${DOMAIN_NAME}.com/msp/tlscacerts/tlsca.${DOMAIN_NAME}.com-cert.pem | base64)


  cat > ${ORG_NAME}_certificates.json << EOF



{
  "tlscert": "$(echo -e "${base64tlscert}" | tr -d '[:space:]')",
  "cacert": "$(echo -e "${base64cacert}" | tr -d '[:space:]')",
  "admincert": "$(echo -e "${base64admincert}" | tr -d '[:space:]')",
  "ordererCacert": "$(echo -e "${base64ordererCacert}" | tr -d '[:space:]')",
  "secret": "$NETWORKSECRET",
  "orgName": "${ORG_NAME}",
  "channelName": "${CHANNEL_NAME}",
  "chaincodeName": "mycc"
}

EOF
 sleep 5
./curl-register-install-instantiate.sh ${ORG_NAME} ${DOMAIN_NAME} ${CHANNEL_NAME} ${NETWORKSECRET}

./curl-test.sh $NETWORKSECRET
elif [ "${MODE}" == "down" ]; then ## Clear the network
  ./stop.sh
else
  printHelp
  exit 1
fi
