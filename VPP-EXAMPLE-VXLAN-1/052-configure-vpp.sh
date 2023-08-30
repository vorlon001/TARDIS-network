#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive

cat << EOF | sudo tee /usr/lib/systemd/system/netns-dataplane.service 
[Unit]
Description=Dataplane network namespace
After=systemd-sysctl.service network-pre.target
Before=network.target network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes

# PrivateNetwork will create network namespace which can be
# used in JoinsNamespaceOf=.
PrivateNetwork=yes

# To set `ip netns` name for this namespace, we create a second namespace
# with required name, unmount it, and then bind our PrivateNetwork
# namespace to it. After this we can use our PrivateNetwork as a named
# namespace in `ip netns` commands.
ExecStartPre=-/usr/bin/echo "Creating dataplane network namespace"
ExecStart=-/usr/sbin/ip netns delete dataplane
ExecStart=-/usr/bin/mkdir -p /etc/netns/dataplane
ExecStart=-/usr/bin/touch /etc/netns/dataplane/resolv.conf
ExecStart=-/usr/sbin/ip netns add dataplane
ExecStart=-/usr/bin/umount /var/run/netns/dataplane
ExecStart=-/usr/bin/mount --bind /proc/self/ns/net /var/run/netns/dataplane
# Apply default sysctl for dataplane namespace
ExecStart=-/usr/sbin/ip netns exec dataplane /usr/lib/systemd/systemd-sysctl
ExecStop=-/usr/sbin/ip netns delete dataplane

[Install]
WantedBy=multi-user.target
WantedBy=network-online.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable netns-dataplane
sudo systemctl start netns-dataplane





vppctl set logging class linux-cp rate-limit 1000 level warn syslog-level notice

vppctl lcp default netns dataplane
vppctl lcp lcp-sync on
vppctl lcp lcp-auto-subint on
