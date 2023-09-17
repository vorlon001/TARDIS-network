#!/usr/bin/bash


route add -net 10.96.1.0/24 gw 192.168.203.170
route add -net 10.96.2.0/24 gw 192.168.203.171
route add -net 10.96.3.0/24 gw 192.168.203.172

route add -net 10.96.128.0/17 gw 192.168.203.170
route add -net 10.96.128.0/17 gw 192.168.203.171
route add -net 10.96.128.0/17 gw 192.168.203.172


route add -net 10.96.68.128/26 gw 192.168.203.172
route add -net 10.96.70.0/26 gw 192.168.203.171
route add -net 10.96.76.192/26 gw 192.168.203.170
