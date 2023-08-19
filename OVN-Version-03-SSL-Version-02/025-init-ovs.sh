#!/usr/bin/bash

export NODE1=192.168.200.170

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
cd /root
EOF
chmod +x /root/e.sh
/root/e.sh

cat <<EOF>/root/ovn/env.ovsdb-init.list.${NODEID}
OVNCMD=ovsdb-init
OVNCLUSTERJOINIP=${NODE1}
OVNICIP=192.168.200.${NODEID}
OVNHOSTIP=192.168.200.${NODEID}
EOF


cat <<EOF>/root/ovn/env.ovsdb-server.list.${NODEID}
OVNCMD=ovsdb-server
OVNCLUSTERJOINIP=${NODE1}
OVNICIP=192.168.200.${NODEID}
OVNHOSTIP=192.168.200.${NODEID}
EOF

cat <<EOF>/root/ovn/env.ovs-vswitchd.${NODEID}
OVNCMD=ovs-vswitchd
OVNCLUSTERJOINIP=${NODE1}
OVNICIP=192.168.200.${NODEID}
OVNHOSTIP=192.168.200.${NODEID}
EOF

cat <<EOF>/root/ovn/env.ovs-controller.list.${NODEID}
OVNCMD=ovs-controller-ssl
OVNCLUSTERJOINIP=${NODE1}
OVNICIP=192.168.200.${NODEID}
OVNHOSTIP=192.168.200.${NODEID}
EOF

cat /root/ovn/env.ovsdb-init.list.${NODEID}
cat /root/ovn/env.ovsdb-server.list.${NODEID}
cat /root/ovn/env.ovs-vswitchd.${NODEID}
cat /root/ovn/env.ovs-controller.list.${NODEID}
# STEP 2 init db

rm -R /root/ovs/openvswitch/.conf.db.~lock~
rm -R /root/ovs/openvswitch/.conf.db

docker run -it --rm --env-file=/root/ovn/env.ovsdb-init.list.${NODEID} \
--network=host --hostname=init-ovs --name ovsdb-server -v /root/ovs/openvswitch:/etc/openvswitch \
-v /root/ovs/log:/var/log/openvswitch/ -v /root/ovs/lib:/var/lib/openvswitch -v /root/ovs/run:/var/run/openvswitch -v /root/ovn/etc:/etc/ovn \
ovn:v11
docker ps -a
# STEP 3
# in pod  ovsdb-server


docker run -it -d --restart=always --env-file=/root/ovn/env.ovsdb-server.list.${NODEID} \
--network=host --privileged  --hostname=ovsdb-server  --name ovsdb-server -v /root/ovs/openvswitch:/etc/openvswitch \
-v /root/ovs/log:/var/log/openvswitch/ -v /root/ovs/lib:/var/lib/openvswitch -v /root/ovs/run:/var/run/openvswitch -v /root/ovn/etc:/etc/ovn ovn:v11
docker ps -a


### STEP 4
### in pod  ovs-vswitchd


docker run -it -d --restart=always --env-file=/root/ovn/env.ovs-vswitchd.${NODEID} \
--network=host --privileged  --hostname=ovs-vswitchd  --name ovs-vswitchd -v /root/ovs/openvswitch:/etc/openvswitch \
-v /root/ovs/log:/var/log/openvswitch/ -v /root/ovs/lib:/var/lib/openvswitch -v /root/ovs/run:/var/run/openvswitch -v /root/ovn/etc:/etc/ovn ovn:v11
docker ps -a


### STEP 4
### in pod  ovs-controller


docker run -it -d  --restart=always --env-file=/root/ovn/env.ovs-controller.list.${NODEID} \
--network=host --privileged  --hostname=ovs-controller  --name ovs-controller -v /root/ovs/openvswitch:/etc/openvswitch \
-v /root/ovs/log:/var/log/openvswitch/ -v /root/ovs/lib:/var/lib/openvswitch -v /root/ovs/run:/var/run/openvswitch -v /root/ovn/etc:/etc/ovn ovn:v11
docker ps -a

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
echo $NODEID
docker exec -it ovsdb-server ovs-vsctl set open_vswitch . external-ids:system-id="node${NODEID}.cloud.local"

