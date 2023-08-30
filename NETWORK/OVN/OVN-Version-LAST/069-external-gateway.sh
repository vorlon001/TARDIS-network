#!/usr/bin/bash

set -x

route add -net 12.0.0.0 netmask 255.255.255.0 gw 192.168.203.180

ip netns exec dataplane ping 12.0.0.66 -c 6
ip netns exec dataplane ping 12.0.0.11 -c 6
ip netns exec dataplane ping 12.0.0.12 -c 6
ip netns exec dataplane ping 12.0.0.13 -c 6

