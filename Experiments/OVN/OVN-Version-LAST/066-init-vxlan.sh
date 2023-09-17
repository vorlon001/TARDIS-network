#!/usr/bin/bash

set -x

vppctl create bridge-domain 13 learn 1 forward 1 uu-flood 1 flood 1 arp-term 0
vppctl show bridge-domain 13 detail

vppctl create vxlan tunnel src 192.168.203.180 dst 192.168.203.170 vni 1
vppctl create vxlan tunnel src 192.168.203.180 dst 192.168.203.171 vni 1
vppctl create vxlan tunnel src 192.168.203.180 dst 192.168.203.172 vni 1
vppctl set interface l2 bridge vxlan_tunnel0 13 1
vppctl set interface l2 bridge vxlan_tunnel1 13 1
vppctl set interface l2 bridge vxlan_tunnel2 13 1

vppctl show vxlan tunnel
vppctl show bridge-domain 13 detail


vppctl show interface address
vppctl show interface


