#!/usr/bin/bash

docker exec -it ovn-northd ovn-nbctl ls-add net_east
docker exec -it ovn-northd ovn-nbctl lsp-add net_east vm1
docker exec -it ovn-northd ovn-nbctl lsp-set-addresses vm1 "40:44:00:00:00:01 192.168.1.11"

docker exec -it ovn-northd ovn-nbctl ls-add public
# Create a localnet port
docker exec -it ovn-northd ovn-nbctl lsp-add public ln-public
docker exec -it ovn-northd ovn-nbctl lsp-set-type ln-public localnet
docker exec -it ovn-northd ovn-nbctl lsp-set-addresses ln-public unknown
docker exec -it ovn-northd ovn-nbctl lsp-set-options ln-public network_name=provider

docker exec -it ovn-northd ovn-nbctl lr-add router_east
docker exec -it ovn-northd ovn-nbctl lrp-add router_east router_east-net_east 40:44:00:00:00:04 192.168.1.1/24
docker exec -it ovn-northd ovn-nbctl lsp-add net_east net_east-router_east
docker exec -it ovn-northd ovn-nbctl lsp-set-type net_east-router_east router
docker exec -it ovn-northd ovn-nbctl lsp-set-addresses net_east-router_east router
docker exec -it ovn-northd ovn-nbctl lsp-set-options net_east-router_east router-port=router_east-net_east



function ovn_add_phys_port_1 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    docker exec -it ovs-vswitchd ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}
ovn_add_phys_port_1 vm1 40:44:00:00:00:01 192.168.1.11 24 192.168.1.1




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

ovn_add_phys_port_2 vm1 40:44:00:00:00:01 192.168.1.11 24 192.168.1.1


ip netns exec vm1 ping 192.168.1.1
