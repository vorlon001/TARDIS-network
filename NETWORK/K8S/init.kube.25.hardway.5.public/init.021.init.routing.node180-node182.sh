#!/usr/bin/bash


route add -net 10.96.1.0/24 gw 192.168.203.170
route add -net 10.96.2.0/24 gw 192.168.203.171
route add -net 10.96.3.0/24 gw 192.168.203.172

route add -net 10.96.128.0/17 gw 192.168.203.170
route add -net 10.96.128.0/17 gw 192.168.203.171
route add -net 10.96.128.0/17 gw 192.168.203.172

echo "need change netplan config"
