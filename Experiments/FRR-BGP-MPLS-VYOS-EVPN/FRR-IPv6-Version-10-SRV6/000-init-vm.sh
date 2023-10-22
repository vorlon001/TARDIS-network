#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive
apt install python3-pip linux-modules-extra-6.2.0-20-generic make cmake gcc git -y
mkdir -p /var/log/vpp/ && chmod 777 -R /var/log/vpp/
snap remove lxd
snap remove core22
snap remove snapd
apt remove -y snapd
rm /etc/netplan/50-cloud-init.yaml
apt autoremove -y

cat <<EOF>>/etc/netplan/00-installer-config.yaml
    vrfs:
      vrf1:
        table: 10
        interfaces:
          - enp1s0.600
          - enp1s0.800
EOF
reboot

