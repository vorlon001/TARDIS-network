#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive

export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
cp /etc/netplan/00-installer-config.yaml /root/000-netplan-${NODEID}.yaml


apt install python3-pip linux-modules-extra-$(uname -r) make cmake gcc git -y

snap remove lxd
snap remove core22
snap remove snapd
apt remove -y snapd
apt autoremove -y

reboot

