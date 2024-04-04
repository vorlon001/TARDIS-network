#!/usr/bin/bash

function throw()
{
   errorCode=$?
   echo "Error: ($?) LINENO:$1"
   exit $errorCode
}

function check_error {
  if [ $? -ne 0 ]; then
    echo "Error: ($?) LINENO:$1"
    exit 1
  fi
}


sed  -i 's|APT::Periodic::Unattended-Upgrade \"1\";|APT::Periodic::Unattended-Upgrade \"0\";|' /etc/apt/apt.conf.d/20auto-upgrades || throw ${LINENO}
cat  /etc/apt/apt.conf.d/20auto-upgrades || throw ${LINENO}

export DEBIAN_FRONTEND=noninteractive || throw ${LINENO}
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf || throw ${LINENO}
apt remove snapd -y || throw ${LINENO}


sysctl -w vm.max_map_count=512000 || throw ${LINENO}
echo "vm.max_map_count = 262144" > /etc/sysctl.d/99-docker-desktop.conf || throw ${LINENO}



apt -y install cgroup-tools cpuset cgroup-lite cgroup-tools cgroupfs-mount sysstat nmon || throw ${LINENO}
sed -i -e 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="cgroup_enable=cpuset cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1"|' /etc/default/grub || throw ${LINENO}
cat /etc/default/grub || throw ${LINENO}
update-grub || throw ${LINENO}
shutdown -r 1 "reboot" || throw ${LINENO}



