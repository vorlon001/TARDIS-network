#!/usr/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}
vppctl show int
vppctl show plug | grep cp



vppctl create tap host-if-name vmvpp10
vppctl create tap host-if-name vmvpp20
vppctl set interface state tap2 up
vppctl set interface state tap3 up

vppctl set interface unnumbered tap2 use loop10
vppctl set interface unnumbered tap3 use loop10

vppctl set interface proxy-arp tap2 enable
vppctl set interface proxy-arp tap3 enable


vppctl ip route add 192.168.44.186/32 via tap2
vppctl ip route add 192.168.44.187/32 via tap3


vppctl create tap host-if-name vmvpp30
vppctl create tap host-if-name vmvpp40
vppctl set interface state tap4 up
vppctl set interface state tap5 up

vppctl set interface unnumbered tap4 use loop10
vppctl set interface unnumbered tap5 use loop10

vppctl set interface proxy-arp tap4 enable
vppctl set interface proxy-arp tap5 enable

vppctl ip route add 192.168.44.188/32 via tap4
vppctl ip route add 192.168.44.189/32 via tap5
