#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

sysctl -w net.vrf.strict_mode=1
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1


vtysh -c "config t
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
 ipv6 address 2001:db8:200:1234::181/64
!
interface lo
 ipv6 address 2001:db0:81:1234::1/128
!
interface enp1s0.800 vrf vrf1
 ip address 192.168.203.181/24
 ipv6 address 2001:db8:800:1234::181/64
exit
!
segment-routing
 srv6
  locators
   locator SRv6_Loc
    prefix 2001:db8:66:81::/64
   exit
   !
  exit
  !
 exit
 !
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
router bgp 65000
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 no bgp network import-check
 bgp log-neighbor-changes
 bgp graceful-restart
 neighbor fabricv6 peer-group
 neighbor fabricv6 remote-as 65000
 neighbor fabricv6 update-source enp1s0.200
 neighbor fabricv6 capability extended-nexthop
 neighbor 2001:db8:200:1234::182 peer-group fabricv6
 !
 segment-routing srv6
  locator SRv6_Loc
 exit
 !
 address-family ipv4 vpn
  neighbor fabricv6 activate
 exit-address-family
 !
 address-family ipv6 unicast
  network 2001:db8:0:181::/64
  network 2001:db0:81:1234::/64
  network 2001:db8:66:81::/64
  redistribute connected route-map redistributeAS65000
  redistribute static route-map redistributeAS65000
  neighbor fabricv6 activate
  neighbor fabricv6 next-hop-self
  neighbor fabricv6 soft-reconfiguration inbound
  neighbor fabricv6 route-map fromAS65000ipv6 in
  neighbor fabricv6 route-map toAS65000ipv6 out
 exit-address-family
 !
 address-family ipv6 vpn
  neighbor fabricv6 activate
 exit-address-family
!
!
router bgp 65000 vrf vrf1
 bgp router-id 192.168.200.181
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 bgp log-neighbor-changes
 bgp graceful-restart
 !
 address-family ipv4 unicast
  redistribute connected
  sid vpn export auto
  rd vpn export 65000:1010
  nexthop vpn export 2001:db0:81:1234::
  rt vpn both 65000:1010
  export vpn
  import vpn
 exit-address-family
 !
 address-family ipv6 unicast
  redistribute connected
  sid vpn export auto
  rd vpn export 65000:1010
  nexthop vpn export 2001:db0:81:1234::
  rt vpn both 65000:1010
  export vpn
  import vpn
 exit-address-family
!
!
ipv6 route 2001:db0:181:1234::/64 blackhole
!
"

vtysh -c "show run" >021-configure-frr-node181.config.v2
cp /etc/netplan/00-installer-config.yaml 021-config-netplan-node181.config.v2
vtysh -c "write"
