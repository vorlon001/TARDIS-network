#!/usr/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
export NODEMACID=${NODEID: -2:2}
echo ${NODEID}
echo ${NODEMACID}


cat <<EOF>>/etc/netplan/00-installer-config.yaml
    enp1s0.801:
      addresses:
      - 172.16.0.171/24
      dhcp4: false
      dhcp6: false
      id: 801
      link: enp1s0
EOF


cat <<EOF>>/etc/netplan/00-installer-config.yaml
    enp1s0.802:
      addresses:
      - 10.100.0.171/24
      dhcp4: false
      dhcp6: false
      id: 802
      link: enp1s0
EOF


netplan apply
