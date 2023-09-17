#!/usr/bin/bash

export TAGNODE=7
export NODE1=192.168.200.1${TAGNODE}0
export NODE2=192.168.200.1${TAGNODE}1
export NODE3=192.168.200.1${TAGNODE}2
export PORT6641="tcp:${NODE1}:6641,tcp:${NODE2}:6641,tcp:${NODE3}:6641"
export PORT6642="tcp:${NODE1}:6642,tcp:${NODE2}:6642,tcp:${NODE3}:6642"

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 show
docker exec -it ovn-northd ovn-sbctl --db=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642 show
