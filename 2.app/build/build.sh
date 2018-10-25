#!/bin/sh

[[ ${#@} -lt 4 || ${#@} -gt 4 ]] && echo '
DOCKER_USER =$1
DOCKER_IMAGE=$2
SERVICE     =$3
TAG         =$4
'



DOCKER_USER=$1
DOCKER_IMAGE=$2
SERVICE=$3
TAG=$4


# ______[ BUILD SCRIPT ]
docker build -t $DOCKER_USER/$DOCKER_IMAGE:${TAG} -f ./services/${SERVICE}

docker push $DOCKER_USER/$DOCKER_IMAGE:latest
docker push $DOCKER_USER/$DOCKER_IMAGE:${TAG}



