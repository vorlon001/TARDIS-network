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

vppctl lcp lcp-sync on
vppctl lcp lcp-auto-subint on

vppctl set interface state GigabitEthernet3/3/0 up
vppctl set interface mtu packet 1500 GigabitEthernet3/3/0


vppctl create sub GigabitEthernet3/3/0  800
vppctl set interface state GigabitEthernet3/3/0.800 up
vppctl set interface mtu packet 1500 GigabitEthernet3/3/0.800
vppctl set interface ip address GigabitEthernet3/3/0.800 192.168.203.172/24
vppctl ip route add 192.168.203.0/24 via  GigabitEthernet3/3/0.800

vppctl create sub GigabitEthernet3/3/0  802
vppctl set interface state GigabitEthernet3/3/0.802 up
vppctl set interface mtu packet 1500 GigabitEthernet3/3/0.802
vppctl set interface ip address GigabitEthernet3/3/0.802 10.100.0.172/24
vppctl ip route add 10.100.0.0/24 via  GigabitEthernet3/3/0.802


vppctl create sub GigabitEthernet3/3/0  803
vppctl set interface state GigabitEthernet3/3/0.803 up
vppctl set interface mtu packet 1500 GigabitEthernet3/3/0.803
vppctl set interface ip address GigabitEthernet3/3/0.803 10.0.0.172/24
vppctl ip route add 10.0.0.0/24 via  GigabitEthernet3/3/0.803

vppctl lcp create GigabitEthernet3/3/0 host-if ge0
vppctl lcp create GigabitEthernet3/3/0.800 host-if ge800
vppctl lcp create GigabitEthernet3/3/0.802 host-if ge802
vppctl lcp create GigabitEthernet3/3/0.803 host-if ge803

ifconfig ge800 192.168.203.172/24 up
ifconfig ge802 10.100.0.172/24 up
ifconfig ge803 10.0.0.172/24 up


ip link show
ping 192.168.203.1 -c 8
ping 192.168.203.2 -c 8
ping 192.168.203.3 -c 8



