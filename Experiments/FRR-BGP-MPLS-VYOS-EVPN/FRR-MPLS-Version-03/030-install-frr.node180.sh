#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

vtysh -c "config t

interface enp1s0.33
 ip address 192.168.33.180/24
 mpls enable
quit
!
interface lo
 ip address 192.168.100.180/32
quit
!
router bgp 65000
 neighbor 192.168.100.172 remote-as 65000
 neighbor 192.168.100.172 update-source 192.168.100.180
 !
 address-family ipv4 vpn
  neighbor 192.168.100.172 activate
 exit-address-family
quit
!
router bgp 65000 vrf vrf1
 !
 address-family ipv4 unicast
  redistribute connected
  redistribute static
  label vpn export auto
  rd vpn export 1:100
  rt vpn both 10:100
  export vpn
  import vpn
 exit-address-family
quit
!
router ospf
 network 192.168.33.0/24 area 0
 network 192.168.100.0/24 area 0
quit
!
mpls ldp
 !
 address-family ipv4
  discovery transport-address 192.168.100.180
  !
  interface enp1s0.33
  quit
  !
 exit-address-family
 !
quit
"

vtysh -c "show run" >031-configure-frr-node180.config
cp /etc/netplan/50-cloud-init.yaml 031-config-netplan-node180.config
vtysh -c "write"

