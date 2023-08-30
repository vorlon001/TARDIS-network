#!/usr/bin/bash

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
JOINTYPE=$(if [[ $NODEID -eq '180' ]];   then  echo "";   else     echo "-join";   fi)

export TAGNODE=8
export NODE1=192.168.200.1${TAGNODE}0
export NODE2=192.168.200.1${TAGNODE}1
export NODE3=192.168.200.1${TAGNODE}2
export PORT6641="tcp:${NODE1}:6641,tcp:${NODE2}:6641,tcp:${NODE3}:6641"
export PORT6642="tcp:${NODE1}:6642,tcp:${NODE2}:6642,tcp:${NODE3}:6642"

cat <<EOF>/root/ovn/env.ovn-run_nb_ovsdb.list.${NODEID}
OVNCMD=ovn-run_nb_ovsdb-cluster${JOINTYPE}
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTERJOINIP=${NODE1}
OVNCLUSTER6641=${PORT6641}
OVNCLUSTER6642=${PORT6642}
EOF

cat <<EOF>/root/ovn/env.ovn-run_sb_ovsdb.list.${NODEID}
OVNCMD=ovn-run_sb_ovsdb-cluster${JOINTYPE}
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTERJOINIP=${NODE1}
OVNCLUSTER6641=${PORT6641}
OVNCLUSTER6642=${PORT6642}
EOF

cat <<EOF>/root/ovn/env.ovn-northd.list.${NODEID}
OVNCMD=ovn-northd-cluster
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=${PORT6641}
OVNCLUSTER6642=${PORT6642}
EOF

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
cat /root/ovn/env.ovn-run_nb_ovsdb.list.${NODEID}
cat /root/ovn/env.ovn-run_sb_ovsdb.list.${NODEID}
cat /root/ovn/env.ovn-northd.list.${NODEID}

docker run -it -d --restart=always   --network=host --privileged  --hostname=ovn-run_nb_ovsdb --env-file=/root/ovn/env.ovn-run_nb_ovsdb.list.${NODEID} --name ovn-run_nb_ovsdb  -v /root/ovn/log:/var/log/ovn/ -v /root/ovn/lib:/var/lib/ovn -v /root/ovn/run:/var/run/ovn ovn:v10

docker run -it -d --restart=always  --network=host --privileged  --hostname=ovn-run_sb_ovsdb --env-file=/root/ovn/env.ovn-run_sb_ovsdb.list.${NODEID} --name ovn-run_sb_ovsdb -v /root/ovn/log:/var/log/ovn/ -v /root/ovn/lib:/var/lib/ovn -v /root/ovn/run:/var/run/ovn ovn:v10

docker run -it -d --restart=always  --network=host --privileged  --hostname=ovn-northd  --env-file=/root/ovn/env.ovn-northd.list.${NODEID} --name ovn-northd -v /root/ovn/log:/var/log/ovn/ -v /root/ovn/lib:/var/lib/ovn -v /root/ovn/run:/var/run/ovn ovn:v10

docker ps -a



docker exec -it ovn-run_nb_ovsdb ovn-nbctl --inactivity-probe=60000 set-connection ptcp:6641:0.0.0.0
docker exec -it ovn-run_sb_ovsdb ovn-sbctl --inactivity-probe=60000 set-connection ptcp:6642:0.0.0.0

