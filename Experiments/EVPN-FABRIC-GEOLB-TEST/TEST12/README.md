

![](https://programmer.group/images/article/005d3759312e4aa2f43a0ed183cd6a83.jpg)


original: https://programmer.group/frr-learning-day-9-complete-data-center-network-model.html


### VM: debian 12
```
[node140LEAF]-----(vlan400)----------[node141:SPEAN]--------(vlan800)----------[node143:LEAF]
    |                                      |
    |                                      |
 (vlan 35)                             (vlan600)
    |                                      |
    |                                      |
  [node142:CE]                      [node142:LEAF]
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


### TEST 12

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


sudo ip link set veth1 up
sudo ip link set veth3 up
sudo ip link set veth1 master vbdif10
sudo ip link set veth3 master vbdif20
```

```
network:
    version: 2
    vlans:
        enp1s0.35:
          dhcp4: false
          dhcp6: false
          id: 35
          link: enp1s0
    tunnels:
      vxlan10:
        mode: vxlan
        id: 10
        accept-ra: no
        neigh-suppress: true
        link-local: []
        mac-learning: false
        port: 4789
        local: 192.168.201.140
      vxlan20:
        mode: vxlan
        id: 20
        accept-ra: no
        neigh-suppress: true
        link-local: []
        mac-learning: false
        port: 4789
        local: 192.168.201.140
    bridges:
      vbdif10:
        dhcp4: false
        dhcp6: false
        addresses: [1.1.1.254/24]
        interfaces: [vxlan10,enp1s0.35]
      vbdif20:
        dhcp4: false
        dhcp6: false
        addresses: [2.2.2.254/24]
        interfaces: [vxlan20]
    vrfs:
      BLUE:
        table: 10
        interfaces:
          - vbdif10
          - vbdif20

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
sudo ip netns exec host2 ip addr add 3.3.3.3/24 dev lo:10
sudo ip netns exec host2 ip route add default via 2.2.2.254 dev eth2


sudo ip link set veth1 up
sudo ip link set veth3 up
sudo ip link set veth1 master vbdif10
sudo ip link set veth3 master vbdif20
```


```
network:
    version: 2
    tunnels:
      vxlan10:
        mode: vxlan
        id: 10
        accept-ra: no
        neigh-suppress: true
        link-local: []
        mac-learning: false
        port: 4789
        local: 192.168.202.142
      vxlan20:
        mode: vxlan
        id: 20
        accept-ra: no
        neigh-suppress: true
        link-local: []
        mac-learning: false
        port: 4789
        local: 192.168.202.142
    bridges:
      vbdif10:
        dhcp4: false
        dhcp6: false
        addresses: [1.1.1.254/24]
        interfaces: [vxlan10]
      vbdif20:
        dhcp4: false
        dhcp6: false
        addresses: [2.2.2.254/24]
        interfaces: [vxlan20]
    vrfs:
      BLUE:
        table: 10
        interfaces:
          - vbdif10
          - vbdif20

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


sudo ip link set veth1 up
sudo ip link set veth3 up
sudo ip link set veth1 master vbdif10
sudo ip link set veth3 master vbdif20
```



```
network:
    version: 2
    tunnels:
      vxlan10:
        mode: vxlan
        id: 10
        accept-ra: no
        neigh-suppress: true
        link-local: []
        mac-learning: false
        port: 4789
        local: 192.168.203.143
      vxlan20:
        mode: vxlan
        id: 20
        accept-ra: no
        neigh-suppress: true
        link-local: []
        mac-learning: false
        port: 4789
        local: 192.168.203.143
    bridges:
      vbdif10:
        dhcp4: false
        dhcp6: false
        addresses: [1.1.1.254/24]
        interfaces: [vxlan10]
      vbdif20:
        dhcp4: false
        dhcp6: false
        addresses: [2.2.2.254/24]
        interfaces: [vxlan20]
    vrfs:
      BLUE:
        table: 10
        interfaces:
          - vbdif10
          - vbdif20

```
