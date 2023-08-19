#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

vtysh -c "config t
ip forwarding"


vtysh -c "config t
interface enp1s0.200
 ip address 192.168.200.150/24
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
router bgp 65000
 bgp router-id 192.168.200.150
 bgp bestpath as-path multipath-relax
 neighbor cluster peer-group
 neighbor cluster remote-as 65000
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.200.170 peer-group fabric
 neighbor 192.168.200.180 peer-group fabric
 !
 address-family ipv4 unicast
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-reflector-client
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-reflector-client
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
!
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
