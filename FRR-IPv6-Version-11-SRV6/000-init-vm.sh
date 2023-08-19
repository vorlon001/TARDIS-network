#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive
apt install python3-pip linux-virtual-hwe-22.04 make cmake gcc linux-modules-extra-5.19.0-43-generic git -y
mkdir -p /var/log/vpp/ && chmod 777 -R /var/log/vpp/
snap remove lxd
snap remove core20
snap remove core22
snap remove snapd
apt remove -y snapd
rm /etc/netplan/50-cloud-init.yaml
apt autoremove -y

cat <<EOF>/etc/systemd/network/vrf1.netdev
[NetDev]
Name=vrf1
Kind=vrf
 [VRF]
Table=10
EOF

cat <<EOF>/etc/systemd/network/6-vrf.network
[Match]
Name=vrf*

[Link]
ActivationPolicy=up
RequiredForOnline=no
EOF

cat <<EOF>>/etc/netplan/00-installer-config.yaml
    vrfs:
      vrf1:
        table: 10
        interfaces:
          - enp1s0.600
          - enp1s0.800
EOF
reboot

