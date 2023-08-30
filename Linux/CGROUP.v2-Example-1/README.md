

```shell

ps --ppid 2 -p 2 -o uname,pid,ppid,cmd,cls,psr --deselect

```



```shell


sed  -i 's|APT::Periodic::Unattended-Upgrade \"1\";|APT::Periodic::Unattended-Upgrade \"0\";|' /etc/apt/apt.conf.d/20auto-upgrades
cat  /etc/apt/apt.conf.d/20auto-upgrades

export DEBIAN_FRONTEND=noninteractive
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
apt remove snapd -y


sysctl -w vm.max_map_count=262144
echo "vm.max_map_count = 262144" > /etc/sysctl.d/99-docker-desktop.conf

apt -y install cgroup-tools cpuset cgroup-lite cgroup-tools cgroupfs-mount libcgroup1 sysstat nmon
sed -i -e 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="cgroup_enable=cpuset cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1"|' /etc/default/grub
cat /etc/default/grub
update-grub
shutdown -r 1 "reboot"


systemctl set-property user.slice MemoryMax=1G
systemctl set-property init.scope MemoryMax=1G
systemctl set-property system.slice MemoryMax=1G
systemctl set-property nginx.service MemoryMax=2G

systemctl set-property user.slice AllowedCPUs=0-2
systemctl set-property init.scope AllowedCPUs=0-2
systemctl set-property system.slice AllowedCPUs=3-3
systemctl set-property nginx.service AllowedCPUs=4-5



systemctl show --property MemoryMax user.slice
systemctl show --property MemoryMax init.scope
systemctl show --property MemoryMax system.slice
systemctl show --property MemoryMax nginx.service

systemctl show --property AllowedCPUs user.slice
systemctl show --property AllowedCPUs init.scope
systemctl show --property AllowedCPUs system.slice
systemctl show --property AllowedCPUs nginx.service


# systemctl set-property example.service MemoryMax=1500K
# systemctl set-property service_name.service AllowedCPUs=0-5
# systemctl set-property <service name> CPUAffinity=<value>

```


```shell

stat -c %T -f /sys/fs/cgroup
cgroup2fs

cat <<EOF>/etc/cgconfig.conf
group system.slice {
        cpuset {
                cpuset.cpus.partition="member";
                cpuset.mems="";
                cpuset.cpus="2";
        }
}
group user.slice {
        cpuset {
                cpuset.cpus.partition="member";
                cpuset.mems="";
                cpuset.cpus="0-1";
        }
}
group nginx.service {
        cpuset {
                cpuset.cpus.partition="member";
                cpuset.mems="";
                cpuset.cpus="3-4";
                pids.max = 60;
        }
        memory {
                memory.max = 2147483648;
        }
}
EOF

cgconfigparser -l /etc/cgconfig.conf
cat /sys/fs/cgroup/system.slice/cpuset.cpus


cat <<EOF>/etc/systemd/system/cgconfigparser.service
[Unit]
Description=cgroup config parser
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/sbin/cgconfigparser -l /etc/cgconfig.conf
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
sudo systemctl enable cgconfigparser --now


systemctl edit nginx.slice
......
[Unit]
Description=Nginx Slice
Before=slices.target

[Slice]
MemoryAccounting=yes
CPUAccounting=yes
IOAccounting=yes
TasksAccounting=yes
......

systemctl edit nginx.slice
......
[Unit]
Description=Nginx Slice
Before=slices.target
......


[Slice]
MemoryAccounting=true
MemoryLimit=2048M
CPUAccounting=true
CPUQuota=25%
TasksMax=4096


nano /usr/lib/systemd/system/nginx.service
and add in the [Service] section:
Slice=nginx.slice

echo "128M" >/sys/fs/cgroup/nginx.slice/memory.max

```

