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

sysctl -w vm.max_map_count=262144 || throw ${LINENO}
echo "vm.max_map_count = 262144" > /etc/sysctl.d/99-docker-desktop.conf || throw ${LINENO}



apt -y install cgroup-tools cpuset cgroup-tools sysstat nmon || throw ${LINENO}
#apt -y install cgroup-tools cpuset cgroup-tools cgroupfs-mount libcgroup1 sysstat nmon || throw ${LINENO}
sed -i -e 's|GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200 consoleblank=0"|GRUB_CMDLINE_LINUX="ipv6.disable=1 console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200 consoleblank=0 cgroup_enable=cpuset cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1"|' /etc/default/grub || throw ${LINENO}
cat /etc/default/grub || throw ${LINENO}
update-grub || throw ${LINENO}
shutdown -r 1 "reboot" || throw ${LINENO}
