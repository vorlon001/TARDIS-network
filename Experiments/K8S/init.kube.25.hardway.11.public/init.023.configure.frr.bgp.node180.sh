#!/usr/bin/bash


vtysh -c "config t
hostname node180
log syslog informational
!
interface enp1s0.200
exit
!
!
ip prefix-list No seq 5 permit 192.168.200.0/24
ip prefix-list No seq 10 permit 192.168.201.0/24
ip prefix-list No seq 15 permit 192.168.202.0/24
ip prefix-list No seq 20 permit 192.168.203.0/24
ip prefix-list Yes seq 5 permit any
!
!
route-map fromAS65000ipv4 permit 65535
exit
!
route-map redistributeAS65000 permit 65535
exit
!
route-map toAS65000ipv4 deny 100
 match ip address prefix-list No
exit
!
route-map toAS65000ipv4 permit 65535
 match ip address prefix-list Yes
exit
!
route-map toAS65000ipv4 permit 65535
 match ip address prefix-list Yes
exit
!
route-map toAS65000ipv6 deny 100
 match ipv6 address prefix-list No
exit
!
!
!
router bgp 65000
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 no bgp network import-check
 neighbor fabricv4 peer-group
 neighbor fabricv4 remote-as 65000
 neighbor fabricv4 update-source enp1s0.200
 neighbor 192.168.200.170 peer-group fabricv4
 neighbor 192.168.200.171 peer-group fabricv4
 neighbor 192.168.200.172 peer-group fabricv4
 !
 address-family ipv4 unicast
  redistribute connected route-map redistributeAS65000
  redistribute static route-map redistributeAS65000
  neighbor fabricv4 activate
  neighbor fabricv4 route-reflector-client
  neighbor fabricv4 next-hop-self
  neighbor fabricv4 soft-reconfiguration inbound
  neighbor fabricv4 route-map fromAS65000ipv4 in
  neighbor fabricv4 route-map toAS65000ipv4 out
 exit-address-family
 !
!
!
"

vtysh -c "show run"
vtysh -c "write"

