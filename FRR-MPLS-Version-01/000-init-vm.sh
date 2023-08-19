#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive

wget  https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 && chmod +x yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq2
yq2 delete -i /etc/netplan/00-installer-config.yaml network.vlans.["enp1s0.600"]
yq2 delete -i /etc/netplan/00-installer-config.yaml network.vlans.["enp1s0.400"]


cat /etc/netplan/00-installer-config.yaml
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
cp /etc/netplan/00-installer-config.yaml 000-netplan-${NODEID}.yaml


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
        - enp1s0.800
EOF
reboot

