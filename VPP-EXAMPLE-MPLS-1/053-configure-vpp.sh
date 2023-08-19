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

#vppctl lcp default netns dataplane
vppctl lcp lcp-sync on
vppctl lcp lcp-auto-subint on
#vppctl ip table add 2

vppctl set interface state GigabitEthernet3/3/0 up
vppctl set interface mtu packet 1500 GigabitEthernet3/3/0

vppctl create sub GigabitEthernet3/3/0 800
vppctl set interface state GigabitEthernet3/3/0.800 up
vppctl set interface mtu packet 1500 GigabitEthernet3/3/0.800
#vppctl set interface ip table GigabitEthernet3/3/0.800 2

vppctl create bridge-domain 1
vppctl create loopback interface instance 1
vppctl lcp create loop1 host-if e0800

vppctl set interface ip address GigabitEthernet3/3/0.800 192.168.203.${NODEID}/24
vppctl set interface state GigabitEthernet3/3/0.800 up

vppctl set interface mac address GigabitEthernet3/3/0.800 de:ad:88:00:${NODEMACID}:01
ip link set dev e0800 address de:ad:88:00:${NODEMACID}:01

ip link show
ping 192.168.203.1 -c 8
ping 192.168.203.2 -c 8
ping 192.168.203.3 -c 8



