#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive

git clone https://github.com/pimvanpelt/vppcfg
pip3 install ./vppcfg


curl -s https://packagecloud.io/install/repositories/fdio/2310/script.deb.sh | sudo bash
apt-get install vpp vpp-plugin-core vpp-plugin-dpdk vpp-dbg vpp-dev vpp-ext-deps python3-vpp-api -y


cat <<EOF>/etc/vpp/startup.conf
unix {
  nodaemon
  log /var/log/vpp/vpp.log
  full-coredump
  cli-listen /run/vpp/cli.sock
  gid vpp
}

api-trace {
  on
}

api-segment {
  gid vpp
}

socksvr {
  default
}

cpu {
}

plugins {
  plugin linux_cp_plugin.so { enable }
  plugin nsh_plugin.so { disable }
}
EOF


echo "vfio" >> /etc/modules
echo "vfio_pci" >> /etc/modules

reboot