```shell

user.slice  init.scope  system.slice

# systemctl set-property example.service MemoryMax=1500K
# systemctl set-property service_name.service AllowedCPUs=0-5
# systemctl set-property <service name> CPUAffinity=<value>




Use any of the memory configuration options (MemoryMin, MemoryLow, MemoryHigh, MemoryMax, MemorySwapMax) 
to allocate memory resources using systemd.

$ systemctl show --property <memory allocation configuration option> <service name>
# systemctl set-property <service name> <memory allocation configuration option>=<value>


The command instantly assigns the memory limit of 1,500 KB to processes executed in a control group the example.service 
service belongs to. The MemoryMax parameter, in this configuration variant, is defined in 
the /etc/systemd/system.control/example.service.d/50-MemoryMax.conf file and controls the value of the
/sys/fs/cgroup/memory/system.slice/example.service/memory.limit_in_bytes file.

Optionally, to temporarily limit the memory usage of a service, run:
# systemctl set-property --runtime example.service MemoryMax=1500K


Procedure
To limit the memory usage of a service, modify the /usr/lib/systemd/system/example.service file as follows:
…​
[Service]
MemoryMax=1500K
…​
Reload all unit configuration files:

# systemctl daemon-reload
Restart the service:

# systemctl restart example.service
Reboot the system.
Optionally, check that the changes took effect:

# cat /sys/fs/cgroup/memory/system.slice/example.service/memory.limit_in_bytes
1536000


27.5. Allocating memory resources using systemd
Use any of the memory configuration options (MemoryMin, MemoryLow, MemoryHigh, MemoryMax, MemorySwapMax) to allocate memory resources using systemd.

Procedure

To set a memory allocation configuration option when using systemd:

Check the assigned values of the memory allocation configuration option in the service of your choice.

$ systemctl show --property <memory allocation configuration option> <service name>
Set the required value of the memory allocation configuration option as a root.

# systemctl set-property <service name> <memory allocation configuration option>=<value>


```


# DEMO V2

```shell


sed  -i 's|APT::Periodic::Unattended-Upgrade \"1\";|APT::Periodic::Unattended-Upgrade \"0\";|' /etc/apt/apt.conf.d/20auto-upgrades
cat  /etc/apt/apt.conf.d/20auto-upgrades

export DEBIAN_FRONTEND=noninteractive
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
apt remove snapd -y


sysctl -w vm.max_map_count=262144
echo "vm.max_map_count = 262144" > /etc/sysctl.d/99-docker-desktop.conf

apt -y install cgroup-tools cpuset cgroup-lite cgroup-tools cgroupfs-mount libcgroup1 sysstat nmon
sed -i -e 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="cgroup_enable=cpuset cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1"|' /etc/default/grub
cat /etc/default/grub
update-grub
shutdown -r 1 "reboot"
```



```shell

stat -c %T -f /sys/fs/cgroup
>>> cgroup2fs




cat <<EOF>/etc/systemd/system/nginx.slice
[Unit]
Description=Nginx Slice
Before=slices.target

[Slice]
MemoryHigh=1024M
MemoryMax=2048M
MemorySwapMax=0M
TasksMax=2048
SocketBindDeny=ipv6
EOF
systemctl daemon-reload
systemctl status nginx2.slice

cat <<EOF>/etc/systemd/system/nginx2.slice
[Unit]
Description=Nginx2 Slice
Before=slices.target
Slice=nginx.slice

[Slice]
MemoryHigh=1024M
MemoryMax=2048M
MemorySwapMax=0M
TasksMax=2048
SocketBindDeny=ipv6
EOF
systemctl daemon-reload
systemctl status nginx2.slice



cat <<EOF>/etc/cgconfig.conf
group system.slice {
        cpuset {
                cpuset.cpus.partition="member";
                cpuset.mems="";
                cpuset.cpus="2";
        }
}
group user.slice {
        cpuset {
                cpuset.cpus.partition="member";
                cpuset.mems="";
                cpuset.cpus="0-1";
        }
}
group nginx.service {
        cpuset {
                cpuset.cpus.partition="member";
                cpuset.mems="";
                cpuset.cpus="3-4";
        }
}
EOF
cgconfigparser -l /etc/cgconfig.conf

cat /sys/fs/cgroup/nginx.slice/cpuset.cpus


cat <<EOF>/etc/systemd/system/cgconfigparser.service
[Unit]
Description=cgroup config parser
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/sbin/cgconfigparser -l /etc/cgconfig.conf
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
sudo systemctl enable cgconfigparser --now


systemctl edit nginx.slice
......
[Unit]
Description=Nginx Slice
Before=slices.target

[Slice]
MemoryAccounting=yes
CPUAccounting=yes
IOAccounting=yes
TasksAccounting=yes
......

systemctl edit nginx.slice
......
[Unit]
Description=Nginx Slice
Before=slices.target
......

nano /usr/lib/systemd/system/nginx.service
and add in the [Service] section:
Slice=nginx.slice



```

```shell

user.slice  init.scope  system.slice

# systemctl set-property example.service MemoryMax=1500K
# systemctl set-property service_name.service AllowedCPUs=0-5
# systemctl set-property <service name> CPUAffinity=<value>

```
