#!/usr/bin/bash

docker exec -it ovn-northd ovn-nbctl ls-add net_west
docker exec -it ovn-northd ovn-nbctl lsp-add net_west vm2
docker exec -it ovn-northd ovn-nbctl lsp-set-addresses vm2 "40:44:00:10:00:02 192.168.2.12"


docker exec -it ovn-northd ovn-nbctl lr-add router_west
docker exec -it ovn-northd ovn-nbctl lrp-add router_west router_west-net_west 40:44:00:00:00:10 192.168.2.1/24
docker exec -it ovn-northd ovn-nbctl lsp-add net_west net_west-router_west
docker exec -it ovn-northd ovn-nbctl lsp-set-type net_west-router_west router
docker exec -it ovn-northd ovn-nbctl lsp-set-addresses net_west-router_west router
docker exec -it ovn-northd ovn-nbctl lsp-set-options net_west-router_west router-port=router_west-net_west

## if not work router port
## docker exec -it ovn-northd ovn-nbctl lrp-del router_west-net_west
## docker exec -it ovn-northd ovn-nbctl lsp-del net_west-router_west

function ovn_add_phys_port_1 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    docker exec -it ovs-vswitchd ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}

ovn_add_phys_port_1 vm2 40:44:00:10:00:02 192.168.2.12 24 192.168.2.1




function ovn_add_phys_port_2 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    ip netns add $name
    ip link set $name netns $name
    ip netns exec $name ip link set $name address $mac
    ip netns exec $name ip addr add $ip/$mask dev $name
    ip netns exec $name ip link set $name up
    ip netns exec $name ip route add default via $gw
}

ovn_add_phys_port_2 vm2 40:44:00:10:00:02 192.168.2.12 24 192.168.2.1


ip netns exec vm2 ping 192.168.2.1
