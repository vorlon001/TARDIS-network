#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}


vppctl create bridge-domain 13 learn 1 forward 1 uu-flood 1 flood 1 arp-term 0
vppctl show bridge-domain 13 detail
vppctl create vxlan tunnel src 192.168.203.131 dst 192.168.203.130 vni 666
vppctl set interface l2 bridge vxlan_tunnel0 13 1
vppctl show vxlan tunnel
vppctl show bridge-domain 13 detail

vppctl set interface ip table vxlan_tunnel0 2


vppctl create loopback interface instance 10
vppctl lcp create loop10 host-if bvi_vxlan

vppctl set interface ip table loop10 2

vppctl set interface ip address loop10 192.168.100.${NODEID}/24
vppctl set interface l2 bridge loop10 13 bvi
vppctl set interface mac address loop10 00:00:${NODEMACID}:44:44:44
vppctl set interface state loop10 up

ifconfig bvi_vxlan up
ip link set dev bvi_vxlan address 00:00:${NODEMACID}:44:44:44


vppctl set bridge-domain arp entry 13 192.168.100.130 00:00:80:44:44:44
vppctl set bridge-domain arp entry 13 192.168.100.131 00:00:81:44:44:44

