#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive


vtysh -c "show run"

vtysh -c "config t
ip forwarding"

vtysh -c "config t
ip route 13.0.0.0/24 blackhole
!
interface enp1s0.800
 ip address 192.168.203.150/24
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
router bgp 65170
 bgp router-id 192.168.200.180
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.203.180 peer-group fabric
 neighbor 192.168.203.180 update-source 192.168.203.170
 !
 address-family ipv4 unicast
  redistribute connected
  redistribute static
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  neighbor fabric next-hop-self
  neighbor fabric soft-reconfiguration inbound
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
"

vtysh -c "show run"

vtysh -c "write"


vtysh -c "show run" >082-configure-frr-node150.config
