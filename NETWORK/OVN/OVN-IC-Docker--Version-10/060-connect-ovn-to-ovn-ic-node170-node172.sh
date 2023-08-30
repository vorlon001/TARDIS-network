#!/usr/bin/bash

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')

cat <<EOF>/root/ovn/env.ovn-ic.list.${NODEID}
OVNCMD=ovn-ic-cluster
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641
OVNCLUSTER6642=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642
OVNCLUSTER6645=tcp:192.168.200.170:6645,tcp:192.168.200.171:6645,tcp:192.168.200.172:6645
OVNCLUSTER6646=tcp:192.168.200.170:6646,tcp:192.168.200.171:6646,tcp:192.168.200.172:6646
EOF

cat /root/ovn/env.ovn-ic.list.${NODEID}


docker run -it -d --restart=always --network=host --privileged  --hostname=ovn-ic --env-file=/root/ovn/env.ovn-ic.list.${NODEID} --name ovn-ic  -v /root/ovn/log:/var/log/ovn/ -v /root/ovn/lib:/var/lib/ovn -v /root/ovn/run:/var/run/ovn ovn:v10
docker ps -a

