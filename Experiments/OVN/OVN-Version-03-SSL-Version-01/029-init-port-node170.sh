#!/usr/bin/bash

function ovn_add_phys_port_1 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    docker exec -it ovs-vswitchd ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}
ovn_add_phys_port_1 vm1 40:44:00:00:00:01 12.0.0.11 24 12.0.0.1




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
    ip netns exec $name route add -net 192.168.0.0 netmask 255.255.0.0 gw 12.0.0.66
}

ovn_add_phys_port_2 vm1 40:44:00:00:00:01 12.0.0.11 24 12.0.0.1


ip netns exec vm1 ping 12.0.0.1 -c 5 
