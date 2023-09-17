#!/usr/bin/bash


vtysh -c "config t
hostname node182
log syslog informational
!
interface enp1s0.200
exit
!
router bgp 65000
 no bgp ebgp-requires-policy
 neighbor 192.168.200.170 remote-as 65000
 neighbor 192.168.200.170 update-source enp1s0.200
 neighbor 192.168.200.171 remote-as 65000
 neighbor 192.168.200.171 update-source enp1s0.200
 neighbor 192.168.200.172 remote-as 65000
 neighbor 192.168.200.172 update-source enp1s0.200
 !
 address-family ipv4 unicast
  redistribute connected
  neighbor 192.168.200.170 next-hop-self
  neighbor 192.168.200.170 route-map fromAS65000 in
  neighbor 192.168.200.170 route-map toAS65000 out
  neighbor 192.168.200.171 next-hop-self
  neighbor 192.168.200.171 route-map fromAS65000 in
  neighbor 192.168.200.171 route-map toAS65000 out
  neighbor 192.168.200.172 next-hop-self
  neighbor 192.168.200.172 route-map fromAS65000 in
  neighbor 192.168.200.172 route-map toAS65000 out
 exit-address-family
exit
!
route-map fromAS65000 permit 65535
exit
!
route-map toAS65000 permit 65535
exit
!
"

vtysh -c "show run"
vtysh -c "write"

