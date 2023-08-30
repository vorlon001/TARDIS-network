#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive
apt install python3-pip linux-virtual-hwe-22.04 make cmake gcc linux-modules-extra-5.19.0-42-generic git -y
mkdir -p /var/log/vpp/ && chmod 777 -R /var/log/vpp/
apt autoremove -y
reboot

