#!/usr/bin/bash

mkdir -p /cloud/KVM/VYOS
cd /cloud/KVM/VYOS

touch meta-data
#touch network-config-node188

MAC_ADDR_200=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
MAC_ADDR_400=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
echo $MAC_ADDR_200 $MAC_ADDR_400
#touch network-config-node188

cat >network-config-node188 <<EOF
---
version: 1
config:
- type: physical
  name: eth0
  mac_address: $MAC_ADDR_200
- type: physical
  name: eth1
  mac_address: $MAC_ADDR_400
EOF

cat <<EOF>vyos-user-data-188
#cloud-config
vyos_config_commands:
- set service ssh port 22
- set system login user vyos authentication encrypted-password '\$6\$K4lzAIXncuBdwzjb\$2DLRUjkEO.LyVPkvve5kz0k7UYsK5gFqMKxMMlhh8Wppf75Eq9UcdLecTNJDRztCdhgTixPFoSr3PZm291ehi0'
- set system login user vyos authentication plaintext-password vyos
- set interfaces ethernet eth0 address '192.168.44.188/24'
- set interfaces ethernet eth0 description 'uplink............'
- set system host-name 'node188'
- set system login banner pre-login 'VyOS router NODE188'
EOF


cp vyos-user-data-188 vyos-user-data
cloud-localds -v --network-config=network-config-node188 node188-seed.qcow2 vyos-user-data meta-data
rm vyos-user-data

#cp vyos-1.4-rolling-202205110618-amd64.qcow2 vyos-node188.qcow2
#cp  vyos-1.3-rolling-202205141638-amd64.qcow2 vyos-node188.qcow2
#cp vyos-1.4-rolling-202205130217-amd64.qcow2 vyos-node188.qcow2
#cp vyos-1.4-rolling-202205110618-amd64.qcow2vyos-node188.qcow2
cp vyos-1.4.0-28122022-amd64.qcow2 vyos-node188.qcow2

virt-install -n node188 \
  --ram 4096 \
  --vcpus 2 \
  --cpu host-model \
  --os-variant debian11 \
  --graphics vnc \
  --hvm \
  --disk path=/cloud/KVM/VYOS/vyos-node188.qcow2,bus=virtio,size=10 \
  --disk path=/cloud/KVM/VYOS/node188-seed.qcow2,device=disk  \
  --noautoconsole  --boot  hd

virsh autostart node188

virsh console node188
