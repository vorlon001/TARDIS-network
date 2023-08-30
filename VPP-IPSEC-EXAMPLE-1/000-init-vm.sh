#!/usr/bin/bash

export DEBIAN_FRONTEND=noninteractive
wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 && chmod +x yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq
wget  https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 && chmod +x yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq2
yq2 delete -i /etc/netplan/00-installer-config.yaml network.vlans.["enp1s0.800"]
yq2 delete -i /etc/netplan/00-installer-config.yaml network.vlans.["enp1s0.600"]


cat /etc/netplan/00-installer-config.yaml
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
cp /etc/netplan/00-installer-config.yaml 000-netplan-${NODEID}.yaml

apt install python3-pip linux-virtual-hwe-22.04 make cmake gcc linux-modules-extra-5.19.0-42-generic git -y
mkdir -p /var/log/vpp/ && chmod 777 -R /var/log/vpp/
apt autoremove -y
reboot

