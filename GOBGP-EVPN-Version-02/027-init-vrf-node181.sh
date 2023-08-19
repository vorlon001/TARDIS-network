#!/usr/bin/bash

set -x
ip link add ve_A type veth peer name ve_B
ip link set ve_A up
ip link set ve_B up

ip netns add zone10
ip link set ve_A netns zone10
ip netns exec zone10 ifconfig ve_A up
ip netns exec zone10 ip link add bvi20 type bridge
ip netns exec zone10 ifconfig bvi20 up
ip netns exec zone10 ip link show

ip netns add zone20
ip link set ve_B netns zone20
ip netns exec zone20 ifconfig ve_B up
ip netns exec zone20 ip link show

ip netns exec zone10 ip link set ve_A master bvi20

ip netns exec zone10 ip link set ve_A up
ip netns exec zone20 ip link set ve_B up


ip link add vxlan10 type vxlan id 10 local 192.168.200.180 dstport 4789 nolearning
ip link set vxlan10 netns zone10

ip netns exec zone10 ip link set vxlan10 master bvi20
ip netns exec zone10 ip link set vxlan10 up

ip netns exec zone10 ip link set bvi20 address 40:44:80:01:66:03
ip netns exec zone20 ip link set ve_B address 40:44:80:02:66:03
#ip netns exec zone10 ifconfig bvi20 192.168.80.180/24
ip netns exec zone20 ifconfig ve_B 192.168.80.180/24
ip netns exec zone20 ifconfig bvi20 192.168.80.80/24

ip netns exec zone10 ip -4 neigh del 192.168.80.66 lladdr 40:44:82:66:02:66 dev bvi20
ip netns exec zone10 ip -4 neigh add  192.168.80.66 lladdr 40:44:82:66:02:66 dev bvi20

ip netns exec zone10 bridge fdb append 00:00:00:00:00:00 dev vxlan10 dst 192.168.200.182


gobgp global rib -a evpn add macadv 40:44:80:02:66:03 192.168.80.180 esi 0 etag 0 label 10 rd 65000:10 rt 65000:10 encap vxlan
gobgp global rib -a evpn add multicast 192.168.80.180 etag 0 rd 192.168.200.182:2  encap vxlan
gobgp global rib -a evpn add macadv 40:44:80:01:66:03 192.168.80.80 esi 0 etag 0 label 10 rd 65000:10 rt 65000:10 encap vxlan
gobgp global rib -a evpn add multicast 192.168.80.80 etag 0 rd 192.168.200.182:2  encap vxlan
gobgp global rib -a evpn
