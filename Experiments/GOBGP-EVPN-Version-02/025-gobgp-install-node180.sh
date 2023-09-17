#!/usr/bin/bash


wget https://github.com/osrg/gobgp/releases/download/v3.14.0/gobgp_3.14.0_linux_amd64.tar.gz
tar zxvf gobgp_3.14.0_linux_amd64.tar.gz

mv gobgp /usr/bin/
mv gobgpd /usr/sbin/
rm LICENSE
rm README.md
rm gobgp_3.14.0_linux_amd64.tar.gz


groupadd --system gobgpd
useradd --system -d /var/lib/gobgpd -s /bin/bash -g gobgpd gobgpd
mkdir -p /var/{lib,run,log}/gobgpd
chown -R gobgpd:gobgpd /var/{lib,run,log}/gobgpd
mkdir -p /etc/gobgpd
chown -R gobgpd:gobgpd /etc/gobgpd


export DEBIAN_FRONTEND=noninteractive

cat <<EOF>/etc/gobgpd/gbgp.yaml
global:
  config:
    as: 65000
    router-id: 192.168.200.180
    port: 1790
    local-address-list:
      - 192.168.200.180
neighbors:
  - config:
      neighbor-address: 192.168.200.182
      peer-as: 65000
    afi-safis:
      - config:
          afi-safi-name: l2vpn-evpn
      - config:
          afi-safi-name: ipv4-unicast
    graceful-restart:
      config:
        enabled: true
        notification-enabled: true
        long-lived-enabled: true
        restart-time: 20
    ebgp-multihop:
      config:
        enabled: true
        multihop-ttl: 14
EOF
chown -R gobgpd:gobgpd /etc/gobgpd

cat << EOF | sudo tee /usr/lib/systemd/system/gobgp.service
#####
[Unit]
Description=GoBGP Daemon (added by Privex)
After=network.target

[Service]
Type=simple
User=root

ExecStart=/usr/sbin/gobgpd -f /etc/gobgpd/gbgp.yaml

Restart=always
RestartSec=30
StandardOutput=syslog
# Hardening measures
####################
PrivateTmp=true
# Mount /usr, /boot/ and /etc read-only for the process.
ProtectSystem=full
# Disallow the process and all of its children to gain
# new privileges through execve().
NoNewPrivileges=true
# Use a new /dev namespace only populated with API pseudo devices
# such as /dev/null, /dev/zero and /dev/random.
PrivateDevices=true
# Deny the creation of writable and executable memory mappings.
MemoryDenyWriteExecute=true

[Install]
WantedBy=multi-user.target
Alias=gobgpd.service
EOF

sudo systemctl daemon-reload
sudo systemctl enable gobgp.service
sudo systemctl start gobgp.service
