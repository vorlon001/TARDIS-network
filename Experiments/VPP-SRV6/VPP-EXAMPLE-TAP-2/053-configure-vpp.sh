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
vppctl ip table add 2


vppctl set interface state GigabitEthernet3/3/0 up
vppctl set interface mtu packet 1500 GigabitEthernet3/3/0

vppctl create sub GigabitEthernet3/3/0  800
vppctl set interface state GigabitEthernet3/3/0.800 up
vppctl set interface mtu packet 1500 GigabitEthernet3/3/0.800
vppctl set interface ip address GigabitEthernet3/3/0.800 192.168.203.130/24
vppctl ip route add 192.168.203.0/24 via  GigabitEthernet3/3/0.800


vppctl create loopback interface instance 10
vppctl lcp create loop10
vppctl set interface state loop10 up
vppctl set interface ip address loop10 192.168.44.1/24

vppctl create tap host-if-name vpp10
vppctl create tap host-if-name vpp20
vppctl set interface state tap0 up
vppctl set interface state tap1 up


ip netns add vpp10
ip netns add vpp20

ip link set dev vpp10 netns vpp10
ip link set dev vpp20 netns vpp20

ip netns exec vpp10 ip link set vpp10 up
ip netns exec vpp20 ip link set vpp20 up

ip netns exec vpp10 ip addr add 192.168.44.21/32 dev vpp10
ip netns exec vpp20 ip addr add 192.168.44.22/32 dev vpp20
ip netns exec vpp10 route add default dev vpp10
ip netns exec vpp20 route add default dev vpp20


ip netns exec vpp10 ip route add default vpp10
ip netns exec vpp20 ip route add default vpp20


# root@node1:~# route add -net 192.168.44.0/24 gw 192.168.203.130

#  553  route del default dev vpp10
#  554  route add default gw 192.168.44.41

vppctl set interface unnumbered tap0 use loop10
vppctl set interface unnumbered tap1 use loop10

vppctl ip route add 192.168.44.1/32 via loop10
vppctl ip route add 192.168.44.21/32 via tap0
vppctl ip route add 192.168.44.22/32 via tap1
vppctl ip route add 192.168.203.0/24 via GigabitEthernet3/3/0.800

vppctl set arp proxy start 0.0.0.0 end 255.255.255.255
vppctl set interface proxy-arp GigabitEthernet3/3/0.800 enable
vppctl set interface proxy-arp loop10 enable
vppctl set interface proxy-arp tap0 enable
vppctl set interface proxy-arp tap1 enable


#  247  arp -i vpp20 -s 192.168.45.22 02:fe:2d:0d:14:2e
#  248  arp -i vpp20 -s 192.168.203.1 02:fe:2d:0d:14:2e
#  249  arp -n
#  250  history


# vppctl set interface proxy-arp GigabitEthernet3/3/0.800 enable
# vppctl set interface proxy-arp loop10 enable
# vppctl set interface proxy-arp tap0 enable
# vppctl set interface proxy-arp tap1 enable
# vppctl set ip neighbor tap1 192.168.44.22 02:fe:2f:03:94:14

