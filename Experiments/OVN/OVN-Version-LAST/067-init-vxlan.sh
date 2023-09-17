#!/usr/bin/bash

set -x

vppctl create loopback interface instance 10
vppctl lcp create loop10 host-if bvi_vxlan
vppctl set interface ip address loop10 12.0.0.66/24
vppctl set interface l2 bridge loop10 13 bvi
vppctl set interface mac address loop10 00:00:00:44:44:44
vppctl set interface state loop10 up

ip netns exec dataplane ifconfig bvi_vxlan up
