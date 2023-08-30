#!/usr/bin/bash

set -x
#kill -1 $(cat /var/run/openvswitch/ovs-vswitchd.pid)
#kill -1  $(cat /var/run/openvswitch/ovs-vtep.pid)
#kill -1 $(cat /var/run/openvswitch/ovsdb-server.pid)

sudo ip link add veth4 type veth peer name vtap4
sudo ip link add link veth4 name veth4.1 type vlan id 1

sudo ip link set vtap4 up
sudo ip link set veth4 up

sudo ip netns add host4
sudo ip link set veth4.1 netns host4
sudo ip netns exec host4 ip link set veth4.1 up
sudo ip netns exec host4 ip link set lo up
sudo ip netns exec host4 ip addr add 12.0.0.66/24 dev veth4.1
sudo ip netns exec host4 ip link set dev veth4.1 address 00:00:00:44:44:44


docker exec -it ovn-controller-vtep ovs-vsctl --db=unix:/var/run/openvswitch/db.sock add-port GW01 vtap4 -- set Interface vtap4 external_ids:iface-id=sw0-vtep-port1
docker exec -it ovn-controller-vtep vtep-ctl --db=unix:/var/run/openvswitch/db.sock add-ls LS1 -- bind-ls GW01 vtap4 1 LS1


ip netns exec host4 ip link show
ip netns exec host4 ip addr show
