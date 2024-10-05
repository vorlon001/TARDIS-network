#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive


curl –s https://deb.frrouting.org/frr/keys.gpg | sudo tee /usr/share/keyrings/frrouting.gpg > /dev/null
FRRVER="frr-stable"
echo deb '[signed-by=/usr/share/keyrings/frrouting.gpg]' https://deb.frrouting.org/frr \
     $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list

# update and install FRR
apt update && apt install frr frr-pythontools -y

sed -i "s/^bgpd=no/bgpd=yes/" /etc/frr/daemons
sed -i "s/^ospfd=no/ospfd=yes/" /etc/frr/daemons
sed -i "s/^ldpd=no/ldpd=yes/" /etc/frr/daemons
sed -i "s/^ospfd=no/ospfd=yes/" /etc/frr/daemons
sed -i "s/^bfdd=no/bfdd=yes/" /etc/frr/daemons
sed -i "s/^vrrpd=no/vrrpd=yes/" /etc/frr/daemons
sed -i "s/^ospf6d=no/ospf6d=yes/" /etc/frr/daemons
sed -i "s/^isisd=no/isisd=yes/" /etc/frr/daemons


# if frr in netns and not vrf
# nano /etc/frr/daemons
# sed -i 's|zebra_options="  -A 127.0.0.1 -s 90000000"|zebra_options="  -A 127.0.0.1 -s 90000000 --vrfwnetns"|' /etc/frr/daemons


systemctl enable frr
systemctl restart frr
systemctl status frr



cat <<EOF>>/etc/modules-load.d/modules.conf
mpls_router
mpls_iptunnel
EOF
modprobe mpls_router
modprobe mpls_iptunnel

cat <<EOF>>/etc/sysctl.conf
net.ipv4.ip_forward = 1
net.mpls.conf.enp1s0.input = 1
net.mpls.conf.enp1s0/32.input = 1
net.mpls.default_ttl = 255
net.mpls.ip_ttl_propagate = 1
net.mpls.platform_labels = 100000
EOF

sysctl -p
sysctl -a | grep mpls

#reboot


export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
vtysh -c "show run" >021-configure-frr-node${NODEID}.config
