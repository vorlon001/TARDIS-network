### Create 4 vm ubuntu 22.04. create vm https://github.com/vorlon001/libvirt-home-labs/tree/v2
- network one: Virtio network device
- network two: e1000
- network three: e1000
- network four: e1000
- all network attach to switch ovs, mode trunk

### Network VM Ubuntu 22.04LTS


```

      node3 (Gateway, 192.168.203.3:VLAN800, UBUNTU 22.04LTS)
                          |
                          |
                          |                                 node3 (FRRouting, BGP, Gateway, 192.168.203.150:VLAN800, UBUNTU 22.04LTS)
                          |                                                       |
                          |                                                       |
                          |                                                       |
                          |                                                       |
                          --------------- VLAN800 ---------------------------------
                                                       |
                                                       |
                                                       |
                                                       |
                                     node180 (VTEP-VPP, 192.168.203.180:VLAN800, UBUNTU 22.04LTS)
                                                       |
                                                       |
                                                       |
                                                       |
                                             --------------------------(VLAN200)---------------------------------------------
                                             |                                                          |                   |
                                             |                                                          |                   |
                                             |                                                          |                   |
                                             |                                                          |                   |
                                             |                                                          |                   |
   node170 (OVN-CENTRAL,OVS, 192.168.200.170:VLAN200, UBUNTU 22.04LTS)                                  |                   |
                                                                                                        |                   |
                                                                                                        |                   |
                                              node170 (OVN-CENTRAL,OVS, 192.168.200.170:VLAN200, UBUNTU 22.04LTS)           |
                                                                                                                            |
                                                                                                                            |
                                                                   node170 (OVN-CENTRAL,OVS,192.168.200.170:VLAN200, UBUNTU 22.04LTS)


```


- Base on https://satishdotpatel.github.io/ovn-ssl-setup-with-openstack/

# OVN CENTRAL
## ON CENTRAL 1 node170 node171 node172

### ON v1 node170 node171 node172

```shell
export DEBIAN_FRONTEND=noninteractive
apt install python3-pip linux-virtual-hwe-22.04 make cmake gcc linux-modules-extra-5.19.0-42-generic git -y
mkdir -p /var/log/vpp/ && chmod 777 -R /var/log/vpp/
apt autoremove -y
reboot
```

### ON v1 node170 node171 node172

```shell

cat <<EOF>/etc/apt/sources.list
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy main
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy-updates main restricted
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy universe
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy-updates universe
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy multiverse
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy-updates multiverse
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy-backports main restricted universe multiverse
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy-security main restricted
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy-security universe
deb  https://nexus3.iblog.pro/repository/archive.ubuntu.com/ jammy-security multiverse
EOF

apt install gpg -y
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 5EDB1B62EC4926EA
gpg --export 5EDB1B62EC4926EA >/etc/apt/5EDB1B62EC4926EA.gpg
apt-key add /etc/apt/5EDB1B62EC4926EA.gpg
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu jammy-updates/antelope main" >> /etc/apt/sources.list

apt update
apt upgrade -y
apt-get install openssl sshpass -y && \
apt-get install openvswitch-switch openvswitch-common -y && \
apt-get install ovn-central ovn-common ovn-host -y

```



### ON v1 node170
```shell


cat <<EOF>e.sh
#!/usr/bin/bash
set -x

ovs-pki init --force
mkdir /etc/openvswitch
cd /etc/openvswitch
ovs-pki req ovnnb
ovs-pki -b sign ovnnb
ls /etc/openvswitch/
cd /etc/openvswitch
ovs-pki req ovnsb
ovs-pki -b sign ovnsb

cd /etc/openvswitch
ovs-pki req ovnnorthd
ovs-pki -b sign ovnnorthd
cd /etc/openvswitch
ovs-pki req ovncontroller
ovs-pki -b sign ovncontroller switch

cp /var/lib/openvswitch/pki/switchca/cacert.pem /etc/openvswitch/

cd /root
echo "root" > pass_file
chmod 0400 pass_file
sshpass -f pass_file ssh -o StrictHostKeyChecking=no root@192.168.200.171 mkdir /etc/openvswitch
sshpass -f pass_file ssh -o StrictHostKeyChecking=no root@192.168.200.172 mkdir /etc/openvswitch
sshpass -f pass_file scp -o StrictHostKeyChecking=no /etc/openvswitch/*pem 192.168.200.171://etc/openvswitch
sshpass -f pass_file scp -o StrictHostKeyChecking=no /etc/openvswitch/*pem 192.168.200.172://etc/openvswitch
EOF
chmod +x e.sh
./e.sh
```



