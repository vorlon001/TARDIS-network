### Create 4 vm ubuntu 22.04. create vm https://github.com/vorlon001/libvirt-home-labs/tree/v2
- network one: Virtio network device
- network two: e1000
- network three: e1000
- network four: e1000
- all network attach to switch ovs, mode trunk

### Network VM Ubuntu 22.04LTS

```shell

root@node170:~# lshw -class network -businfo
Bus info          Device      Class          Description
========================================================
pci@0000:01:00.0              network        Virtio network device
virtio@0          enp1s0      network        Ethernet interface
pci@0000:03:01.0  enp2s0      network        82540EM Gigabit Ethernet Controller
pci@0000:03:02.0  ens2f0      network        82540EM Gigabit Ethernet Controller
pci@0000:03:03.0  ens3f0      network        82540EM Gigabit Ethernet Controller
pci@0000:03:04.0  ens4f0      network        82540EM Gigabit Ethernet Controller
root@node170:~#
```

### netplan config example

```yaml
network:
    ethernets:
        enp1s0:
            dhcp4: false
            match:
                macaddress: fa:16:3e:9b:b6:d6
                name: enp*s0
            set-name: enp1s0
        enp2s0:
            dhcp4: false
            match:
                macaddress: fa:16:3e:fe:e1:c8
                name: enp*s0
            set-name: enp2s0
    version: 2
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.170/24
            dhcp4: false
            dhcp6: false
            gateway4: 192.168.200.1
            id: 200
            link: enp1s0
            nameservers:
                addresses:
                - 192.168.1.10
                search:
                - cloud.local
        enp1s0.400:
            addresses:
            - 192.168.201.170/24
            dhcp4: false
            dhcp6: false
            id: 400
            link: enp1s0
        enp1s0.600:
            addresses:
            - 192.168.202.170/24
            dhcp4: false
            dhcp6: false
            id: 600
            link: enp1s0
        enp1s0.800:
            addresses:
            - 192.168.203.170/24
            dhcp4: false
            dhcp6: false
            id: 800
            link: enp1s0
```shell


# TEST 20.1 WORK
# ------------- 

```shell

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-add net180 br300
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-addresses br300 "40:44:70:66:66:03 192.168.80.101"

function ovn_add_phys_port_1 {
    name=$1
    docker exec -it ovs-vswitchd ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}
ovn_add_phys_port_1 br300 40:44:70:66:66:03

ip link add ve_A type veth peer name ve_B
ip link set ve_A up
ip link set ve_B up

ifconfig bvi300 up

ip netns add zone1

ip link set ve_A netns zone1
ip link set br300 netns zone1
ip netns exec zone1 ip link add bvi300 type bridge
ip netns exec zone1 ifconfig ve_A up 
ip netns exec zone1 ifconfig br300 up
ip netns exec zone1 ifconfig bvi300 up
ip netns exec zone1 ip link show

ip netns add zone2
ip link set ve_B netns zone2
ip netns exec zone2 ifconfig ve_B up
ip netns exec zone2 ip link show

ip netns exec zone1 ip link set br300 master bvi300
ip netns exec zone1 ip link set ve_A master bvi300

ip netns exec zone1 ip link set bvi300 address 40:44:70:88:66:03
ip netns exec zone2 ip link set ve_B address 40:44:70:66:66:03
ip netns exec zone2 ifconfig ve_B 192.168.80.101/24

ip netns exec vm1 ping 192.168.80.1 -c 5


root@node180:~# ip netns exec vm1 ping 192.168.80.101

```




# TEST 20.2 WORK EVPN
# ------------- 


# node 150
```shell
bridge fdb 
tcpdump -ni enp1s0.200 port 4789

sudo ip link add vbdif10 type bridge
sudo ip link add vbdif20 type bridge
sudo ip link set vbdif10 up
sudo ip link set vbdif20 up
sudo ip link add vxlan20 type vxlan id 20 local 192.168.200.150 dstport 4789 nolearning
sudo ip link add vxlan10 type vxlan id 10 local 192.168.200.150 dstport 4789 nolearning
sudo ip link set vxlan10 up
sudo ip link set vxlan20 up
sudo ip link set vxlan20 master vbdif20
sudo ip link set vxlan10 master vbdif10
sudo ip address add 192.168.70.66/24 dev vbdif10
sudo ip address add 192.168.80.66/24 dev vbdif20

echo 1 > /proc/sys/net/ipv4/ip_forward

ip link set dev vbdif10 address 40:44:70:66:00:66
ip link set dev vbdif20 address 40:44:80:66:00:66
```

# ------------- 

# node 170

```shell
sudo ip link add br10 type bridge
sudo ip link add vxlan10 type vxlan id 10 local 192.168.200.180 dstport 4789 nolearning
sudo ip link set br10 up
sudo ip link set vxlan10 up
sudo ip link set vxlan10 master br10

echo 1 > /proc/sys/net/ipv4/ip_forward
```

# ------------- 

# node 180

```shell

sudo ip link add br10 type bridge
sudo ip link add vxlan20 type vxlan id 20 local 192.168.200.180 dstport 4789 nolearning
sudo ip link set br10 up
sudo ip link set vxlan20 up
sudo ip link set vxlan20 master br10

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-add net180 br300
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-addresses br300 "40:44:80:66:00:66 192.168.80.66"

function ovn_add_phys_port_1 {
    name=$1
    docker exec -it ovs-vswitchd ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}
ovn_add_phys_port_1 br300 40:44:80:66:00:66

ip netns add zone1

ip link set br300 netns zone1
ip netns exec zone1 ip link add bvi300 type bridge
ip netns exec zone1 ifconfig br300 up
ip netns exec zone1 ifconfig bvi300 up
ip netns exec zone1 ip link show

ip netns exec zone1 ip link set br300 master bvi300
ip netns exec zone1 ip link set bvi300 address 40:44:70:88:66:03


ip link add vxlan20 type vxlan id 20 local 192.168.200.180 dstport 4789 nolearning
ip link set vxlan20 netns zone1
ip netns exec zone1 ip link set vxlan20 master bvi300
ip netns exec zone1 ip link set vxlan20 up

#node 180
ip netns exec vm1 ping 192.168.80.1 -c 5
#node150
ping 192.168.80.11

root@node180:~# ip netns exec vm1 ping 192.168.80.101

```
