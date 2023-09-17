#!/usr/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}
vppctl show int
vppctl show plug | grep cp

vppctl ikev2 profile add gw
vppctl ikev2 profile set gw auth shared-key-mic string 0123456789
vppctl ikev2 profile set gw id local ip4-addr 10.0.0.173
vppctl ikev2 profile set gw id remote ip4-addr 10.0.0.172
vppctl ikev2 profile set gw traffic-selector local ip-range 192.168.0.0 - 192.168.0.255 port-range 0 - 65535 protocol 0
vppctl ikev2 profile set gw traffic-selector remote ip-range 172.16.0.0 - 172.16.0.255 port-range 0 - 65535 protocol 0
vppctl ikev2 profile set gw responder GigabitEthernet3/3/0.803 10.0.0.173
vppctl ikev2 profile set gw ike-crypto-alg aes-cbc 256  ike-integ-alg sha1-96  ike-dh modp-2048
vppctl ikev2 profile set gw esp-crypto-alg aes-cbc 256  esp-integ-alg sha1-96  esp-dh ecp-256
vppctl ikev2 profile set gw sa-lifetime 3600 10 5 0

vppctl create ipip tunnel src 10.0.0.173 dst 10.0.0.172 instance 0 outer-table-id 0
vppctl set interface unnumbered ipip0 use GigabitEthernet3/3/0.803
vppctl ikev2 profile set gw tunnel ipip0
vppctl set interface state ipip0 up
vppctl ip route add 172.16.0.0/24 via ipip0

vppctl ikev2 initiate sa-init gw

#vpp# show ikev2 profile
#profile gw
#  auth-method shared-key-mic auth data 0123456789
#  local id-type ip4-addr data 10.0.0.173
#  remote id-type ip4-addr data 10.0.0.172
#  local traffic-selector addr 192.168.0.0 - 192.168.0.255 port 0 - 65535 protocol 0
#  remote traffic-selector addr 172.16.0.0 - 172.16.0.255 port 0 - 65535 protocol 0
#  protected tunnel ipip0
#  responder GigabitEthernet3/3/0.803 10.0.0.173
#  ike-crypto-alg aes-cbc 256 ike-integ-alg sha1-96 ike-dh modp-2048
#  esp-crypto-alg aes-cbc 256 esp-integ-alg sha1-96
#  lifetime 3600 jitter 10 handover 5 maxdata 0