### ON v1 node170 node171 node172
```shell

# node170 node 171 node172

cp /var/lib/openvswitch/pki/switchca/cacert.pem /etc/openvswitch/

ovn-nbctl set-ssl /etc/openvswitch/ovnnb-privkey.pem \
     /etc/openvswitch/ovnnb-cert.pem  /etc/openvswitch/cacert.pem
ovn-nbctl set-connection pssl:6641

ovn-sbctl set-ssl /etc/openvswitch/ovnsb-privkey.pem \
    /etc/openvswitch/ovnsb-cert.pem  /etc/openvswitch/cacert.pem

ovn-sbctl set-connection pssl:6642

ovn-nbctl get-ssl
ovn-nbctl get-connection


# node 170
cat <<EOF>/etc/default/ovn-central
# OVN cluster parameters
OVN_CTL_OPTS=" \
  --db-nb-create-insecure-remote=no \
  --db-sb-create-insecure-remote=no \
  --db-nb-addr=192.168.200.170 \
  --db-sb-addr=192.168.200.170 \
  --db-nb-cluster-local-addr=192.168.200.170 \
  --db-sb-cluster-local-addr=192.168.200.170 \
  --ovn-northd-nb-db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 \
  --ovn-northd-sb-db=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642 \
  --ovn-northd-ssl-key=/etc/openvswitch/ovnnorthd-privkey.pem \
  --ovn-northd-ssl-cert=/etc/openvswitch/ovnnorthd-cert.pem \
  --ovn-northd-ssl-ca-cert=/etc/openvswitch/cacert.pem \
"
EOF

# node171

cat <<EOF>/etc/default/ovn-central
# OVN cluster parameters
OVN_CTL_OPTS=" \
  --db-nb-create-insecure-remote=no \
  --db-sb-create-insecure-remote=no \
  --db-nb-addr=192.168.200.171 \
  --db-sb-addr=192.168.200.171 \
  --db-nb-cluster-local-addr=192.168.200.171 \
  --db-sb-cluster-local-addr=192.168.200.171 \
  --db-nb-cluster-remote-addr=192.168.200.170 \
  --db-sb-cluster-remote-addr=192.168.200.170 \
  --ovn-northd-nb-db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 \
  --ovn-northd-sb-db=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642 \
  --ovn-northd-ssl-key=/etc/openvswitch/ovnnorthd-privkey.pem \
  --ovn-northd-ssl-cert=/etc/openvswitch/ovnnorthd-cert.pem \
  --ovn-northd-ssl-ca-cert=/etc/openvswitch/cacert.pem \
"
EOF

#node172
cat <<EOF>/etc/default/ovn-central
# OVN cluster parameters
OVN_CTL_OPTS=" \
  --db-nb-create-insecure-remote=no \
  --db-sb-create-insecure-remote=no \
  --db-nb-addr=192.168.200.172 \
  --db-sb-addr=192.168.200.172 \
  --db-nb-cluster-local-addr=192.168.200.172 \
  --db-sb-cluster-local-addr=192.168.200.172 \
  --db-nb-cluster-remote-addr=192.168.200.170 \
  --db-sb-cluster-remote-addr=192.168.200.170 \
  --ovn-northd-nb-db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 \
  --ovn-northd-sb-db=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642 \
  --ovn-northd-ssl-key=/etc/openvswitch/ovnnorthd-privkey.pem \
  --ovn-northd-ssl-cert=/etc/openvswitch/ovnnorthd-cert.pem \
  --ovn-northd-ssl-ca-cert=/etc/openvswitch/cacert.pem \
"
EOF

# node170 node171 node172
systemctl restart ovn-central.service
export NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
ovs-vsctl set Open_vSwitch . external-ids:ovn-remote=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642

ovs-vsctl set Open_vSwitch .  \
  external_ids:ovn-remote=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642 \
  external_ids:ovn-encap-ip=192.168.200.${NODEID} \
  external_ids:ovn-encap-type=geneve,vxlan \
  external_ids:system-id=$(hostname)


cat <<EOF>/etc/default/ovn-host
OVN_CTL_OPTS="--ovn-controller-ssl-key=/etc/openvswitch/ovncontroller-privkey.pem  --ovn-controller-ssl-cert=/etc/openvswitch/ovncontroller-cert.pem --ovn-controller-ssl-ca-cert=/etc/openvswitch/cacert.pem"
EOF

systemctl restart ovn-controller

ovs-vsctl show



```






