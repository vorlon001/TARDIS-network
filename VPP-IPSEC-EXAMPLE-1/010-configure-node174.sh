#!/usr/bin/bash

set -x

cat <<EOF>>/etc/netplan/00-installer-config.yaml
    enp1s0.804:
      addresses:
      - 192.168.0.174/24
      dhcp4: false
      dhcp6: false
      id: 804
      link: enp1s0
EOF


netplan apply


route add -net 172.16.0.0/24 gw 192.168.0.173
