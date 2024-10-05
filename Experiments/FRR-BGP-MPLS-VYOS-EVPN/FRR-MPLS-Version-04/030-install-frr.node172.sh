#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

vtysh -c "config t

interface enp1s0.32
 ip address 192.168.32.172/24
 mpls enable
quit
!
interface enp1s0.33
 ip address 192.168.33.172/24
 mpls enable
quit
!
interface lo
 ip address 192.168.100.172/32
quit
!
router bgp 65000
 neighbor 192.168.100.171 remote-as 65000
 neighbor 192.168.100.171 update-source 192.168.100.172
 neighbor 192.168.100.180 remote-as 65000
 neighbor 192.168.100.180 update-source 192.168.100.172
 !
 address-family ipv4 vpn
  neighbor 192.168.100.171 activate
  neighbor 192.168.100.171 route-reflector-client
  neighbor 192.168.100.180 activate
  neighbor 192.168.100.180 route-reflector-client
 exit-address-family
quit
!
router ospf
 network 192.168.32.0/24 area 0
 network 192.168.33.0/24 area 0
 network 192.168.100.0/24 area 0
quit
!
mpls ldp
 !
 address-family ipv4
  discovery transport-address 192.168.100.172
  !
  interface enp1s0.32
  quit
  !
  interface enp1s0.33
  quit
  !
 exit-address-family
 !
exit
"

vtysh -c "show run" >031-configure-frr-node172.config
cp /etc/netplan/50-cloud-init.yaml 031-config-netplan-node172.config
vtysh -c "write"
