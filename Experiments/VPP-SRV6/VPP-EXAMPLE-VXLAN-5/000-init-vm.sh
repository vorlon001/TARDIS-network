#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive
apt install python3-pip linux-virtual-hwe-22.04 make cmake gcc git -y
apt install linux-modules-extra-6.2.0-37-generic -y
mkdir -p /var/log/vpp/ && chmod 777 -R /var/log/vpp/
apt autoremove -y
reboot

