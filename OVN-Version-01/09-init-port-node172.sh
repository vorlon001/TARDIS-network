#!/usr/bin/bash

function ovn_add_phys_port_1 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    docker exec -it ovs-vswitchd ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}
ovn_add_phys_port_1 vm3 40:44:00:00:00:03 192.168.1.13 24 192.168.1.1




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

ovn_add_phys_port_2 vm3 40:44:00:00:00:03 192.168.1.13 24 192.168.1.1


ip netns exec vm3 ping 192.168.1.1 -c 3
ip netns exec vm3 ping 192.168.1.11 -c 3
ip netns exec vm3 ping 192.168.1.12 -c 3
