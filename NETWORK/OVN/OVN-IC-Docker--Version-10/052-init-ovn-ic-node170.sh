#!/usr/bin/bash


NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
JOINTYPE=$(if [[ $NODEID -eq '170' ]];   then  echo "";   else     echo "-join";   fi)

docker exec -it ovn-ic_nb_ovsdb ovn-ic-nbctl ts-add ts1
docker exec -it ovn-ic_nb_ovsdb ovn-ic-nbctl ts-add sw1
docker exec -it ovn-ic_nb_ovsdb ovn-ic-nbctl ts-add sw2
