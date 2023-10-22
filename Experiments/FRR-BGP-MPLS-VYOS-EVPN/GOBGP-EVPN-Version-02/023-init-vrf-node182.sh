#!/usr/bin/bash

set -x

#bridge fdb 
#tcpdump -ni enp1s0.200 port 4789

sudo ip link add vbdif10 type bridge
sudo ip link add vbdif20 type bridge
sudo ip link set vbdif10 up
sudo ip link set vbdif20 up
sudo ip link add vxlan20 type vxlan id 20 local 192.168.200.182 dstport 4789 nolearning
sudo ip link add vxlan10 type vxlan id 10 local 192.168.200.182 dstport 4789 nolearning
sudo ip link set vxlan10 up
sudo ip link set vxlan20 up
sudo ip link set vxlan20 master vbdif20
sudo ip link set vxlan10 master vbdif10
sudo ip address add 192.168.70.66/24 dev vbdif10
sudo ip address add 192.168.80.66/24 dev vbdif20

echo 1 > /proc/sys/net/ipv4/ip_forward

ip link set dev vbdif10 address 40:44:82:66:01:66
ip link set dev vbdif20 address 40:44:82:66:02:66
