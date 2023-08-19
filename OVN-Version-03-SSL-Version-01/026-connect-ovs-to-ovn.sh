#!/usr/bin/bash

docker exec -it ovs-vswitchd ovs-vsctl show
docker exec -it ovs-vswitchd ovs-vsctl add-br br-int
docker exec -it ovs-vswitchd ovs-vsctl show

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
echo $NODEID


docker exec -it ovsdb-server ovs-appctl -t ovsdb-server ovsdb-server/add-remote ptcp:6640

docker exec -it ovs-vswitchd ovs-vsctl set open_vswitch . external-ids:system-id="node${NODEID}.cloud.local"
docker exec -it ovs-vswitchd ovs-vsctl --columns external_ids list open_vswitch
docker exec -it ovs-vswitchd ovs-vsctl set open . external-ids:ovn-bridge=br-int
docker exec -it ovs-vswitchd ovs-vsctl set open . external-ids:ovn-remote=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642
docker exec -it ovs-vswitchd ovs-vsctl set open . external-ids:ovn-encap-ip=192.168.200.${NODEID}
#docker exec -it ovs-vswitchd ovs-vsctl set open . external-ids:ovn-encap-type=vxlan
#docker exec -it ovs-vswitchd ovs-vsctl set open . external-ids:ovn-encap-type=geneve
docker exec -it ovs-vswitchd ovs-vsctl set open . external-ids:ovn-encap-type=geneve,vxlan

# geneve vxlan

docker exec -it ovs-vswitchd netstat -napt
docker exec -it ovs-vswitchd ovs-vsctl show
docker exec -it ovs-vswitchd ovs-vsctl --columns external_ids list open_vswitch

#docker exec -it ovs-controller /usr/share/ovn/scripts/ovn-ctl \
#                 --ovn-controller-ssl-key=/etc/ovn/ovn-privkey.pem \
#                 --ovn-controller-ssl-cert=/etc/ovn/ovn-cert.pem \
#                 --ovn-controller-ssl-ca-cert=/etc/ovn/cacert.pem restart_controller

#docker exec -it ovs-vswitchd ovs-vsctl show
#docker exec -it ovs-vswitchd ovs-vsctl --columns external_ids list open_vswitch
#echo "sleep 8 sec."
#sleep 8
#docker ps -a
#docker restart  ovs-controller
echo "sleep 8 sec."
sleep 8
docker ps -a

docker exec -it ovn-northd-ssl ovn-nbctl --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 show
docker exec -it ovn-northd-ssl ovn-sbctl --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642 show

