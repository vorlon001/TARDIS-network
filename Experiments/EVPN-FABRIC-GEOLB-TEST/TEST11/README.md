### TEST 11

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
        interfaces: [vxlan10]
      vbdif20:
        dhcp4: false
        dhcp6: false
        addresses: [2.2.2.254/24]
        interfaces: [vxlan20]

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

```
