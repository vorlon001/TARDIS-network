#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive

git clone https://github.com/pimvanpelt/vppcfg
pip3 install ./vppcfg


curl -s https://packagecloud.io/install/repositories/fdio/2306/script.deb.sh | sudo bash
apt-get install vpp vpp-plugin-core vpp-plugin-dpdk vpp-dbg vpp-dev vpp-ext-deps python3-vpp-api -y


cat <<EOF>>/etc/vpp/startup.conf
plugins {
  plugin linux_cp_plugin.so { enable }
  plugin nsh_plugin.so { disable }
}
EOF

reboot

