# Demo V4
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

apt install nginx cgroup-tools -y

```

```shell

systemctl set-property user.slice MemoryMax=1G
systemctl set-property init.scope MemoryMax=1G
systemctl set-property system.slice MemoryMax=1G

systemctl set-property user.slice AllowedCPUs=0-1
systemctl set-property init.scope AllowedCPUs=0-1
systemctl set-property system.slice AllowedCPUs=2-2
```

```shell
systemctl show --property MemoryMax user.slice
systemctl show --property MemoryMax init.scope
systemctl show --property MemoryMax system.slice

systemctl show --property AllowedCPUs user.slice
systemctl show --property AllowedCPUs init.scope
systemctl show --property AllowedCPUs system.slice
```

https://manpages.debian.org/stretch/systemd/systemd.resource-control.5.en.html

```shell
systemctl set-property nginx.slice MemoryMax=2G
systemctl set-property nginx.slice TasksMax=60
systemctl set-property nginx.slice AllowedCPUs=3-4

systemctl show --property MemoryMax nginx.slice
systemctl show --property AllowedCPUs nginx.slice
systemctl show --property TasksMax nginx.slice

systemctl set-property nginx.slice 

systemctl start nginx.slice
systemctl status nginx.slice

```

```shell

cat <<EOF>/usr/lib/systemd/system/nginx.service
# Stop dance for nginx
# =======================
#
# ExecStop sends SIGQUIT (graceful stop) to the nginx process.
# If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
# and sends SIGTERM (fast shutdown) to the main process.
# After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
#
# nginx signals reference doc:
# http://nginx.org/en/docs/control.html
#
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
TimeoutStopSec=5
KillMode=mixed
Slice=nginx.slice

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl stop nginx.service
systemctl disable nginx.service
systemctl enable nginx.service
systemctl start nginx.service


systemctl status nginx.service

```


```shell

root@node181:~# cat /etc/systemd/system.control/nginx.slice.d/50-AllowedCPUs.conf
# This is a drop-in unit file extension, created via "systemctl set-property"
# or an equivalent operation. Do not edit.
[Slice]
AllowedCPUs=3-4
root@node181:~# cat /etc/systemd/system.control/nginx.slice.d/50-MemoryMax.conf
# This is a drop-in unit file extension, created via "systemctl set-property"
# or an equivalent operation. Do not edit.
[Slice]
MemoryMax=2147483648
root@node181:~# cat /etc/systemd/system.control/nginx.slice.d/50-TasksMax.conf
# This is a drop-in unit file extension, created via "systemctl set-property"
# or an equivalent operation. Do not edit.
[Slice]
TasksMax=60
root@node181:~#


```


```shell

ps --ppid 2 -p 2 -o uname,pid,ppid,cmd,cls,psr --deselect

```

```shell
# example
echo "128M" >/sys/fs/cgroup/nginx.slice/memory.max

```
