#!/usr/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}

sysctl -w net.ipv4.ip_forward=1

apt-get install -y bridge-utils

ip link add vxlan0 type vxlan id 1 local 10.100.0.171 dev enp1s0.802 dstport 4789
#ip link set vxlan0 mtu 1500
ip link set vxlan0 up

bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 10.100.0.172

brctl addbr br0
#ip link set br0 mtu 1500
brctl addif br0 vxlan0
ip link set br0 up

ip addr add 169.254.1.2/30 dev br0
ip route add 192.168.0.0/24 via 169.254.1.1 dev br0


