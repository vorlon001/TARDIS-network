
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


### TEST 10

### node140



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
```


```
root@node140:~# vtysh

Hello, this is FRRouting (version 10.1.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

node140# sh run
Building configuration...

Current configuration:
!
frr version 10.1.1
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
 neighbor fabric peer-group
 neighbor fabric remote-as 65000
 neighbor 192.168.201.141 peer-group fabric
 !
 address-family ipv4 unicast
  neighbor fabric route-map IMPORT in
  neighbor fabric route-map EXPORT out
 exit-address-family
 !
 address-family l2vpn evpn
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
end
node140#

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
                macaddress: fa:16:3e:ae:e9:c7
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:ca:d5:7a
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
        enp1s0.600:
            addresses:
            - 192.168.202.140/24
            id: 600
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
        enp1s0.800:
            addresses:
            - 192.168.203.140/24
            id: 800
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
root@node140:~#

```

### node141


```
node141# sh run
Building configuration...

Current configuration:
!
frr version 10.1.1
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
end
node141#

root@node141:~# cat /etc/netplan/50-cloud-init.yaml
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
                macaddress: fa:16:3e:02:13:7f
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:ce:52:0e
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

### node142


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
```


```
node142# sh run
Building configuration...

Current configuration:
!
frr version 10.1.1
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
end
node142#

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
                macaddress: fa:16:3e:4f:b0:7b
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:ae:a9:a4
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
        enp1s0.400:
            addresses:
            - 192.168.201.142/24
            id: 400
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
        enp1s0.600:
            addresses:
            - 192.168.202.142/24
            id: 600
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
        enp1s0.800:
            addresses:
            - 192.168.203.142/24
            id: 800
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
root@node142:~#

```

### node143


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

```

```
node143# sh run
Building configuration...

Current configuration:
!
frr version 10.1.1
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
end
node143#

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
                macaddress: fa:16:3e:be:47:b3
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:a7:5e:2e
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
        enp1s0.400:
            addresses:
            - 192.168.201.143/24
            id: 400
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
        enp1s0.600:
            addresses:
            - 192.168.202.143/24
            id: 600
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
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
