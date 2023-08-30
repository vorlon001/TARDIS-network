#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

sysctl -w net.vrf.strict_mode=1
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1


vtysh -c "config t
!
log stdout notifications
log monitor notifications
log commands
!
!debug bgp neighbor-events
!debug bgp zebra
!debug bgp vnc verbose
!debug bgp update-groups
!debug bgp updates in
!debug bgp updates out
!
ip forwarding
ipv6 forwarding"


vtysh -c "config t
interface enp1s0.200
 ipv6 address 2001:db8:200:1234::182/64
!
interface lo
 ipv6 address 2001:db0:82:1234::1/128
!
!
ipv6 prefix-list No seq 5 permit 2001:db8:200:1234::/64
ipv6 prefix-list No seq 10 permit 2001:db8:400:1234::/64
ipv6 prefix-list No seq 15 permit 2001:db8:600:1234::/64
ipv6 prefix-list No seq 20 permit 2001:db8:800:1234::/64
ipv6 prefix-list Yes seq 5 permit any
!
!
route-map fromAS65000ipv6 permit 65535
exit
!
!
route-map redistributeAS65000 permit 65535
exit
!
!
route-map toAS65000ipv6 deny 100
 match ipv6 address prefix-list No
exit
!
!
route-map toAS65000ipv6 permit 65535
 match ipv6 address prefix-list Yes
exit
!
!
segment-routing
 srv6
  locators
   locator SRv6_Loc
    prefix 2001:db8:66:82::/64
   exit
   !
  exit
  !
 exit
 !
!
!
router bgp 65000
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 no bgp network import-check
 neighbor fabricv6 peer-group
 neighbor fabricv6 remote-as 65000
 neighbor fabricv6 tcp-mss 1200
 neighbor fabricv6 update-source enp1s0.200
 neighbor fabricv6 capability extended-nexthop
 neighbor 2001:db8:200:1234::180 peer-group fabricv6
 neighbor 2001:db8:200:1234::181 peer-group fabricv6
 !
 segment-routing srv6
  locator SRv6_Loc
 exit
 !
 address-family ipv4 vpn
  neighbor fabricv6 activate
  neighbor 2001:db8:200:1234::180 route-reflector-client
  neighbor 2001:db8:200:1234::181 route-reflector-client
 exit-address-family
 !
 address-family ipv6 unicast
  network 2001:db8:66:82::/64
  redistribute connected route-map redistributeAS65000
  redistribute static route-map redistributeAS65000
  neighbor fabricv6 activate
  neighbor fabricv6 route-reflector-client
  neighbor fabricv6 next-hop-self
  neighbor fabricv6 soft-reconfiguration inbound
  neighbor fabricv6 route-map fromAS65000ipv6 in
  neighbor fabricv6 route-map toAS65000ipv6 out
  neighbor 2001:db8:200:1234::180 route-reflector-client
  neighbor 2001:db8:200:1234::181 route-reflector-client
 exit-address-family
 !
 address-family ipv6 vpn
  neighbor fabricv6 activate
  neighbor 2001:db8:200:1234::180 route-reflector-client
  neighbor 2001:db8:200:1234::181 route-reflector-client
 exit-address-family
!
!
ipv6 route 2001:db0:182:1234::/64 blackhole
!
exit
"

vtysh -c "show run" >021-configure-frr-node182.config
cp /etc/netplan/00-installer-config.yaml 021-config-netplan-node182.config
vtysh -c "write"
