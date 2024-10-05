#!/usr/bin/bash

export NODEID=170
cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.original
cat <<EOF>/etc/netplan/50-cloud-init.yaml
network:
  ethernets:
    enp1s0:
      dhcp4: false
      dhcp6: false
      match:
        macaddress: $(ip link show enp1s0 | grep link/ether | awk '{print $2}')
        name: enp*s0
      set-name: enp1s0
    enp2s0:
      dhcp4: false
      dhcp6: false
      match:
        macaddress: $(ip link show enp2s0 | grep link/ether | awk '{print $2}')
        name: enp*s0
      set-name: enp2s0
  version: 2
  vlans:
    enp1s0.200:
      addresses:
      - 192.168.200.${NODEID}/24
      dhcp4: false
      dhcp6: false
      id: 200
      link: enp1s0
      nameservers:
        addresses:
        - 192.168.1.10
        search:
        - cloud.local
    enp1s0.31:
      addresses:
      - 192.168.31.${NODEID}/24
      dhcp4: false
      dhcp6: false
      gateway4: 192.168.31.171
      id: 31
      link: enp1s0
EOF
reboot
