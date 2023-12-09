```
apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top
apt install cloud-image-utils -y

```
```

       /etc/netplan/00-installer-config.yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        enp1s0:
            dhcp4: false
            dhcp6: false
            match:
                macaddress: fa:16:3e:ca:2a:4b
                name: enp*s0
            set-name: enp1s0
    version: 2
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.130/24
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



```

### attach interface in vm node188
```


vppctl create tap host-if-name vmvpp10
vppctl create tap host-if-name vmvpp20
vppctl set interface state tap2 up
vppctl set interface state tap3 up

vppctl set interface unnumbered tap2 use loop10
vppctl set interface unnumbered tap3 use loop10

vppctl set interface proxy-arp tap2 enable
vppctl set interface proxy-arp tap3 enable


vppctl create tap host-if-name vmvpp30
vppctl create tap host-if-name vmvpp40
vppctl set interface state tap4 up
vppctl set interface state tap5 up

vppctl set interface unnumbered tap4 use loop10
vppctl set interface unnumbered tap5 use loop10

vppctl set interface proxy-arp tap4 enable
vppctl set interface proxy-arp tap5 enable

vppctl ip route add 192.168.44.188/32 via tap4
vppctl ip route add 192.168.44.189/32 via tap5


### attach interface or start vm xml-config

    <interface type='direct' trustGuestRxFilters='yes'>
      <mac address='52:54:40:5d:d7:9e'/>
      <source dev='vmvpp40' mode='vepa'/>
      <model type='e1000'/>
      <address type='pci' domain='0x0000' bus='0x12' slot='0x01' function='0x0'/>
    </interface>

###

ifconfig eth3 up
ip addr add 192.168.44.188/32 dev eth3
route add default dev eth3


```
