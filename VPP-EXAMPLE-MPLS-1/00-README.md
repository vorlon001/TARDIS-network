### Create 4 vm ubuntu 22.04. create vm https://github.com/vorlon001/libvirt-home-labs/tree/v2
- network one: Virtio network device
- network two: e1000
- network three: e1000
- network four: e1000
- all network attach to switch ovs, mode trunk

### Network VM Ubuntu 22.04LTS


```

      node3 (Gateway, 192.168.203.3:VLAN800, UBUNTU 22.04LTS)
                          |
                          |
                          |                                 node3 (FRRouting, BGP, Gateway, 192.168.203.150:VLAN800, UBUNTU 22.04LTS)
                          |                                                       |
                          |                                                       |
                          |                                                       |
                          |                                                       |
                          --------------- VLAN800 --------------------------------------------------------------------------------
                          |                            |                                                     |                   |
                          |                            |                                                     |                   |
                          |                            |                                                     |                   |
                          |                            |                                                     |                   |
                          |          node180 (VTEP-VPP, 192.168.203.180:VLAN800, UBUNTU 22.04LTS)            |                   |
                          |                      (192.168.200.180: VLAN200)                                  |                   |
                          |                            |                                                     |                   |
                          |                            |                                                     |                   |
                          |                            |                                                      \                  |
                          |                  --------------------------(VLAN200)---------------------------------------------    |
                          |                  |                                                          |     /             |    |
                          |                  |                                                          |     |             |    |
                          |                  |                                                          |     |             |    |
                          |                  |                                                          |     |             |    |
                          |                  |                                                          |     |             |    |
                          |                  |                                                          |     |             |    |
                          |                  |                                                          |     |             |    |
   node170 (OVN-CENTRAL,OVS, 192.168.200.170:VLAN200, UBUNTU 22.04LTS)                                  |     |             |    |
                      (192.168.203.170: VLAN800)                                                        |     |             |    |
                                                                                                        |     |             |    |
                                              node170 (OVN-CENTRAL,OVS, 192.168.200.170:VLAN200, UBUNTU 22.04LTS)           |    |
                                                        (192.168.203.171: VLAN800)                                          |    |
                                                                                                                            |    |
                                                                   node170 (OVN-CENTRAL,OVS,192.168.200.172:VLAN200, UBUNTU 22.04LTS)
                                                                                        (192.168.203.172: VLAN800)

```

```


https://github.com/pimvanpelt/lcpng
https://ipng.ch/s/articles/2023/05/21/vpp-mpls-3.html
https://wiki.fd.io/view/VPP/Using_VPP_as_a_VXLAN_Tunnel_Terminator#Example_Config_of_BD_with_BVI.2FVXLAN-Tunnel.2FEthernet-Port

# WORK
```shell
# node180
#!/usr/bin/bash
export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}


vppctl create bridge-domain 13 learn 1 forward 1 uu-flood 1 flood 1 arp-term 0
vppctl show bridge-domain 13 detail
vppctl create vxlan tunnel src 192.168.203.180 dst 192.168.203.181 vni 666
vppctl set interface l2 bridge vxlan_tunnel0 13 1
vppctl show vxlan tunnel
vppctl show bridge-domain 13 detail

vppctl create loopback interface instance 10
vppctl lcp create loop10 host-if bvi_vxlan
vppctl set interface ip address loop10 192.168.100.${NODEID}/24
vppctl set interface l2 bridge loop10 13 bvi
vppctl set interface mac address loop10 00:00:${NODEMACID}:44:44:44
vppctl set interface state loop10 up

ip netns exec dataplane ifconfig bvi_vxlan up
ip netns exec dataplane ip link set dev bvi_vxlan address 00:00:${NODEMACID}:44:44:44


vppctl set bridge-domain arp entry 13 192.168.100.180 00:00:80:44:44:44
vppctl set bridge-domain arp entry 13 192.168.100.181 00:00:81:44:44:44

# node181
#!/usr/bin/bash
export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}


vppctl create bridge-domain 13 learn 1 forward 1 uu-flood 1 flood 1 arp-term 0
vppctl show bridge-domain 13 detail
vppctl create vxlan tunnel src 192.168.203.181 dst 192.168.203.180 vni 666
vppctl set interface l2 bridge vxlan_tunnel0 13 1
vppctl show vxlan tunnel
vppctl show bridge-domain 13 detail

vppctl create loopback interface instance 10
vppctl lcp create loop10 host-if bvi_vxlan
vppctl set interface ip address loop10 192.168.100.${NODEID}/24
vppctl set interface l2 bridge loop10 13 bvi
vppctl set interface mac address loop10 00:00:${NODEMACID}:44:44:44
vppctl set interface state loop10 up

ip netns exec dataplane ifconfig bvi_vxlan up
ip netns exec dataplane ip link set dev bvi_vxlan address 00:00:${NODEMACID}:44:44:44


