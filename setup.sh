#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"
FILE_NAME=$(find . -iname "*swarm*yml")


is_docker_swarm_created(){
    # 0   created, 
    # 111 not
    #validate if already created boxes
    MACHINES=$(docker-machine ls | awk 'NR > 1')
    if [[ -n $MACHINES && ! $MACHINES =~ Running ]];

        then
            echo "[+] machines founded"
            #start machines
            docker-machine ls | awk 'NR > 1 { print $1 }' | xargs -I{} docker-machine restart {}
            return 0
    fi
    return 111
}


docker_swarm(){
if [[ -z $MACHINES ]];

    then
        CIDR="192.168.77.1/16"
        DEL_VBOX_ADAPTER=$(VBoxManage  list hostonlyifs | grep -i 77 -B4 |grep -i name | awk '{ print $NF }' | xargs -I{} VBoxManage hostonlyif remove {} 2>&-)

        #______________[ Create machines  & initialize master and nodes ]
        echo "[+] creating machines"
        for NODE in master node{1..2};
        do

            #create machines
            echo "[+]________________________[ creating $NODE ]"
            docker-machine create -d virtualbox --virtualbox-memory "1024" --virtualbox-hostonly-cidr $CIDR  $NODE &>/dev/null

            sleep 1

            #____[ initialize master and worker ]
            if [[ $NODE = "master" ]] ;
                then
                    echo "[+]________________________[ enter configure master ]"
                    MASTER_INIT=$( docker-machine ssh ${NODE} -- docker swarm init --advertise-addr $(docker-machine ip ${NODE}) )
                    WORKER_INIT=$(echo "$MASTER_INIT" | grep -i "join " | sed "s|^\s*||g")
                    sleep 1

                else
                    echo "[+]________________________[ enter configure $NODE ]"
                    docker-machine ssh "${NODE}" -- "${WORKER_INIT}"
            fi

        done

    else
        echo "[+] machines already up"

fi
} # docker_swarm_end


webapp_secret(){
#______________[ secret ]

eval $(docker-machine env master)

echo "foobar" | docker secret create secret_code -
}


webapp_build(){
#______________[ stack build ]

eval $(docker-machine env -u)

for i in `ls -1 ./services`;
do
    docker build -t ddtmx/flask_${i}:latest -f ./services/${i}/Dockerfile ./services/${i}
    docker push ddtmx/flask_${i}:latest
done
}


webapp_deploy(){
#_____________[ stack deploy ]

eval $(docker-machine env master)
for file in $FILE_NAME;
do
    name=${file#*_}    #prefix
    name=${name%*.yml} #suffix
    docker stack deploy -c $file $name
done

}

docker_swarm
webapp_secret
webapp_build
webapp_deploy

