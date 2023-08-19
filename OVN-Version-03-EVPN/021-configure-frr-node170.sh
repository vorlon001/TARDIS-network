#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

vtysh -c "config t
ip forwarding"


vtysh -c "config t
interface enp1s0.200
 ip address 192.168.200.170/24
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
router bgp 65000
 bgp router-id 192.168.200.170
 bgp bestpath as-path multipath-relax
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.200.150 peer-group fabric
 !
 address-family ipv4 unicast
  redistribute connected
  redistribute static
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
 exit-address-family
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
"

vtysh -c "show run" >021-configure-frr-node170.config

vtysh -c "write"
