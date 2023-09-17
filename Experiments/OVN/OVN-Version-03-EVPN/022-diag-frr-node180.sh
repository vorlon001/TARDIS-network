#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive


vtysh -c "show ip bgp summary"
vtysh -c "show ip bgp "
vtysh -c "show ip bgp l2vpn evpn"
vtysh -c "show ip bgp l2vpn evpn neighbors 192.168.200.150 advertised-routes"
