
![](https://programmer.group/images/article/005d3759312e4aa2f43a0ed183cd6a83.jpg)


original: https://programmer.group/frr-learning-day-9-complete-data-center-network-model.html


### VM: debian 12
```
[node140]-----(vlan400)----------[node141]--------(vlan800)----------[node143]
                                    |
                                    |
                                (vlan600)
                                    |
                                    |
                                 [node142]

```

```

set -x

export DEBIAN_FRONTEND=noninteractive


curl –s https://deb.frrouting.org/frr/keys.gpg | sudo tee /usr/share/keyrings/frrouting.gpg > /dev/null
FRRVER="frr-stable"
echo deb '[signed-by=/usr/share/keyrings/frrouting.gpg]' https://deb.frrouting.org/frr \
     $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list

# update and install FRR
apt update && apt install frr frr-pythontools -y

apt -y update && apt -y install frr frr-pythontools

sed -i "s/^bgpd=no/bgpd=yes/" /etc/frr/daemons
sed -i "s/^ospfd=no/ospfd=yes/" /etc/frr/daemons
sed -i "s/^ldpd=no/ldpd=yes/" /etc/frr/daemons
sed -i "s/^ospfd=no/ospfd=yes/" /etc/frr/daemons
sed -i "s/^bfdd=no/bfdd=yes/" /etc/frr/daemons
sed -i "s/^vrrpd=no/vrrpd=yes/" /etc/frr/daemons

modprobe vrf 
# if frr in netns and not vrf
# nano /etc/frr/daemons

sed -i 's|zebra_options="  -A 127.0.0.1 -s 90000000"|zebra_options="  -A 127.0.0.1"|' /etc/frr/daemons


systemctl enable frr
systemctl restart frr
systemctl status frr


vtysh -c "show ip bgp summary"
vtysh -c "show ip bgp ipv4"
vtysh -c "show ip bgp ipv6"

sysctl -w net.ipv4.ip_forward=1

set +x
```

```
modprobe vrf 
sysctl -w net.ipv4.ip_forward=1
```


### TEST 1

### node140

```
root@node140:~# cat /etc/netplan/50-cloud-init.yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        enp1s0:
            match:
                macaddress: fa:16:3e:5e:23:ef
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:be:63:15
            set-name: enp2s0
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.140/24
            id: 200
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
            routes:
            -   to: 0.0.0.0/0
                via: 192.168.200.1
        enp1s0.400:
            addresses:
            - 192.168.201.140/24
            id: 400
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
root@node140:~#
```


```
root@node140:~# cat /etc/frr/frr.conf
frr version 8.4.4
frr defaults traditional
hostname node140
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 65000
 bgp router-id 192.168.200.140
 bgp bestpath as-path multipath-relax
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.201.141 peer-group fabric
 !
 address-family ipv4 unicast
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
root@node140:~#

```

```
sudo modprobe vrf 
sudo sysctl -w net.ipv4.ip_forward=1

#Add host1
sudo ip netns add host1
sudo ip link add veth1 type veth peer name eth0 netns host1
sudo ip netns exec host1 ip link set lo up
sudo ip netns exec host1 ip link set eth0 up
sudo ip netns exec host1 ip addr add 1.1.1.10/24 dev eth0
sudo ip netns exec host1 ip route add default via 1.1.1.254 dev eth0

#Add host2
sudo ip netns add host2
sudo ip link add veth3 type veth peer name eth2 netns host2
sudo ip netns exec host2 ip link set lo up
sudo ip netns exec host2 ip link set eth2 up
sudo ip netns exec host2 ip addr add 2.2.2.20/24 dev eth2
sudo ip netns exec host2 ip route add default via 2.2.2.254 dev eth2


sudo ip link add vbdif10 type bridge
sudo ip link add vbdif20 type bridge
sudo ip link set vbdif10 up
sudo ip link set vbdif20 up
sudo ip link add vxlan20 type vxlan id 20 local 192.168.201.140 dstport 4789 nolearning
sudo ip link add vxlan10 type vxlan id 10 local 192.168.201.140 dstport 4789 nolearning
sudo ip link set vxlan10 up
sudo ip link set vxlan20 up
sudo ip link set veth1 up
sudo ip link set veth3 up
sudo ip link set veth3 master vbdif20
sudo ip link set vxlan20 master vbdif20
sudo ip link set veth1 master vbdif10
sudo ip link set vxlan10 master vbdif10
sudo ip address add 1.1.1.254/24 dev vbdif10
sudo ip address add 2.2.2.254/24 dev vbdif20
echo 1 > /proc/sys/net/ipv4/ip_forward



router bgp 65000
 bgp router-id 192.168.200.140
 bgp bestpath as-path multipath-relax
 neighbor cluster peer-group
 neighbor cluster remote-as 65000
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.201.141 peer-group fabric
 !
 address-family ipv4 unicast
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!

```



```
root@node140:~# vtysh

Hello, this is FRRouting (version 8.4.4).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

node140# sh ip bgp
BGP table version is 4, local router ID is 192.168.200.140, vrf id 0
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

   Network          Next Hop            Metric LocPrf Weight Path
*>i192.168.200.0/24 192.168.201.141          0    100      0 ?
*>i192.168.201.0/24 192.168.201.141          0    100      0 ?
*>i192.168.202.0/24 192.168.201.141          0    100      0 ?
*>i192.168.203.0/24 192.168.201.141          0    100      0 ?

Displayed  4 routes and 4 total paths
node140# sh ip bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 192.168.200.140, local AS number 65000 vrf-id 0
BGP table version 4
RIB entries 7, using 1344 bytes of memory
Peers 1, using 724 KiB of memory
Peer groups 2, using 128 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.201.141 4      65000        79        34        0    0    0 00:17:07            4        0 N/A

Total number of neighbors 1
node140#

node140# sh ip bgp l2vpn evpn                                                                                                                                              23:06:19 [26/1807]
BGP table version is 7, local router ID is 192.168.200.140
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 192.168.200.140:2
*> [2]:[0]:[48]:[7e:88:fc:ac:0d:02]
                    192.168.201.140                    32768 i
                    ET:8 RT:65000:20
*> [2]:[0]:[48]:[c2:00:ad:c7:d3:f3]:[128]:[fe80::c000:adff:fec7:d3f3]
                    192.168.201.140                    32768 i
                    ET:8 RT:65000:20 Default Gateway ND:Router Flag
*> [3]:[0]:[32]:[192.168.201.140]
                    192.168.201.140                    32768 i
                    ET:8 RT:65000:20
Route Distinguisher: 192.168.200.140:3
*> [2]:[0]:[48]:[26:ae:b0:3c:ec:ff]:[32]:[1.1.1.254]
                    192.168.201.140                    32768 i
                    ET:8 RT:65000:10 Default Gateway
*> [2]:[0]:[48]:[26:ae:b0:3c:ec:ff]:[128]:[fe80::24ae:b0ff:fe3c:ecff]
                    192.168.201.140                    32768 i
                    ET:8 RT:65000:10 Default Gateway ND:Router Flag
*> [3]:[0]:[32]:[192.168.201.140]
                    192.168.201.140                    32768 i
                    ET:8 RT:65000:10
Route Distinguisher: 192.168.200.142:2
*>i[2]:[0]:[48]:[52:89:5f:2d:2b:e0]:[32]:[2.2.2.254]
                    192.168.202.142          0    100      0 i
                    RT:65000:20 ET:8 Default Gateway
*>i[2]:[0]:[48]:[52:89:5f:2d:2b:e0]:[128]:[fe80::5089:5fff:fe2d:2be0]
                    192.168.202.142          0    100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.202.142]
                    192.168.202.142          0    100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.142:3
*>i[2]:[0]:[48]:[16:c5:ea:6e:1b:bb]
                    192.168.202.142          0    100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[16:c5:ea:6e:1b:bb]:[32]:[1.1.1.1]
                    192.168.202.142          0    100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[ea:bc:c5:2c:cd:58]:[128]:[fe80::e8bc:c5ff:fe2c:cd58]
                    192.168.202.142          0    100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.202.142]
                    192.168.202.142          0    100      0 i
                    RT:65000:10 ET:8
Route Distinguisher: 192.168.200.143:2
*>i[2]:[0]:[48]:[1e:6c:25:c9:e7:09]
                    192.168.203.143          0    100      0 i
                    RT:65000:20 ET:8
*>i[2]:[0]:[48]:[46:6c:67:50:3a:10]:[128]:[fe80::446c:67ff:fe50:3a10]
                    192.168.203.143          0    100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.203.143]
                    192.168.203.143          0    100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.143:3
*>i[2]:[0]:[48]:[5e:35:2b:8d:f6:c0]:[128]:[fe80::5c35:2bff:fe8d:f6c0]
                    192.168.203.143          0    100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.203.143]
                    192.168.203.143          0    100      0 i
                    RT:65000:10 ET:8

Displayed 18 out of 18 total prefixes
node140#
```


```
root@node140:~# tcpdump  -ni enp1s0.400
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp1s0.400, link-type EN10MB (Ethernet), snapshot length 262144 bytes
23:11:36.103041 IP 192.168.203.143.34085 > 192.168.201.140.4789: VXLAN, flags [I] (0x08), vni 20
IP 1.1.1.2 > 2.2.2.20: ICMP echo request, id 27693, seq 29, length 64
23:11:36.103094 IP 192.168.201.140.45901 > 192.168.203.143.4789: VXLAN, flags [I] (0x08), vni 20
IP 2.2.2.20 > 1.1.1.2: ICMP echo reply, id 27693, seq 29, length 64
23:11:37.127045 IP 192.168.203.143.34085 > 192.168.201.140.4789: VXLAN, flags [I] (0x08), vni 20
IP 1.1.1.2 > 2.2.2.20: ICMP echo request, id 27693, seq 30, length 64
23:11:37.127101 IP 192.168.201.140.45901 > 192.168.203.143.4789: VXLAN, flags [I] (0x08), vni 20
IP 2.2.2.20 > 1.1.1.2: ICMP echo reply, id 27693, seq 30, length 64
23:11:38.151029 IP 192.168.203.143.34085 > 192.168.201.140.4789: VXLAN, flags [I] (0x08), vni 20
IP 1.1.1.2 > 2.2.2.20: ICMP echo request, id 27693, seq 31, length 64
23:11:38.151081 IP 192.168.201.140.45901 > 192.168.203.143.4789: VXLAN, flags [I] (0x08), vni 20
IP 2.2.2.20 > 1.1.1.2: ICMP echo reply, id 27693, seq 31, length 64
23:11:39.175035 IP 192.168.203.143.34085 > 192.168.201.140.4789: VXLAN, flags [I] (0x08), vni 20
IP 1.1.1.2 > 2.2.2.20: ICMP echo request, id 27693, seq 32, length 64
23:11:39.175111 IP 192.168.201.140.45901 > 192.168.203.143.4789: VXLAN, flags [I] (0x08), vni 20
IP 2.2.2.20 > 1.1.1.2: ICMP echo reply, id 27693, seq 32, length 64
^C
8 packets captured
8 packets received by filter
0 packets dropped by kernel
root@node140:~#

```

### node 141


```
root@node141:~# cat /etc/netplan/50-cloud-init.yaml                                                                                                                        23:01:45 [10/1917]
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        enp1s0:
            match:
                macaddress: fa:16:3e:4e:f2:29
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:12:59:2d
            set-name: enp2s0
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.141/24
            id: 200
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
            routes:
            -   to: 0.0.0.0/0
                via: 192.168.200.1
        enp1s0.400:
            addresses:
            - 192.168.201.141/24
            id: 400
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
        enp1s0.600:
            addresses:
            - 192.168.202.141/24
            id: 600
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
        enp1s0.800:
            addresses:
            - 192.168.203.141/24
            id: 800
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
root@node141:~#
```


```
root@node141:~# cat /etc/frr/frr.conf
frr version 8.4.4
frr defaults traditional
hostname node141
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 65000
 bgp router-id 192.168.200.141
 bgp bestpath as-path multipath-relax
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.201.140 peer-group fabric
 neighbor 192.168.202.142 peer-group fabric
 neighbor 192.168.203.143 peer-group fabric
 !
 address-family ipv4 unicast
  redistribute connected
  neighbor fabric route-reflector-client
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor fabric activate
  neighbor fabric route-reflector-client
 exit-address-family
exit
!
root@node141:~#

```


```
node141# sh ip bgp l2vpn evpn                                                                                                                                              23:07:28 [35/1836]
BGP table version is 7, local router ID is 192.168.200.141
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 192.168.200.140:2
*>i[2]:[0]:[48]:[7e:88:fc:ac:0d:02]
                    192.168.201.140               100      0 i
                    RT:65000:20 ET:8
*>i[2]:[0]:[48]:[c2:00:ad:c7:d3:f3]:[128]:[fe80::c000:adff:fec7:d3f3]
                    192.168.201.140               100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.201.140]
                    192.168.201.140               100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.140:3
*>i[2]:[0]:[48]:[26:ae:b0:3c:ec:ff]:[32]:[1.1.1.254]
                    192.168.201.140               100      0 i
                    RT:65000:10 ET:8 Default Gateway
*>i[2]:[0]:[48]:[26:ae:b0:3c:ec:ff]:[128]:[fe80::24ae:b0ff:fe3c:ecff]
                    192.168.201.140               100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[2]:[0]:[48]:[be:4c:87:52:34:7a]
                    192.168.201.140               100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[be:4c:87:52:34:7a]:[32]:[1.1.1.10]
                    192.168.201.140               100      0 i
                    RT:65000:10 ET:8
*>i[3]:[0]:[32]:[192.168.201.140]
                    192.168.201.140               100      0 i
                    RT:65000:10 ET:8
Route Distinguisher: 192.168.200.142:2
*>i[2]:[0]:[48]:[16:e9:9a:28:12:1b]
                    192.168.202.142               100      0 i
                    RT:65000:20 ET:8
*>i[2]:[0]:[48]:[16:e9:9a:28:12:1b]:[32]:[2.2.2.2]
                    192.168.202.142               100      0 i
                    RT:65000:20 ET:8
*>i[2]:[0]:[48]:[52:89:5f:2d:2b:e0]:[32]:[2.2.2.254]
                    192.168.202.142               100      0 i
                    RT:65000:20 ET:8 Default Gateway
*>i[2]:[0]:[48]:[52:89:5f:2d:2b:e0]:[128]:[fe80::5089:5fff:fe2d:2be0]
                    192.168.202.142               100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.202.142]
                    192.168.202.142               100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.142:3
*>i[2]:[0]:[48]:[16:c5:ea:6e:1b:bb]
                    192.168.202.142               100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[16:c5:ea:6e:1b:bb]:[32]:[1.1.1.1]
                    192.168.202.142               100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[ea:bc:c5:2c:cd:58]:[128]:[fe80::e8bc:c5ff:fe2c:cd58]
                    192.168.202.142               100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.202.142]
                    192.168.202.142               100      0 i
                    RT:65000:10 ET:8
Route Distinguisher: 192.168.200.143:2
*>i[2]:[0]:[48]:[46:6c:67:50:3a:10]:[128]:[fe80::446c:67ff:fe50:3a10]
                    192.168.203.143               100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.203.143]
                    192.168.203.143               100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.143:3
*>i[2]:[0]:[48]:[5e:35:2b:8d:f6:c0]:[128]:[fe80::5c35:2bff:fe8d:f6c0]
                    192.168.203.143               100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.203.143]
                    192.168.203.143               100      0 i
                    RT:65000:10 ET:8

Displayed 21 out of 21 total prefixes
node141#


```


### node142
```
root@node142:~# cat /etc/netplan/50-cloud-init.yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        enp1s0:
            match:
                macaddress: fa:16:3e:6e:46:29
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:c2:d1:75
            set-name: enp2s0
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.142/24
            id: 200
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
            routes:
            -   to: 0.0.0.0/0
                via: 192.168.200.1
        enp1s0.600:
            addresses:
            - 192.168.202.142/24
            id: 600
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
root@node142:~#

```

```
root@node142:~# cat /etc/frr/frr.conf
frr version 8.4.4
frr defaults traditional
hostname node142
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 65000
 bgp router-id 192.168.200.142
 bgp bestpath as-path multipath-relax
 neighbor cluster peer-group
 neighbor cluster remote-as 65000
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.202.141 peer-group fabric
 !
 address-family ipv4 unicast
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
root@node142:~#

```

```
sudo modprobe vrf 
sudo sysctl -w net.ipv4.ip_forward=1

#Add host1
sudo ip netns add host1
sudo ip link add veth1 type veth peer name eth0 netns host1
sudo ip netns exec host1 ip link set lo up
sudo ip netns exec host1 ip link set eth0 up
sudo ip netns exec host1 ip addr add 1.1.1.1/24 dev eth0
sudo ip netns exec host1 ip route add default via 1.1.1.254 dev eth0

#Add host2
sudo ip netns add host2
sudo ip link add veth3 type veth peer name eth2 netns host2
sudo ip netns exec host2 ip link set lo up
sudo ip netns exec host2 ip link set eth2 up
sudo ip netns exec host2 ip addr add 2.2.2.2/24 dev eth2
sudo ip netns exec host2 ip route add default via 2.2.2.254 dev eth2


sudo ip link add vbdif10 type bridge
sudo ip link add vbdif20 type bridge
sudo ip link set vbdif10 up
sudo ip link set vbdif20 up
sudo ip link add vxlan20 type vxlan id 20 local 192.168.202.142 dstport 4789 nolearning
sudo ip link add vxlan10 type vxlan id 10 local 192.168.202.142 dstport 4789 nolearning
sudo ip link set vxlan10 up
sudo ip link set vxlan20 up
sudo ip link set veth1 up
sudo ip link set veth3 up
sudo ip link set veth3 master vbdif20
sudo ip link set vxlan20 master vbdif20
sudo ip link set veth1 master vbdif10
sudo ip link set vxlan10 master vbdif10
sudo ip address add 1.1.1.254/24 dev vbdif10
sudo ip address add 2.2.2.254/24 dev vbdif20
echo 1 > /proc/sys/net/ipv4/ip_forward



router bgp 65000
 bgp router-id 192.168.200.142
 bgp bestpath as-path multipath-relax
 neighbor cluster peer-group
 neighbor cluster remote-as 65000
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.202.141 peer-group fabric
 !
 address-family ipv4 unicast
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!

```

```
node142# sh ip bgp l2vpn evpn                                                                                                                                              23:08:18 [35/1831]
BGP table version is 7, local router ID is 192.168.200.142
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 192.168.200.140:2
*>i[2]:[0]:[48]:[7e:88:fc:ac:0d:02]
                    192.168.201.140          0    100      0 i
                    RT:65000:20 ET:8
*>i[2]:[0]:[48]:[c2:00:ad:c7:d3:f3]:[128]:[fe80::c000:adff:fec7:d3f3]
                    192.168.201.140          0    100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.201.140]
                    192.168.201.140          0    100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.140:3
*>i[2]:[0]:[48]:[26:ae:b0:3c:ec:ff]:[32]:[1.1.1.254]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8 Default Gateway
*>i[2]:[0]:[48]:[26:ae:b0:3c:ec:ff]:[128]:[fe80::24ae:b0ff:fe3c:ecff]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[2]:[0]:[48]:[be:4c:87:52:34:7a]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[be:4c:87:52:34:7a]:[32]:[1.1.1.10]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8
*>i[3]:[0]:[32]:[192.168.201.140]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8
Route Distinguisher: 192.168.200.142:2
*> [2]:[0]:[48]:[16:e9:9a:28:12:1b]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:20
*> [2]:[0]:[48]:[16:e9:9a:28:12:1b]:[32]:[2.2.2.2]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:20
*> [2]:[0]:[48]:[52:89:5f:2d:2b:e0]:[32]:[2.2.2.254]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:20 Default Gateway
*> [2]:[0]:[48]:[52:89:5f:2d:2b:e0]:[128]:[fe80::5089:5fff:fe2d:2be0]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:20 Default Gateway ND:Router Flag
*> [3]:[0]:[32]:[192.168.202.142]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:20
Route Distinguisher: 192.168.200.142:3
*> [2]:[0]:[48]:[16:c5:ea:6e:1b:bb]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:10
*> [2]:[0]:[48]:[16:c5:ea:6e:1b:bb]:[32]:[1.1.1.1]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:10
*> [2]:[0]:[48]:[ea:bc:c5:2c:cd:58]:[128]:[fe80::e8bc:c5ff:fe2c:cd58]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:10 Default Gateway ND:Router Flag
*> [3]:[0]:[32]:[192.168.202.142]
                    192.168.202.142                    32768 i
                    ET:8 RT:65000:10
Route Distinguisher: 192.168.200.143:2
*>i[2]:[0]:[48]:[46:6c:67:50:3a:10]:[128]:[fe80::446c:67ff:fe50:3a10]
                    192.168.203.143          0    100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.203.143]
                    192.168.203.143          0    100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.143:3
*>i[2]:[0]:[48]:[5e:35:2b:8d:f6:c0]:[128]:[fe80::5c35:2bff:fe8d:f6c0]
                    192.168.203.143          0    100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.203.143]
                    192.168.203.143          0    100      0 i
                    RT:65000:10 ET:8

Displayed 21 out of 21 total prefixes
node142#

```

### node143

```
root@node143:~# cat /etc/netplan/50-cloud-init.yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        enp1s0:
            match:
                macaddress: fa:16:3e:8a:df:9a
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:83:60:87
            set-name: enp2s0
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.143/24
            id: 200
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
            routes:
            -   to: 0.0.0.0/0
                via: 192.168.200.1
        enp1s0.800:
            addresses:
            - 192.168.203.143/24
            id: 800
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
root@node143:~#
```


```
root@node143:~# cat /etc/frr/frr.conf
frr version 8.4.4
frr defaults traditional
hostname node143
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 65000
 bgp router-id 192.168.200.143
 bgp bestpath as-path multipath-relax
 neighbor cluster peer-group
 neighbor cluster remote-as 65000
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.203.141 peer-group fabric
 !
 address-family ipv4 unicast
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
root@node143:~#

```


```
sudo modprobe vrf 
sudo sysctl -w net.ipv4.ip_forward=1

#Add host1
sudo ip netns add host1
sudo ip link add veth1 type veth peer name eth0 netns host1
sudo ip netns exec host1 ip link set lo up
sudo ip netns exec host1 ip link set eth0 up
sudo ip netns exec host1 ip addr add 1.1.1.2/24 dev eth0
sudo ip netns exec host1 ip route add default via 1.1.1.254 dev eth0

#Add host2
sudo ip netns add host2
sudo ip link add veth3 type veth peer name eth2 netns host2
sudo ip netns exec host2 ip link set lo up
sudo ip netns exec host2 ip link set eth2 up
sudo ip netns exec host2 ip addr add 2.2.2.3/24 dev eth2
sudo ip netns exec host2 ip route add default via 2.2.2.254 dev eth2


sudo ip link add vbdif10 type bridge
sudo ip link add vbdif20 type bridge
sudo ip link set vbdif10 up
sudo ip link set vbdif20 up
sudo ip link add vxlan20 type vxlan id 20 local 192.168.203.143 dstport 4789 nolearning
sudo ip link add vxlan10 type vxlan id 10 local 192.168.203.143 dstport 4789 nolearning
sudo ip link set vxlan10 up
sudo ip link set vxlan20 up
sudo ip link set veth1 up
sudo ip link set veth3 up
sudo ip link set veth3 master vbdif20
sudo ip link set vxlan20 master vbdif20
sudo ip link set veth1 master vbdif10
sudo ip link set vxlan10 master vbdif10
sudo ip address add 1.1.1.254/24 dev vbdif10
sudo ip address add 2.2.2.254/24 dev vbdif20
echo 1 > /proc/sys/net/ipv4/ip_forward



router bgp 65000
 bgp router-id 192.168.200.143
 bgp bestpath as-path multipath-relax
 neighbor cluster peer-group
 neighbor cluster remote-as 65000
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.203.141 peer-group fabric
 !
 address-family ipv4 unicast
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!

```


```
node143# sh ip bgp l2vpn evpn                                                                                                                                              23:09:29 [35/1858]
BGP table version is 15, local router ID is 192.168.200.143
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 192.168.200.140:2
*>i[2]:[0]:[48]:[7e:88:fc:ac:0d:02]
                    192.168.201.140          0    100      0 i
                    RT:65000:20 ET:8
*>i[2]:[0]:[48]:[c2:00:ad:c7:d3:f3]:[128]:[fe80::c000:adff:fec7:d3f3]
                    192.168.201.140          0    100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.201.140]
                    192.168.201.140          0    100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.140:3
*>i[2]:[0]:[48]:[26:ae:b0:3c:ec:ff]:[32]:[1.1.1.254]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8 Default Gateway
*>i[2]:[0]:[48]:[26:ae:b0:3c:ec:ff]:[128]:[fe80::24ae:b0ff:fe3c:ecff]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[2]:[0]:[48]:[be:4c:87:52:34:7a]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[be:4c:87:52:34:7a]:[32]:[1.1.1.10]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8
*>i[3]:[0]:[32]:[192.168.201.140]
                    192.168.201.140          0    100      0 i
                    RT:65000:10 ET:8
Route Distinguisher: 192.168.200.142:2
*>i[2]:[0]:[48]:[16:e9:9a:28:12:1b]
                    192.168.202.142          0    100      0 i
                    RT:65000:20 ET:8
*>i[2]:[0]:[48]:[16:e9:9a:28:12:1b]:[32]:[2.2.2.2]
                    192.168.202.142          0    100      0 i
                    RT:65000:20 ET:8
*>i[2]:[0]:[48]:[52:89:5f:2d:2b:e0]:[32]:[2.2.2.254]
                    192.168.202.142          0    100      0 i
                    RT:65000:20 ET:8 Default Gateway
*>i[2]:[0]:[48]:[52:89:5f:2d:2b:e0]:[128]:[fe80::5089:5fff:fe2d:2be0]
                    192.168.202.142          0    100      0 i
                    RT:65000:20 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.202.142]
                    192.168.202.142          0    100      0 i
                    RT:65000:20 ET:8
Route Distinguisher: 192.168.200.142:3
*>i[2]:[0]:[48]:[16:c5:ea:6e:1b:bb]
                    192.168.202.142          0    100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[16:c5:ea:6e:1b:bb]:[32]:[1.1.1.1]
                    192.168.202.142          0    100      0 i
                    RT:65000:10 ET:8
*>i[2]:[0]:[48]:[ea:bc:c5:2c:cd:58]:[128]:[fe80::e8bc:c5ff:fe2c:cd58]
                    192.168.202.142          0    100      0 i
                    RT:65000:10 ET:8 Default Gateway ND:Router Flag
*>i[3]:[0]:[32]:[192.168.202.142]
                    192.168.202.142          0    100      0 i
                    RT:65000:10 ET:8
Route Distinguisher: 192.168.200.143:2
*> [2]:[0]:[48]:[46:6c:67:50:3a:10]:[128]:[fe80::446c:67ff:fe50:3a10]
                    192.168.203.143                    32768 i
                    ET:8 RT:65000:20 Default Gateway ND:Router Flag
*> [3]:[0]:[32]:[192.168.203.143]
                    192.168.203.143                    32768 i
                    ET:8 RT:65000:20
Route Distinguisher: 192.168.200.143:3
*> [2]:[0]:[48]:[5e:35:2b:8d:f6:c0]:[128]:[fe80::5c35:2bff:fe8d:f6c0]
                    192.168.203.143                    32768 i
                    ET:8 RT:65000:10 Default Gateway ND:Router Flag
*> [3]:[0]:[32]:[192.168.203.143]
                    192.168.203.143                    32768 i
                    ET:8 RT:65000:10

Displayed 21 out of 21 total prefixes
node143#

```



### TEST 2


### node140

```
root@node140:~# cat /etc/frr/frr.conf
frr version 8.4.4
frr defaults traditional
hostname node140
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
ip route 3.3.3.3/32 2.2.2.2
!
router bgp 65000
 bgp router-id 192.168.200.140
 bgp bestpath as-path multipath-relax
 neighbor cluster peer-group
 neighbor cluster remote-as 65000
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.201.141 peer-group fabric
 !
 address-family ipv4 unicast
  redistribute connected
  redistribute static
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor cluster activate
  neighbor cluster route-map IMPORT in
  neighbor cluster route-map EXPORT out
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
root@node140:~#
```


```
node140# show ip r
% Ambiguous command: show ip r
node140# show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

K>* 0.0.0.0/0 [0/0] via 192.168.200.1, enp1s0.200, 00:46:25
C>* 1.1.1.0/24 is directly connected, vbdif10, 00:35:12
C>* 2.2.2.0/24 is directly connected, vbdif20, 00:35:12
S>* 3.3.3.3/32 [1/0] via 2.2.2.2, vbdif20, weight 1, 00:03:11
C>* 192.168.200.0/24 is directly connected, enp1s0.200, 00:46:25
C>* 192.168.201.0/24 is directly connected, enp1s0.400, 00:46:25
B>* 192.168.202.0/24 [200/0] via 192.168.201.141, enp1s0.400, weight 1, 00:34:51
B>* 192.168.203.0/24 [200/0] via 192.168.201.141, enp1s0.400, weight 1, 00:34:51
node140#

```

### node141
```
node141# sh run
Building configuration...

Current configuration:
!
frr version 8.4.4
frr defaults traditional
hostname node141
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 65000
 bgp router-id 192.168.200.141
 bgp bestpath as-path multipath-relax
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.201.140 peer-group fabric
 neighbor 192.168.202.142 peer-group fabric
 neighbor 192.168.203.143 peer-group fabric
 !
 address-family ipv4 unicast
  redistribute connected
  redistribute static
  neighbor fabric route-reflector-client
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor fabric activate
  neighbor fabric route-reflector-client
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
  advertise-default-gw
 exit-address-family
exit
!
route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
end
node141#
```


```
node141# sh ip bgp
BGP table version is 10, local router ID is 192.168.200.141, vrf id 0
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

   Network          Next Hop            Metric LocPrf Weight Path
*=i1.1.1.0/24       192.168.203.143          0    100      0 ?
*=i                 192.168.202.142          0    100      0 ?
*>i                 192.168.201.140          0    100      0 ?
*=i2.2.2.0/24       192.168.203.143          0    100      0 ?
*=i                 192.168.202.142          0    100      0 ?
*>i                 192.168.201.140          0    100      0 ?
*>i3.3.3.3/32       2.2.2.2                  0    100      0 ?
* i192.168.200.0/24 192.168.203.143          0    100      0 ?
* i                 192.168.202.142          0    100      0 ?
* i                 192.168.201.140          0    100      0 ?
*>                  0.0.0.0                  0         32768 ?
* i192.168.201.0/24 192.168.201.140          0    100      0 ?
*>                  0.0.0.0                  0         32768 ?
* i192.168.202.0/24 192.168.202.142          0    100      0 ?
*>                  0.0.0.0                  0         32768 ?
* i192.168.203.0/24 192.168.203.143          0    100      0 ?
*>                  0.0.0.0                  0         32768 ?

Displayed  7 routes and 17 total paths
node141# sh ip bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 192.168.200.141, local AS number 65000 vrf-id 0
BGP table version 10
RIB entries 13, using 2496 bytes of memory
Peers 3, using 2172 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.201.140 4      65000        76       124        0    0    0 00:35:37            5        7 N/A
192.168.202.142 4      65000        76       168        0    0    0 00:34:29            4        7 N/A
192.168.203.143 4      65000        68       123        0    0    0 00:36:44            4        7 N/A

Total number of neighbors 3
node141#
```

### node142
```
ip netns exec host2 ifconfig lo:10 3.3.3.3/32
```



```
root@node142:~# tcpdump -ni enp1s0.600
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp1s0.600, link-type EN10MB (Ethernet), snapshot length 262144 bytes
23:25:59.648130 IP 192.168.201.140.57280 > 192.168.202.142.4789: VXLAN, flags [I] (0x08), vni 20
IP 1.1.1.10 > 3.3.3.3: ICMP echo request, id 55723, seq 14, length 64
23:25:59.648181 IP 192.168.202.142.34510 > 192.168.201.140.4789: VXLAN, flags [I] (0x08), vni 20
IP 3.3.3.3 > 1.1.1.10: ICMP echo reply, id 55723, seq 14, length 64
23:26:00.672143 IP 192.168.201.140.57280 > 192.168.202.142.4789: VXLAN, flags [I] (0x08), vni 20
IP 1.1.1.10 > 3.3.3.3: ICMP echo request, id 55723, seq 15, length 64
23:26:00.672189 IP 192.168.202.142.34510 > 192.168.201.140.4789: VXLAN, flags [I] (0x08), vni 20
IP 3.3.3.3 > 1.1.1.10: ICMP echo reply, id 55723, seq 15, length 64
23:26:01.696046 IP 192.168.201.140.57280 > 192.168.202.142.4789: VXLAN, flags [I] (0x08), vni 20
IP 1.1.1.10 > 3.3.3.3: ICMP echo request, id 55723, seq 16, length 64
23:26:01.696072 IP 192.168.202.142.34510 > 192.168.201.140.4789: VXLAN, flags [I] (0x08), vni 20
IP 3.3.3.3 > 1.1.1.10: ICMP echo reply, id 55723, seq 16, length 64
23:26:02.720073 IP 192.168.201.140.57280 > 192.168.202.142.4789: VXLAN, flags [I] (0x08), vni 20
IP 1.1.1.10 > 3.3.3.3: ICMP echo request, id 55723, seq 17, length 64
23:26:02.720109 IP 192.168.202.142.34510 > 192.168.201.140.4789: VXLAN, flags [I] (0x08), vni 20
IP 3.3.3.3 > 1.1.1.10: ICMP echo reply, id 55723, seq 17, length 64
^C
8 packets captured
8 packets received by filter
0 packets dropped by kernel
root@node142:~#
root@node140:~# ip netns exec host1 ping 3.3.3.3
PING 3.3.3.3 (3.3.3.3) 56(84) bytes of data.
64 bytes from 3.3.3.3: icmp_seq=1 ttl=63 time=1.04 ms
64 bytes from 3.3.3.3: icmp_seq=2 ttl=63 time=0.607 ms
64 bytes from 3.3.3.3: icmp_seq=3 ttl=63 time=0.518 ms
64 bytes from 3.3.3.3: icmp_seq=4 ttl=63 time=0.507 ms
64 bytes from 3.3.3.3: icmp_seq=5 ttl=63 time=0.552 ms
64 bytes from 3.3.3.3: icmp_seq=6 ttl=63 time=0.571 ms
64 bytes from 3.3.3.3: icmp_seq=7 ttl=63 time=0.564 ms
64 bytes from 3.3.3.3: icmp_seq=8 ttl=63 time=0.553 ms
64 bytes from 3.3.3.3: icmp_seq=9 ttl=63 time=0.562 ms
64 bytes from 3.3.3.3: icmp_seq=10 ttl=63 time=0.736 ms
64 bytes from 3.3.3.3: icmp_seq=11 ttl=63 time=0.538 ms
64 bytes from 3.3.3.3: icmp_seq=12 ttl=63 time=0.493 ms
64 bytes from 3.3.3.3: icmp_seq=13 ttl=63 time=0.572 ms
64 bytes from 3.3.3.3: icmp_seq=14 ttl=63 time=0.661 ms
64 bytes from 3.3.3.3: icmp_seq=15 ttl=63 time=0.678 ms
64 bytes from 3.3.3.3: icmp_seq=16 ttl=63 time=0.499 ms
64 bytes from 3.3.3.3: icmp_seq=17 ttl=63 time=0.555 ms
64 bytes from 3.3.3.3: icmp_seq=18 ttl=63 time=0.522 ms
64 bytes from 3.3.3.3: icmp_seq=19 ttl=63 time=0.593 ms
64 bytes from 3.3.3.3: icmp_seq=20 ttl=63 time=0.571 ms
64 bytes from 3.3.3.3: icmp_seq=21 ttl=63 time=0.540 ms
64 bytes from 3.3.3.3: icmp_seq=22 ttl=63 time=0.504 ms
64 bytes from 3.3.3.3: icmp_seq=23 ttl=63 time=0.587 ms
64 bytes from 3.3.3.3: icmp_seq=24 ttl=63 time=0.544 ms
64 bytes from 3.3.3.3: icmp_seq=25 ttl=63 time=0.582 ms
64 bytes from 3.3.3.3: icmp_seq=26 ttl=63 time=0.599 ms
64 bytes from 3.3.3.3: icmp_seq=27 ttl=63 time=0.548 ms
64 bytes from 3.3.3.3: icmp_seq=28 ttl=63 time=0.596 ms
64 bytes from 3.3.3.3: icmp_seq=29 ttl=63 time=0.582 ms
64 bytes from 3.3.3.3: icmp_seq=30 ttl=63 time=0.574 ms
^C
--- 3.3.3.3 ping statistics ---
30 packets transmitted, 30 received, 0% packet loss, time 29681ms
rtt min/avg/max/mdev = 0.493/0.584/1.041/0.099 ms
root@node140:~#

```

```
root@node140:~# ip r s
default via 192.168.200.1 dev enp1s0.200 proto static
1.1.1.0/24 dev vbdif10 proto kernel scope link src 1.1.1.254
2.2.2.0/24 dev vbdif20 proto kernel scope link src 2.2.2.254
3.3.3.3 nhid 39 via 2.2.2.2 dev vbdif20 proto static metric 20
192.168.200.0/24 dev enp1s0.200 proto kernel scope link src 192.168.200.140
192.168.201.0/24 dev enp1s0.400 proto kernel scope link src 192.168.201.140
192.168.202.0/24 nhid 32 via 192.168.201.141 dev enp1s0.400 proto bgp metric 20
192.168.203.0/24 nhid 32 via 192.168.201.141 dev enp1s0.400 proto bgp metric 20
root@node140:~#

```


```
root@node141:~# ip r s
default via 192.168.200.1 dev enp1s0.200 proto static
1.1.1.0/24 nhid 41 proto bgp metric 20
        nexthop via 192.168.201.140 dev enp1s0.400 weight 1
        nexthop via 192.168.202.142 dev enp1s0.600 weight 1
        nexthop via 192.168.203.143 dev enp1s0.800 weight 1
2.2.2.0/24 nhid 41 proto bgp metric 20
        nexthop via 192.168.201.140 dev enp1s0.400 weight 1
        nexthop via 192.168.202.142 dev enp1s0.600 weight 1
        nexthop via 192.168.203.143 dev enp1s0.800 weight 1
3.3.3.3 nhid 45 proto bgp metric 20
        nexthop via 192.168.201.140 dev enp1s0.400 weight 1
        nexthop via 192.168.202.142 dev enp1s0.600 weight 1
        nexthop via 192.168.203.143 dev enp1s0.800 weight 1
192.168.200.0/24 dev enp1s0.200 proto kernel scope link src 192.168.200.141
192.168.201.0/24 dev enp1s0.400 proto kernel scope link src 192.168.201.141
192.168.202.0/24 dev enp1s0.600 proto kernel scope link src 192.168.202.141
192.168.203.0/24 dev enp1s0.800 proto kernel scope link src 192.168.203.141
root@node141:~#

```


```
root@node142:~# ip r s
default via 192.168.200.1 dev enp1s0.200 proto static
1.1.1.0/24 dev vbdif10 proto kernel scope link src 1.1.1.254
2.2.2.0/24 dev vbdif20 proto kernel scope link src 2.2.2.254
3.3.3.3 nhid 39 via 2.2.2.2 dev vbdif20 proto bgp metric 20
192.168.200.0/24 dev enp1s0.200 proto kernel scope link src 192.168.200.142
192.168.201.0/24 nhid 16 via 192.168.202.141 dev enp1s0.600 proto bgp metric 20
192.168.202.0/24 dev enp1s0.600 proto kernel scope link src 192.168.202.142
192.168.203.0/24 nhid 16 via 192.168.202.141 dev enp1s0.600 proto bgp metric 20
root@node142:~#

```


```
root@node143:~# ip r s
default via 192.168.200.1 dev enp1s0.200 proto static
1.1.1.0/24 dev vbdif10 proto kernel scope link src 1.1.1.254
2.2.2.0/24 dev vbdif20 proto kernel scope link src 2.2.2.254
3.3.3.3 nhid 41 via 2.2.2.2 dev vbdif20 proto bgp metric 20
192.168.200.0/24 dev enp1s0.200 proto kernel scope link src 192.168.200.143
192.168.201.0/24 nhid 32 via 192.168.203.141 dev enp1s0.800 proto bgp metric 20
192.168.202.0/24 nhid 32 via 192.168.203.141 dev enp1s0.800 proto bgp metric 20
192.168.203.0/24 dev enp1s0.800 proto kernel scope link src 192.168.203.143
root@node143:~#

```


### TEST 4

### node140

```
# Add vrf
/usr/bin/sudo /usr/sbin/ip link add dev BLUE type vrf table 10
/usr/bin/sudo /usr/sbin/ip link set dev BLUE up

# Add LAN
/usr/bin/sudo /usr/sbin/ip link add link enp2s0 name BLUE-LAN type vlan id 210
/usr/bin/sudo /usr/sbin/ip link set dev BLUE-LAN master BLUE up
```


```
!
interface BLUE-LAN
 ip address 10.0.0.1/24
exit
!
router bgp 65000 vrf BLUE
 bgp router-id 192.168.200.140
 bgp log-neighbor-changes
 !
 address-family ipv4 unicast
  network 10.0.0.0/24
  neighbor BLUE-PEER soft-reconfiguration inbound
  neighbor BLUE-PEER route-map BLUE-in in
  neighbor BLUE-PEER route-map BLUE-out out
 exit-address-family
exit
!
ip prefix-list BLUE-LAN seq 1 permit 10.0.0.0/24
!
route-map BLUE-out permit 1
 match ip address prefix-list BLUE-LAN
exit
!
route-map BLUE-in permit 1
 match ip address prefix-list BLUE-WAN
exit
!
```


### node142

```
# Add vrf
/usr/bin/sudo /usr/sbin/ip link add dev BLUE type vrf table 10
/usr/bin/sudo /usr/sbin/ip link set dev BLUE up

# Add LAN
/usr/bin/sudo /usr/sbin/ip link add link enp2s0 name BLUE-LAN type vlan id 211
/usr/bin/sudo /usr/sbin/ip link set dev BLUE-LAN master BLUE up
```


```
!
interface BLUE-LAN
 ip address 10.0.1.1/24
exit
!
router bgp 65000 vrf BLUE
 bgp router-id 192.168.200.142
 bgp log-neighbor-changes
 !
 address-family ipv4 unicast
  network 10.0.1.0/24
  neighbor BLUE-PEER soft-reconfiguration inbound
  neighbor BLUE-PEER route-map BLUE-in in
  neighbor BLUE-PEER route-map BLUE-out out
 exit-address-family
exit
!
ip prefix-list BLUE-LAN seq 1 permit 10.0.0.0/24
!
route-map BLUE-out permit 1
 match ip address prefix-list BLUE-LAN
exit
!
route-map BLUE-in permit 1
 match ip address prefix-list BLUE-WAN
exit
!
```
