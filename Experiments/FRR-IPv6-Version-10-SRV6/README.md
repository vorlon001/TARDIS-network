
```shell

array=( 180 181 182 )
for i in "${array[@]}"
do
  scp * root@192.168.200.${i}:.
done


```



```shell

#node170
route add -net 192.168.203.0/24 gw 192.168.202.180
ip -6 route add 2001:db8:800:1234::/64 via 2001:db8:600:1234::180

#node171
route add -net 192.168.202.0/24 gw 192.168.203.181
ip -6 route add 2001:db8:600:1234::/64 via 2001:db8:800:1234::181


tcpdump -ni enp1s0.200 "icmp6 && ip6[40] == 128"
tcpdump -ni enp1s0.200 | grep RT6

#node170
ping 2001:db8:800:1234::171
ping 192.168.203.171


$IPP netns exec r1 sysctl -w net.ipv4.ip_forward=1
$IPP netns exec r1 sysctl -w net.ipv4.conf.all.forwarding=1
$IPP netns exec r1 sysctl -w net.ipv6.conf.all.forwarding=1
$IPP netns exec r1 sysctl -w net.ipv6.conf.all.seg6_enabled=1
# disable also rp_filter on the receiving decap interface that will forward the
# packet to the right destination (through the nexthop)
$IPP netns exec r1 sysctl -w net.ipv4.conf.all.rp_filter=0
#$IPP netns exec r1 sysctl -w net.ipv4.conf.veth3.rp_filter=0
$IPP netns exec r1 sysctl -w net.ipv4.conf.veth4.rp_filter=0
# Using proxy_arp we can simplify the configuration of clients
$IPP netns exec r1 sysctl -w net.ipv4.conf.all.proxy_arp=1
$IPP netns exec r1 sysctl -w net.ipv4.conf.veth4.proxy_arp=1

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1
sysctl -w net.ipv6.conf.all.seg6_require_hmac=0

sysctl -w net.vrf.strict_mode=1
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv6.seg6_flowlabel=1
sysctl -w net.ipv6.conf.all.seg6_enabled=1

node180# show segment-routing srv6 locator
Locator:
Name                 ID      Prefix                   Status
-------------------- ------- ------------------------ -------
SRv6_Loc                   1 2001:db0:80:1234::/64    Up

node180# show bgp segment-routing srv6
locator_name: SRv6_Loc
locator_chunks:
- 2001:db0:80:1234::/64
functions:
- sid: 2001:db0:80:1234:100::
  locator: SRv6_Loc
- sid: 2001:db0:80:1234:200::
  locator: SRv6_Loc
bgps:
- name: default
  vpn_policy[AFI_IP].tovpn_sid: none
  vpn_policy[AFI_IP6].tovpn_sid: none
- name: vrf1
  vpn_policy[AFI_IP].tovpn_sid: 2001:db0:80:1234:100::
  vpn_policy[AFI_IP6].tovpn_sid: 2001:db0:80:1234:200::


node181# show segment-routing srv6 locator
Locator:
Name                 ID      Prefix                   Status
-------------------- ------- ------------------------ -------
SRv6_Loc                   1 2001:db0:81:1234::/64    Up

node181# show bgp segment-routing srv6
locator_name: SRv6_Loc
locator_chunks:
- 2001:db0:81:1234::/64
functions:
- sid: 2001:db0:81:1234:100::
  locator: SRv6_Loc
- sid: 2001:db0:81:1234:200::
  locator: SRv6_Loc
bgps:
- name: default
  vpn_policy[AFI_IP].tovpn_sid: none
  vpn_policy[AFI_IP6].tovpn_sid: none
- name: vrf1
  vpn_policy[AFI_IP].tovpn_sid: 2001:db0:81:1234:100::
  vpn_policy[AFI_IP6].tovpn_sid: 2001:db0:81:1234:200::
node181# show segment-routing srv6 locator
Locator:
Name                 ID      Prefix                   Status
-------------------- ------- ------------------------ -------
SRv6_Loc                   1 2001:db0:81:1234::/64    Up


root@node181:~# ip -6 r s
::1 dev lo proto kernel metric 256 pref medium
2001:db0:80:1234::1 nhid 38 via 2001:db8:200:1234::180 dev enp1s0.200 proto bgp metric 20 pref medium
2001:db0:80:1234::/64 nhid 38 via 2001:db8:200:1234::180 dev enp1s0.200 proto bgp metric 20 pref medium
2001:db0:81:1234::1 dev lo proto kernel metric 256 pref medium
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
2001:db0:81:1234:100:: nhid 13  encap seg6local action End.DT4 vrftable 10 dev vrf1 proto bgp metric 20 pref medium
2001:db0:81:1234:200:: nhid 14  encap seg6local action End.DT6 table 10 dev vrf1 proto bgp metric 20 pref medium
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2001:db0:82:1234::1 nhid 34 via fe80::f816:3eff:fe89:f5f5 dev enp1s0.200 proto bgp metric 20 pref medium
2001:db0:180:1234::/64 nhid 38 via 2001:db8:200:1234::180 dev enp1s0.200 proto bgp metric 20 pref medium
blackhole 2001:db0:181:1234::/64 dev lo proto static metric 20 pref medium
2001:db0:182:1234::/64 nhid 34 via fe80::f816:3eff:fe89:f5f5 dev enp1s0.200 proto bgp metric 20 pref medium
2001:db8:0:180::/64 nhid 38 via 2001:db8:200:1234::180 dev enp1s0.200 proto bgp metric 20 pref medium
2001:db8:200:1234::/64 dev enp1s0.200 proto kernel metric 256 pref medium
2001:db8:200:1234::/64 dev enp1s0.200 proto ra metric 1024 expires 2591999sec pref medium
2001:db8:400:1234::/64 dev enp1s0.400 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0 proto kernel metric 256 pref medium
fe80::/64 dev enp2s0 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0.200 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0.400 proto kernel metric 256 pref medium
default proto ra metric 1024 expires 29sec pref medium
        nexthop via fe80::f816:3eff:fea1:e8fe dev enp1s0.200 weight 1
        nexthop via fe80::f816:3eff:fe89:f5f5 dev enp1s0.200 weight 1
root@node181:~# ip route add 2001:db0:81:1234:100::/128 encap seg6local action End.DT4 nh4 0.0.0.0 table 10  dev enp1s0.800
RTNETLINK answers: Invalid argument
root@node181:~# ip -6 r s^C


root@node181:~# ip route list table  10
192.168.202.0/24 nhid 44  encap seg6 mode encap segs 1 [ 2001:db0:80:1234:100:: ] via inet6 2001:db8:200:1234::180 dev enp1s0.200 proto bgp metric 20
192.168.203.0/24 dev enp1s0.800 proto kernel scope link src 192.168.203.181
local 192.168.203.181 dev enp1s0.800 proto kernel scope host src 192.168.203.181
broadcast 192.168.203.255 dev enp1s0.800 proto kernel scope link src 192.168.203.181

root@node181:~# ip -6 route list table  10
2001:db8:600:1234::/64 nhid 42  encap seg6 mode encap segs 1 [ 2001:db0:80:1234:200:: ] via 2001:db8:200:1234::180 dev enp1s0.200 proto bgp metric 20 pref medium
anycast 2001:db8:800:1234:: dev enp1s0.800 proto kernel metric 0 pref medium
local 2001:db8:800:1234::181 dev enp1s0.800 proto kernel metric 0 pref medium
2001:db8:800:1234::/64 dev enp1s0.800 proto kernel metric 256 pref medium
anycast fe80:: dev enp1s0.800 proto kernel metric 0 pref medium
local fe80::f816:3eff:fee9:ecd8 dev enp1s0.800 proto kernel metric 0 pref medium
fe80::/64 dev enp1s0.800 proto kernel metric 256 pref medium
multicast ff00::/8 dev enp1s0.800 proto kernel metric 256 pref medium


```

















