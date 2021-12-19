#!/bin/bash
# stopping the containers. Note that this will remove all existing docker containers
if [ -z "$(docker ps -aq)" -o "$(docker ps -aq)" == " " ]; then
    echo "no containers to delete"
else
     docker rm -f $(docker ps -aq)
fi

for i in *.err; do test -f "$i" && rm *.err && break; done
for i in *.out; do test -f "$i" && rm *.out && break; done
for i in *.txt; do test -f "$i" && rm *.txt && break; done

sed -i 's/LAST_PORT=.*/LAST_PORT='7061'/' .env
DIR=$PWD/orderer-crypto/
if [ -d "$DIR" ]; then
     sudo rm -rf $DIR
else
    echo "$DIR is Empty"
fi
DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /peer0.*peer0.*/) {print $3}')
 if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
 else
    docker rmi -f $DOCKER_IMAGE_IDS
 fi
PID=`ps -eaf | grep composer-playground | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$PID" ]]; then
  echo "killing $PID"
  kill -9 $PID
fi

sudo rm -rf *-config/
for i in *.pb; do test -f "$i" && rm *.pb && break; done
for i in *.json; do test -f "$i" && rm *.json && break; done
for i in *.block; do test -f "$i" && sudo rm *.block && break; done
DIR=~/.composer/
if [ -d "$DIR" ]; then
rm -rf ~/.composer/
fi
DIR=/var/hyperledger/
if [ -d "$DIR" ]; then
sudo rm -rf /var/hyperledger
fi
cd
DIR=$PWD/blockchain-explorer/
if [ -d "$DIR" ]; then
if [ "$(ls -A $DIR)" ]; then
cd blockchain-explorer/
sudo ./stop.sh
cd ../
rm -rf blockchain-explorer
fi
fi
cd
DIR=$PWD/src/github.com/hyperledger/fabric/peer/
if [ -d "$DIR" ]; then
if [ "$(ls -A $DIR)" ]; then
     sudo rm -rf $DIR/*
else
    echo "$DIR is Empty"
fi
fi
docker system prune --volumes -f

pm2 delete fabricapp
echo -e "\e[36m###############################################################\e[0m"
echo -e "\e[36m#                 \e[5m\e[34m All \e[33mremoved \e[32msucessfully\e[0m\e[36m                    #\e[0m"
echo -e "\e[36m###############################################################\e[0m"
