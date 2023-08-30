#!/usr/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}
vppctl show int
vppctl show plug | grep cp

vppctl set logging class linux-cp rate-limit 1000 level warn syslog-level notice

vppctl lcp default netns dataplane
vppctl lcp lcp-sync on
vppctl lcp lcp-auto-subint on


ip link add name veth_vpp1 type veth peer name vpp1
ip link set dev vpp1 up
ip link set dev veth_vpp1 up

ip addr add 12.0.0.${NODEMACID}/24 dev veth_vpp1


vppctl create host-interface name vpp1
vppctl set int state host-vpp1 up
vppctl set int ip address host-vpp1 12.0.0.${NODEID}/24

vppctl lcp create host-vpp1 host-if hostvpp1

ping 12.0.0.${NODEMACID} -c 8
ping 12.0.0.${NODEID} -c 8
