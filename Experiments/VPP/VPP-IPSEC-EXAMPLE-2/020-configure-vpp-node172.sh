#!/usr/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}
vppctl show int
vppctl show plug | grep cp

# tenant 1

vppctl ikev2 profile add gw01
vppctl ikev2 profile set gw01 auth shared-key-mic string 0123456789
vppctl ikev2 profile set gw01 id local ip4-addr 10.0.0.172
vppctl ikev2 profile set gw01 id remote ip4-addr 10.0.0.173
vppctl ikev2 profile set gw01 traffic-selector local ip-range 172.16.0.0 - 172.16.0.255 port-range 0 - 65535 protocol 0
vppctl ikev2 profile set gw01 traffic-selector remote ip-range 192.168.0.0 - 192.168.0.255 port-range 0 - 65535 protocol 0

vppctl create ipip tunnel src 10.0.0.172 dst 10.0.0.173 instance 1 outer-table-id 0

vppctl ip table add 1
vppctl set interface ip table ipip1 1
vppctl ikev2 profile set gw01 tunnel ipip1
vppctl set interface ip address ipip1 169.254.0.1/32
vppctl set interface state ipip1 up
vppctl ip route add table 1 192.168.0.0/24 via ipip1

vppctl create bridge-domain 1 learn 1 forward 1 uu-flood 1 flood 1 arp-term 1

vppctl create vxlan tunnel src 10.100.0.172 dst 10.100.0.171 vni 1 instance 1
vppctl set interface l2 bridge vxlan_tunnel1 1 1
vppctl loopback create mac 1a:2b:3c:4d:5e:8f instance 1
vppctl set interface l2 bridge loop1 1 bvi
vppctl set interface ip table loop1 1
vppctl set interface state loop1 up
vppctl set interface ip address loop1 169.254.1.1/30

vppctl ip route add table 1 172.16.0.0/24 via 169.254.1.2 loop1


# tenant 2

# tenant 3

vppctl show ikev2 profile
vppctl show bridge-domain 1 detail

#vpp# show ikev2 profile
#profile gw01
#  auth-method shared-key-mic auth data 0123456789
#  local id-type ip4-addr data 10.0.0.172
#  remote id-type ip4-addr data 10.0.0.173
#  local traffic-selector addr 172.16.0.0 - 172.16.0.255 port 0 - 65535 protocol 0
#  remote traffic-selector addr 192.168.0.0 - 192.168.0.255 port 0 - 65535 protocol 0
#  protected tunnel ipip1
#  lifetime 0 jitter 0 handover 0 maxdata 0