vppctl set bridge-domain arp entry 13 192.168.100.180 00:00:80:44:44:44
vppctl set bridge-domain arp entry 13 192.168.100.181 00:00:81:44:44:44
```




```shell

route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
router bgp 65000
 bgp router-id 192.168.200.180
 bgp bestpath as-path multipath-relax
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.200.181 peer-group fabric
 !
 address-family ipv4 unicast
  redistribute connected
  redistribute static
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
 exit-address-family
exit
!


route-map IMPORT permit 1
exit
!
route-map EXPORT permit 1
exit
!
router bgp 65000
 bgp router-id 192.168.200.181
 bgp bestpath as-path multipath-relax
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.200.180 peer-group fabric
 !
 address-family ipv4 unicast
  redistribute connected
  redistribute static
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
  neighbor fabric activate
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
  advertise-all-vni
 exit-address-family
!


apt install bridge-utils -y
for vni in 100 200; do
   ip link add vxlan${vni} type vxlan\
   id ${vni}\
   dstport 4789\
   local 192.168.200.180\
   nolearning

   brctl addbr br${vni};
   brctl addif br${vni} vxlan${vni};
   brctl stp br${vni} off;
   ip link set up dev br${vni};
   ip link set up dev vxlan${vni}; 
done

ip tuntap add tap03 mode tap
ip addr add 10.10.10.100/24 dev tap03
ip link set dev tap03 up
brctl addif br100 tap03

ip tuntap add tap02 mode tap
ip addr add 10.10.10.101/24 dev tap02
ip link set dev tap02 up
brctl addif br100 tap02

ip tuntap add tap01 mode tap
ip addr add 10.10.20.100 dev tap01
ip link set up dev tap01
ip link set dev tap01 master br200


apt install bridge-utils -y
for vni in 100 200; do
   ip link add vxlan${vni} type vxlan\
   id ${vni}\
   dstport 4789\
   local 192.168.200.181\
   nolearning

   brctl addbr br${vni};
   brctl addif br${vni} vxlan${vni};
   brctl stp br${vni} off;
   ip link set up dev br${vni};
   ip link set up dev vxlan${vni}; 
done

ip tuntap add tap03 mode tap
ip addr add 10.10.10.100/24 dev tap03
ip link set dev tap03 up
brctl addif br100 tap03

ip tuntap add tap02 mode tap
ip addr add 10.10.10.101/24 dev tap02
ip link set dev tap02 up
brctl addif br100 tap02

ip tuntap add tap01 mode tap
ip addr add 10.10.20.100 dev tap01
ip link set up dev tap01
ip link set dev tap01 master br200

```



```shell

vppctl ip table add 1
vppctl create sub-interfaces NCIC-1-v1 1
vppctl set interface state NCIC-1-v1.1 up
vppctl set interface ip table NCIC-1-v1.1 1

vppctl ip table add 2
vppctl create sub-interfaces NCIC-1-v1 2
vppctl set interface state NCIC-1-v1.2 up
vppctl set interface ip table NCIC-1-v1.2 2
vppctl set interface ip address NCIC-1-v1.2 10.10.203.19/29
vppctl ip route add 198.19.255.248/29 table 2 via 198.19.255.249 next-hop-table 4093



vppctl show vxlan tunnel
vppctl show bridge-domain 13 detail

>>>> vpp# show vxlan tunnel
>>>> [0] instance 0 src 192.168.203.180 dst 192.168.203.181 src_port 4789 dst_port 4789 vni 666 fib-idx 0 sw-if-idx 7 encap-dpo-idx 7
>>>> vpp# show bridge-domain 13 detail
>>>>   BD-ID   Index   BSN  Age(min)  Learning  U-Forwrd   UU-Flood   Flooding  ARP-Term  arp-ufwd Learn-co Learn-li   BVI-Intf
>>>>    13       2      0     off        on        on       flood        on       off       off        1    16777216    loop10
>>>> span-l2-input l2-input-classify l2-input-feat-arc l2-policer-classify l2-input-acl vpath-input-l2 l2-ip-qos-record l2-input-vtr >>>> l2-learn l2-rw l2-fwd l2-flood l2-flood l2-output
>>>> 
>>>>            Interface           If-idx ISN  SHG  BVI  TxFlood        VLAN-Tag-Rewrite
>>>>             loop10               8     1    0    *      *                 none
>>>>          vxlan_tunnel0           7     1    1    -      *                 none
>>>> vpp# show interface address
>>>> GigabitEthernet3/2/0 (dn):
>>>> GigabitEthernet3/3/0 (up):
>>>> GigabitEthernet3/3/0.800 (up):
>>>>   L2 bridge bd-id 1 idx 1 shg 0
>>>> GigabitEthernet3/4/0 (dn):
>>>> local0 (dn):
>>>> loop10 (up):
>>>>   L2 bridge bd-id 13 idx 2 shg 0 bvi
>>>>   L3 192.168.100.180/24 ip4 table-id 2 fib-idx 1
>>>> loop1 (up):
>>>>   L2 bridge bd-id 1 idx 1 shg 0 bvi
>>>>   L3 192.168.203.180/24
>>>> tap4 (up):
>>>> tap7 (up):
>>>> vxlan_tunnel0 (up):
>>>>   L2 bridge bd-id 13 idx 2 shg 1
>>>> vpp# show ip table
>>>> [0] table_id:0 ipv4-VRF:0
>>>> [1] table_id:2 ipv4-VRF:2

