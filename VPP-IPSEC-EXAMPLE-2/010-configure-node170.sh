#!/usr/bin/bash

set -x

cat <<EOF>>/etc/netplan/00-installer-config.yaml
    enp1s0.801:
      addresses:
      - 172.16.0.170/24
      dhcp4: false
      dhcp6: false
      id: 801
      link: enp1s0
EOF

netplan apply

route add -net 192.168.0.0/24 gw 172.16.0.171