```shell
ip vrf exec vrf1 ping 192.168.202.171


root@node170:~# ip route show table 20
default via 192.168.230.180 dev vrf2 proto static onlink
192.168.230.0/24 dev enp1s0.800 proto kernel scope link src 192.168.230.170
local 192.168.230.170 dev enp1s0.800 proto kernel scope host src 192.168.230.170
broadcast 192.168.230.255 dev enp1s0.800 proto kernel scope link src 192.168.230.170

root@node170:~# ip route show table 10
default via 192.168.202.180 dev vrf1 proto static onlink
192.168.202.0/24 dev enp1s0.600 proto kernel scope link src 192.168.202.170
local 192.168.202.170 dev enp1s0.600 proto kernel scope host src 192.168.202.170
broadcast 192.168.202.255 dev enp1s0.600 proto kernel scope link src 192.168.202.170
root@node170:~#


root@node170:~# ip -6 r s
::1 dev lo proto kernel metric 256 pref medium
2001:db8:200:1234::/64 dev enp1s0.200 proto kernel metric 256 pref medium
2001:db8:200:1234::/64 dev enp1s0.200 proto ra metric 1024 expires 2591991sec pref medium
2001:db8:400:1234::/64 dev enp1s0.400 proto kernel metric 256 pref medium
2001:db8:600:1234::/64 dev enp1s0.600 proto kernel metric 256 pref medium
2001:db8:800:1234::/64 dev enp1s0.800 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0 proto kernel metric 256 pref medium
fe80::/64 dev enp2s0 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0.200 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0.600 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0.400 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0.800 proto kernel metric 256 pref medium
default dev enp1s0.800 metric 1 pref medium
default proto ra metric 1024 expires 21sec pref medium
        nexthop via fe80::f816:3eff:fe79:5444 dev enp1s0.200 weight 1
        nexthop via fe80::f816:3eff:fe02:8d53 dev enp1s0.200 weight 1
        nexthop via fe80::f816:3eff:fe47:1429 dev enp1s0.200 weight 1

ip -6 route add default dev enp1s0.800 metric 1
ip -6 route add default via 2001:db8:800:1234::180

net.ipv6.conf.enp1s0/200.disable_ipv6=1
net.ipv6.conf.enp1s0/200.disable_ipv6 = 1


sysctl net.ipv6.conf.enp1s0/200.disable_ipv6=1
sysctl net.ipv6.conf.enp1s0/600.disable_ipv6=1
ip -6 route add default via 2001:db8:801:1234::181

net.ipv6.conf.enp1s0/600.disable_ipv6 = 1
root@node170:~# ip -6 r s
::1 dev lo proto kernel metric 256 pref medium
2001:db8:800:1234::/64 dev enp1s0.800 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0 proto kernel metric 256 pref medium
fe80::/64 dev enp2s0 proto kernel metric 256 pref medium
fe80::/64 dev enp1s0.800 proto kernel metric 256 pref medium


ovs-appctl fdb/show sw1
ovs-vsctl list interface | grep 'name\|ofport' | grep -v 'status\|ofport_request'

        enp1s0.600:
            addresses:
            - 2001:db8:600:1234::180/64
            dhcp4: false
            dhcp6: false
            id: 600
            link: enp1s0
        enp1s0.800:
            addresses:
            - 2001:db8:800:1234::180/64
            dhcp4: false
            dhcp6: false
            id: 800
            link: enp1s0

node180# show ip route vrf vrf1
node180# show ipv6 route vrf vrf1


interface enp1s0.600 vrf vrf1
 ipv6 address 2001:db8:600:1234::180/64
exit
!
interface enp1s0.800 vrf vrf1
 ipv6 address 2001:db8:800:1234::180/64
exit
!
!
segment-routing
 srv6
  locators
   locator SRv6_Loc
    prefix 2001:db8:0:1::/64
   exit
   !
  exit
  !
 exit
 !
!
router bgp 65000
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 no bgp network import-check
 neighbor fabricv6 peer-group
 neighbor fabricv6 remote-as 65000
 neighbor fabricv6 update-source enp1s0.200
 neighbor fabricv6 remote-as 192.168.200.180
 neighbor fabricv6 tcp-mss 1200
 neighbor fabricv6 capability extended-nexthop
 neighbor 2001:db8:200:1234::182 peer-group fabricv6
 neighbor 001:db8:200:1234::182 tcp-mss 0 
 !
 address-family ipv6 unicast
  network 2001:db8:0:1::/64
  redistribute connected route-map redistributeAS65000
  redistribute static route-map redistributeAS65000
  neighbor fabricv6 activate
  neighbor fabricv6 route-reflector-client
  neighbor fabricv6 next-hop-self
  neighbor fabricv6 soft-reconfiguration inbound
  neighbor fabricv6 route-map fromAS65000ipv6 in
  neighbor fabricv6 route-map toAS65000ipv6 out
 exit-address-family
 !
 segment-routing srv6
  locator SRv6_Loc
 exit
 !
 address-family ipv4 vpn
  neighbor fabricv6 activate
 exit-address-family
 !
 address-family ipv6 vpn
  neighbor fabricv6 activate
 exit-address-family
exit
!
router bgp 65000 vrf vrf1
 bgp router-id 192.168.200.180
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 !
 address-family ipv4 unicast
  redistribute connected
  sid vpn export auto
  rd vpn export 64512:142
  nexthop vpn export 2001:db8:ffff:1::2
  rt vpn both 64512:142
  export vpn
  import vpn
 exit-address-family
 !
 address-family ipv6 unicast
  redistribute connected
  sid vpn export auto
  rd vpn export 64512:162
  rt vpn both 64512:162
  export vpn
  import vpn
 exit-address-family
exit
!


node180# show bgp segment-routing srv6
locator_name: SRv6_Loc
locator_chunks:
- 2001:db8:0:180::/64
functions:
- sid: 2001:db8:0:180:100::
  locator: SRv6_Loc
- sid: 2001:db8:0:180:200::
  locator: SRv6_Loc
bgps:
- name: default
  vpn_policy[AFI_IP].tovpn_sid: none
  vpn_policy[AFI_IP6].tovpn_sid: none
- name: vrf1
  vpn_policy[AFI_IP].tovpn_sid: 2001:db8:0:180:100::
  vpn_policy[AFI_IP6].tovpn_sid: 2001:db8:0:180:200::







cat >> /etc/iproute2/rt_tables.d/vrf.conf <<EOF
10 vrf1
EOF

root@node180:~# cat /etc/netplan/00-installer-config.yaml
.........
    vrfs:
      vrf1:
        table: 10
        interfaces:
          - enp1s0.800
        routes:
          - to: default
            via: 192.168.203.1
        routing-policy:
          - from: 192.168.203.180



            link: enp1s0
        enp1s0.600:
            addresses:
            - 2001:db8:600:1234::/64
            dhcp4: false
            dhcp6: false
            id: 600
            link: enp1s0
        enp1s0.800:
            addresses:
            - 2001:db8:800:1234::/64
            dhcp4: false
            dhcp6: false



router bgp 65000 vrf vrf1
 address-family ipv6 unicast
  redistribute connected
  sid vpn export auto
  rd vpn export 65000:1010
  nexthop vpn export 2001:db8:200:1234::180
  rt vpn both 65000:1010
  export vpn
  import vpn
 exit-address-family

router bgp 65000 vrf vrf1
 address-family ipv6 unicast
  redistribute connected
  sid vpn export auto
  rd vpn export 65000:1010
  nexthop vpn export 2001:db8:200:1234::181
  rt vpn both 65000:1010
  export vpn
  import vpn
 exit-address-family


 router bgp 65000 vrf vrf1
 bgp router-id 192.168.200.180
 no bgp ebgp-requires-policy
 no bgp default ipv4-unicast
 !
 address-family ipv4 unicast
  redistribute connected
  sid vpn export auto
  rd vpn export 65000:1010
  nexthop vpn export 2001:db0:81:1234::1
  rt vpn both 65000:1010
  export vpn
  import vpn
 exit-address-family
 !
 address-family ipv6 unicast
  redistribute connected
  sid vpn export auto
  rd vpn export 65000:1010
  nexthop vpn export 2001:db0:81:1234::1
  rt vpn both 65000:1010
  export vpn
  import vpn
 exit-address-family
```