>>>> vpp# show ip fib table 2
>>>> ipv4-VRF:2, fib_index:1, flow hash:[src dst sport dport proto flowlabel ] epoch:0 flags:none locks:[interface:3, CLI:1, adjacency:1, ]
>>>> 0.0.0.0/0
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:9 buckets:1 uRPF:7 to:[0:0]]
>>>>     [0] [@0]: dpo-drop ip4
>>>> 0.0.0.0/32
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:10 buckets:1 uRPF:8 to:[0:0]]
>>>>     [0] [@0]: dpo-drop ip4
>>>> 192.168.100.0/32
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:23 buckets:1 uRPF:28 to:[0:0]]
>>>>     [0] [@0]: dpo-drop ip4
>>>> 192.168.100.0/24
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:22 buckets:1 uRPF:31 to:[0:0]]
>>>>     [0] [@4]: ipv4-glean: [src:192.168.100.0/24] loop10: mtu:9000 next:2 flags:[] ffffffffffff0000804444440806
>>>> 192.168.100.180/32
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:25 buckets:1 uRPF:32 to:[2:168]]
>>>>     [0] [@12]: dpo-receive: 192.168.100.180 on loop10
>>>> 192.168.100.181/32
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:26 buckets:1 uRPF:23 to:[0:0]]
>>>>     [0] [@5]: ipv4 via 192.168.100.181 loop10: mtu:9000 next:6 flags:[] 0000814444440000804444440800
>>>> 192.168.100.255/32
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:24 buckets:1 uRPF:30 to:[0:0]]
>>>>     [0] [@0]: dpo-drop ip4
>>>> 224.0.0.0/4
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:12 buckets:1 uRPF:10 to:[0:0]]
>>>>     [0] [@0]: dpo-drop ip4
>>>> 240.0.0.0/4
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:11 buckets:1 uRPF:9 to:[0:0]]
>>>>     [0] [@0]: dpo-drop ip4
>>>> 255.255.255.255/32
>>>>   unicast-ip4-chain
>>>>   [@0]: dpo-load-balance: [proto:ip4 index:13 buckets:1 uRPF:11 to:[0:0]]
>>>>     [0] [@0]: dpo-drop ip4
>>>> vpp#

```




```shell

vppctl mpls table add 0
vppctl set interface mpls GigabitEthernet3/3/0.800 enable



vpp0-2# conf t
no mpls ldp
mpls ldp
 router-id 192.168.203.180
 dual-stack cisco-interop
 ordered-control
 !
 address-family ipv4
  discovery transport-address 192.168.203.180
  label local advertise explicit-null
  interface e0800
 exit-address-family
 !
 

no mpls ldp
 mpls ldp
 router-id 192.168.203.181
 dual-stack cisco-interop
 ordered-control
 !
 address-family ipv4
  discovery transport-address 192.168.203.181
  label local advertise explicit-null
  interface e0800
 exit-address-family
 !

```



```shell
ipng@vpp0-1:~$ cat << EOF | tee -a /etc/vpp/config/manual.vpp
mpls table add 0
set interface mpls GigabitEthernet10/0/0 enable
set interface mpls GigabitEthernet10/0/1 enable
EOF





# BUILD VPP and install from source deb
```shell
export DEBIAN_FRONTEND=noninteractive

apt install python3-pip linux-virtual-hwe-22.04 make cmake gcc linux-modules-extra-5.19.0-42-generic -y
mkdir -p /var/log/vpp/ && chmod 777 -R /var/log/vpp/
apt autoremove -y
reboot


apt-get install libmnl-dev
mkdir ~/src
cd ~/src
git clone https://gerrit.fd.io/r/vpp
cd vpp
git checkout stable/2306
cd ..
git clone https://github.com/pimvanpelt/lcpng.git
ln -s ~/src/lcpng ~/src/vpp/src/plugins/lcpng
cd ~/src/vpp
#
build-root/vagrant/build.sh
# or
make install-dep
make install-ext-deps
make build


>>> root@node180:~/vpp# ls -la /root/vpp/build-root/*.deb
>>> -rw-r--r-- 1 root root   197444 мая 26 10:03 /root/vpp/buil

```









```