```shell

ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem query ssl:192.168.200.170:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem query ssl:192.168.200.171:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem query ssl:192.168.200.172:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"


ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem query ssl:192.168.200.170:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem query ssl:192.168.200.171:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem query ssl:192.168.200.172:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"




ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  dump  ssl:192.168.200.170:6641 
ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  dump  ssl:192.168.200.171:6641 
ovsdb-client  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  dump  ssl:192.168.200.172:6641 


ovsdb-client  --private-key=/etc/openvswitch/ovnsb-privkey.pem --certificate=/etc/openvswitch/ovnsb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  dump  ssl:192.168.200.170:6642 
ovsdb-client  --private-key=/etc/openvswitch/ovnsb-privkey.pem --certificate=/etc/openvswitch/ovnsb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  dump  ssl:192.168.200.171:6642 
ovsdb-client  --private-key=/etc/openvswitch/ovnsb-privkey.pem --certificate=/etc/openvswitch/ovnsb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  dump  ssl:192.168.200.172:6642 



ovs-vsctl show
ovs-vsctl --columns external_ids list open_vswitch


OVN_NB_DB=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem show
OVN_SB_DB=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642 ovn-sbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem show


# if need
systemctl restart ovn-controller
systemctl restart ovn-northd.service
systemctl restart ovn-ovsdb-server-sb.service
systemctl restart ovn-ovsdb-server-nb.service

systemctl status ovn-controller
systemctl status ovn-northd.service
systemctl status ovn-ovsdb-server-sb.service
systemctl status ovn-ovsdb-server-nb.service

ovs-vsctl show

```




```shell
# node 170

OVN_NB_DB=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  ls-add net_east


ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  ls-add net_east
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-add net_east vm1
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-addresses vm1 "40:44:00:00:00:01 12.0.0.11"

ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-add net_east vm2
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-addresses vm2 "40:44:00:00:00:02 12.0.0.12"

ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-add net_east vm3
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-addresses vm3 "40:44:00:00:00:03 12.0.0.13"

ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  ls-add public
# Create a localnet port
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-add public ln-public
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-type ln-public localnet
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-addresses ln-public unknown
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-options ln-public network_name=provider

ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lr-add router_east
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lrp-add router_east router_east-net_east 40:44:00:00:00:04 12.0.0.1/24
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-add net_east net_east-router_east
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-type net_east-router_east router
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-addresses net_east-router_east router
ovn-nbctl  --private-key=/etc/openvswitch/ovnnb-privkey.pem --certificate=/etc/openvswitch/ovnnb-cert.pem --ca-cert=/etc/openvswitch/cacert.pem  lsp-set-options net_east-router_east router-port=router_east-net_east


```



```shell
# node170

function ovn_add_phys_port_1 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}
ovn_add_phys_port_1 vm1 40:44:00:00:00:01 12.0.0.11 24 12.0.0.1




function ovn_add_phys_port_2 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    ip netns add $name
    ip link set $name netns $name
    ip netns exec $name ip link set $name address $mac
    ip netns exec $name ip addr add $ip/$mask dev $name
    ip netns exec $name ip link set $name up
    ip netns exec $name ip route add default via $gw
    ip netns exec $name route add -net 192.168.0.0 netmask 255.255.0.0 gw 12.0.0.66
}

ovn_add_phys_port_2 vm1 40:44:00:00:00:01 12.0.0.11 24 12.0.0.1


ip netns exec vm1 ping 12.0.0.1 -c 5



```



```shell
# node171


function ovn_add_phys_port_1 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}
ovn_add_phys_port_1 vm2 40:44:00:00:00:02 12.0.0.12 24 12.0.0.1




function ovn_add_phys_port_2 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    ip netns add $name
    ip link set $name netns $name
    ip netns exec $name ip link set $name address $mac
    ip netns exec $name ip addr add $ip/$mask dev $name
    ip netns exec $name ip link set $name up
    ip netns exec $name ip route add default via $gw
    ip netns exec $name route add -net 192.168.0.0 netmask 255.255.0.0 gw 12.0.0.66
}

ovn_add_phys_port_2 vm2 40:44:00:00:00:02 12.0.0.12 24 12.0.0.1


ip netns exec vm2 ping 12.0.0.1 -c 5
ip netns exec vm2 ping 12.0.0.11 -c 5


```



```shell
# node172


function ovn_add_phys_port_1 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    ovs-vsctl add-port br-int $name -- set Interface $name type=internal -- set Interface $name external_ids:iface-id=$name
}
ovn_add_phys_port_1 vm3 40:44:00:00:00:03 12.0.0.13 24 12.0.0.1




function ovn_add_phys_port_2 {
    name=$1
    mac=$2
    ip=$3
    mask=$4
    gw=$5
    ip netns add $name
    ip link set $name netns $name
    ip netns exec $name ip link set $name address $mac
    ip netns exec $name ip addr add $ip/$mask dev $name
    ip netns exec $name ip link set $name up
    ip netns exec $name ip route add default via $gw
    ip netns exec $name route add -net 192.168.0.0 netmask 255.255.0.0 gw 12.0.0.66
}

ovn_add_phys_port_2 vm3 40:44:00:00:00:03 12.0.0.13 24 12.0.0.1


ip netns exec vm3 ping 12.0.0.1 -c 3
ip netns exec vm3 ping 12.0.0.11 -c 3
ip netns exec vm3 ping 12.0.0.12 -c 3




```
