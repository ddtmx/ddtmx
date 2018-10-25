#!/bin/sh

SWARM_NAME;

name=${SWARM_NAME#*_}    #prefix
name=${name%*.yml} #suffix
docker stack deploy -c $SWARM_NAME $name
