#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

vtysh -c "config t
ip forwarding"


vtysh -c "config t
interface bvi1 vrf dataplane
 ip address 192.168.203.180/24
!
router bgp 65000
 bgp router-id 192.168.200.180
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
router bgp 65000 vrf dataplane
 neighbor fabric_core peer-group
 neighbor fabric_core remote-as 65170
 neighbor fabric_dataplane peer-group
 neighbor fabric_dataplane remote-as 65000
 neighbor 192.168.203.150 peer-group fabric_core
 neighbor 192.168.203.150 update-source 192.168.203.180
 !
 address-family ipv4 unicast
  redistribute connected
  redistribute static
  neighbor fabric_core route-map IMPORT in
  neighbor fabric_core route-map EXPORT out
  neighbor fabric_core next-hop-self
  neighbor fabric_dataplane next-hop-self
  neighbor fabric_fabric soft-reconfiguration inbound
  neighbor fabric_dataplane soft-reconfiguration inbound
  neighbor fabric_dataplane route-map IMPORT in
  neighbor fabric_dataplane route-map EXPORT out
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

vtysh -c "show run" >072-configure-frr-node150.config

vtysh -c "write"
