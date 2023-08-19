#!/usr/bin/bash

docker exec -it ovsdb-server ovs-vsctl show
docker exec -it ovsdb-server ovs-vsctl add-br br-int
docker exec -it ovsdb-server ovs-vsctl show

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
echo $NODEID
docker exec -it ovsdb-server ovs-vsctl set open_vswitch . external-ids:system-id="node${NODEID}.cloud.local"
docker exec -it ovsdb-server ovs-vsctl --columns external_ids list open_vswitch
docker exec -it ovsdb-server ovs-vsctl set open . external-ids:ovn-bridge=br-int
docker exec -it ovsdb-server ovs-vsctl set open . external-ids:ovn-remote=tcp:192.168.200.180:6642,tcp:192.168.200.181:6642,tcp:192.168.200.182:6642
docker exec -it ovsdb-server ovs-vsctl set open . external-ids:ovn-encap-ip=192.168.200.${NODEID}
#docker exec -it ovsdb-server ovs-vsctl set open . external-ids:ovn-encap-type=vxlan
#docker exec -it ovsdb-server ovs-vsctl set open . external-ids:ovn-encap-type=geneve
docker exec -it ovsdb-server ovs-vsctl set open . external-ids:ovn-encap-type=geneve,vxlan

# geneve vxlan

docker exec -it ovsdb-server netstat -napt
docker exec -it ovsdb-server ovs-vsctl show
docker exec -it ovsdb-server ovs-vsctl --columns external_ids list open_vswitch


docker restart  ovs-controller

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 show
docker exec -it ovn-northd ovn-sbctl --db=tcp:192.168.200.180:6642,tcp:192.168.200.181:6642,tcp:192.168.200.182:6642 show
