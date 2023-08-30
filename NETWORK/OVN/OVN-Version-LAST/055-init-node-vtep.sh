#!/usr/bin/bash

#!/usr/bin/bash

# docker stop $(docker ps -aq)
# docker rm $(docker ps -aq) --force

set -x

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
echo $NODEID
cat <<EOF>/root/e.sh
cd /root/ovs
rm -R openvswitch
rm -R log
rm -R lib
rm -R run
mkdir openvswitch
mkdir log
mkdir lib
mkdir run
cd /root/ovn
rm -R openvswitch
rm -R log
rm -R lib
rm -R run
mkdir openvswitch
mkdir log
mkdir lib
mkdir run
cd /root/vtep/ovs
rm -R openvswitch
rm -R log
rm -R db
rm -R lib
rm -R run
mkdir openvswitch
mkdir db
mkdir log
mkdir lib
mkdir run
cd /root/vtep/ovn
rm -R openvswitch
rm -R log
rm -R lib
rm -R run
mkdir openvswitch
mkdir log
mkdir lib
mkdir run
cd /root
EOF
chmod +x /root/e.sh
/root/e.sh

cat <<EOF>/root/ovn/env.ovsdb-init.list.${NODEID}
OVNCMD=ovsdb-init
OVNCTEPGATEWAY=GW01
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641
OVNCLUSTER6642=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642
EOF

cat <<EOF>/root/ovn/env.ovsdb-vtep-init.list.${NODEID}
OVNCMD=ovsdb-vtep-init
OVNCTEPGATEWAY=GW01
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641
OVNCLUSTER6642=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642
EOF





cat <<EOF>/root/ovn/env.ovn-controller-vtep.list.${NODEID}
OVNCMD=ovn-controller-vtep
OVNCTEPGATEWAY=GW01
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641
OVNCLUSTER6642=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642
EOF

cat <<EOF>/root/ovn/env.ovsdb-server-vtep.list.${NODEID}
OVNCMD=ovsdb-server-vtep
OVNCTEPGATEWAY=GW01
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641
OVNCLUSTER6642=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642
EOF

cat <<EOF>/root/ovn/env.ovs-vtepd.${NODEID}
OVNCMD=ovs-vtepd
OVNCTEPGATEWAY=GW01
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641
OVNCLUSTER6642=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642
EOF

cat <<EOF>/root/ovn/env.ovs-vswitchd-vtep.list.${NODEID}
OVNCMD=ovs-vswitchd-vtep
OVNCTEPGATEWAY=GW01
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641
OVNCLUSTER6642=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642
EOF

cat /root/ovn/env.ovn-controller-vtep-init.list.${NODEID}
cat /root/ovn/env.ovsdb-server-vtep.list.${NODEID}
cat /root/ovn/env.ovs-vtepd.${NODEID}
cat /root/ovn/env.ovs-vswitchd-vtep.list.${NODEID}
# STEP 2 init db

rm -R /root/vtep/ovs/openvswitch/.conf.db.~lock~
rm -R /root/vtep/ovs/openvswitch/.conf.db


docker run -it --rm --env-file=/root/ovn/env.ovsdb-init.list.${NODEID} \
--network=host --hostname=init-ovs --name ovsdb-server -v /root/vtep/ovs/openvswitch/db:/etc/openvswitch \
-v /root/vtep/ovs/log:/var/log/openvswitch/ -v /root/vtep/ovs/lib:/var/lib/openvswitch -v /root/vtep/ovs/run:/var/run/openvswitch  \
ovn:v10
docker ps -a

docker run -it --rm --env-file=/root/ovn/env.ovsdb-vtep-init.list.${NODEID} \
--network=host --hostname=init-ovs --name ovsdb-server -v /root/vtep/ovs/openvswitch/db:/etc/openvswitch \
-v /root/vtep/ovs/log:/var/log/openvswitch/ -v /root/vtep/ovs/lib:/var/lib/openvswitch -v /root/vtep/ovs/run:/var/run/openvswitch  \
ovn:v10
docker ps -a


NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
echo $NODEID

docker run -it  -d --restart=always --env-file=/root/ovn/env.ovsdb-server-vtep.list.${NODEID} \
--network=host --hostname=ovsdb-server-vtep --name ovsdb-server-vtep \
 -v /root/vtep/ovs/log:/var/log/openvswitch \
 -v /root/vtep/ovn/log:/var/log/ovn/ \
 -v /root/vtep/ovs/openvswitch/db:/etc/openvswitch \
 -v /root/vtep/ovn/run:/var/run/openvswitch \
ovn:v10
docker ps -a

echo "sleep 10s"
sleep 10

docker run -it  -d --restart=always --env-file=/root/ovn/env.ovn-controller-vtep.list.${NODEID} \
--network=host --hostname=ovn-controller-vtep --name ovn-controller-vtep \
 -v /root/vtep/ovs/log:/var/log/openvswitch \
 -v /root/vtep/ovn/log:/var/log/ovn/ \
 -v //root/vtep/ovs/openvswitch/db:/etc/openvswitch \
 -v /root/vtep/ovn/run:/var/run/openvswitch \
ovn:v10
docker ps -a

echo "sleep 10s"
sleep 10


docker run -it  -d --restart=always --env-file=/root/ovn/env.ovs-vswitchd-vtep.list.${NODEID} \
--network=host --hostname=ovs-vswitchd-vtep --name ovs-vswitchd-vtep \
 -v /root/vtep/ovs/log:/var/log/openvswitch \
 -v /root/vtep/ovn/log:/var/log/ovn/ \
 -v /root/vtep/ovs/openvswitch/db:/etc/openvswitch \
 -v /root/vtep/ovn/run:/var/run/openvswitch \
ovn:v10
docker ps -a

echo "sleep 10s"
sleep 10


docker exec -it ovn-controller-vtep vtep-ctl --db=unix:/var/run/openvswitch/db.sock add-ps GW01
echo "sleep 10s"
sleep 10
docker exec -it ovn-controller-vtep vtep-ctl --db=unix:/var/run/openvswitch/db.sock set Physical_Switch GW01 tunnel_ips=192.168.203.$NODEID
echo "sleep 10s"
sleep 10
docker exec -it ovn-controller-vtep ovs-vsctl --db=unix:/var/run/openvswitch/db.sock add-br GW01
echo "sleep 10s"
sleep 10


NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
echo $NODEID

docker run -it  -d --restart=always --env-file=/root/ovn/env.ovs-vtepd.${NODEID} \
--network=host --hostname=ovs-vtepd.${NODEID} --name ovs-vtepd.${NODEID} \
 -v /root/vtep/ovs/log:/var/log/openvswitch \
 -v /root/vtep/ovn/log:/var/log/ovn/ \
 -v /root/vtep/ovs/openvswitch/db:/etc/openvswitch \
 -v /root/vtep/ovn/run:/var/run/openvswitch \
ovn:v10
docker ps -a

echo "sleep 10s"
sleep 10
