#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive


apt -y update && apt -y install frr frr-pythontools

sed -i "s/^bgpd=no/bgpd=yes/" /etc/frr/daemons
sed -i "s/^ospfd=no/ospfd=yes/" /etc/frr/daemons
sed -i "s/^ldpd=no/ldpd=yes/" /etc/frr/daemons
sed -i "s/^ospfd=no/ospfd=yes/" /etc/frr/daemons
sed -i "s/^bfdd=no/bfdd=yes/" /etc/frr/daemons
sed -i "s/^vrrpd=no/vrrpd=yes/" /etc/frr/daemons

# if frr in netns and not vrf
# nano /etc/frr/daemons

sed -i 's|zebra_options="  -A 127.0.0.1 -s 90000000"|zebra_options="  -A 127.0.0.1 -s 90000000 --vrfwnetns"|' /etc/frr/daemons


systemctl enable frr
systemctl restart frr
systemctl status frr
