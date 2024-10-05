#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive

export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
cp /etc/netplan/00-installer-config.yaml /root/000-netplan-${NODEID}.yaml


apt install python3-pip make cmake gcc git -y

apt autoremove -y

reboot

