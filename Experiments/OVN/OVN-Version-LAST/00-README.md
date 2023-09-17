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

```

000-init-vm.sh - run on all nodes
001-build-ovn.sh - run on nodes: node170,171,172,180

# init ovn central
022-init-ovn-central.sh - run on nodes: node170,171,172
023-test-ovn-central.sh - run on node170
023-test-ovn-central.sh - run on node171

#init ovs
025-init-ovs.sh - run on node170,171,172
026-connect-ovs-to-ovn.sh - run on node170,171,172

#init ovn
027-init-ovn-switch.sh - on node170

# test connection
./028-init-port-node170.sh - on node170
./028-init-port-node171.sh - on node171
./028-init-port-node172.sh - on node172

# ovn show configuration

./029-show-config-ovn.sh

# init vpp
./050-init-vpp.sh - on node180
./051-test-vpp.sh - on node180
./052-configure-vpp.sh - on node180
./053-configure-vpp.sh - on node180

# init ovn vtep on node180
# if command not apply, apply the commands manually !!!!

./055-init-node-vtep.sh - on node180

./056-configure-port-on-leader-ovn.sh - on node170

./057-configure-port-vtep.sh - on node180

./058-show-vtep.sh - on node180
>>> MAC                 : "40:44:00:00:00:03"
>>> 
>>> MAC                 : "40:44:00:00:00:01"
>>> 
>>> MAC                 : "40:44:00:00:00:02"
>>> 52621162-eb1e-4e2e-85a2-9f7de8f8cf5a
>>>     Physical_Switch GW01
>>>         tunnel_ips: ["192.168.203.180"]
>>>         Physical_Port vtap4
>>>             vlan_bindings:
>>>                 1=LS1

./066-init-vxlan.sh - on node180
sleep 60 second
./067-init-vxlan.sh - on node180
sleep 60 second
./068-test-vtep.sh  - on node180
sleep 60 second
./069-external-gateway.sh - on node180

ip netns exec vm1 ping 12.0.0.66 - on node170
ip netns exec vm2 ping 12.0.0.66 - on node171
ip netns exec vm3 ping 12.0.0.66 - on node172

tcpdump -ni enp1s0.800  port 4789 - on node170
tcpdump -ni enp1s0.800  port 4789 - on node170
tcpdump -ni enp1s0.800  port 4789 - on node170

# init BGP

./080-install-frr.sh - on node150
./082-configure.sh - on node150
./082-diag.sh - on node150 show bgp status

./070-install-frr.sh  - on node180
./071-configure-frr.sh - on node180
./072-diag-frr.sh - on node180

DONE!!

```

```shell
root@node170:~# lshw -class network -businfo
Bus info          Device      Class          Description
========================================================
pci@0000:01:00.0              network        Virtio network device
virtio@0          enp1s0      network        Ethernet interface
pci@0000:03:01.0  enp2s0      network        82540EM Gigabit Ethernet Controller
pci@0000:03:02.0  ens2f0      network        82540EM Gigabit Ethernet Controller
pci@0000:03:03.0  ens3f0      network        82540EM Gigabit Ethernet Controller
pci@0000:03:04.0  ens4f0      network        82540EM Gigabit Ethernet Controller
root@node170:~#
```

### netplan config example

```yaml
network:
    ethernets:
        enp1s0:
            dhcp4: false
            match:
                macaddress: fa:16:3e:9b:b6:d6
                name: enp*s0
            set-name: enp1s0
        enp2s0:
            dhcp4: false
            match:
                macaddress: fa:16:3e:fe:e1:c8
                name: enp*s0
            set-name: enp2s0
    version: 2
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.170/24
            dhcp4: false
            dhcp6: false
            gateway4: 192.168.200.1
            id: 200
            link: enp1s0
            nameservers:
                addresses:
                - 192.168.1.10
                search:
                - cloud.local
        enp1s0.400:
            addresses:
            - 192.168.201.170/24
            dhcp4: false
            dhcp6: false
            id: 400
            link: enp1s0
```

### debug

```shell
docker restart ovn-northd ovn-run_nb_ovsdb ovn-run_sb_ovsdb
docker stop ovn-northd ovn-run_nb_ovsdb ovn-run_sb_ovsdb
docker rm ovn-northd ovn-run_nb_ovsdb ovn-run_sb_ovsdb
rm -R /root/ovn/*

docker rm $(docker ps -q) --force
docker rmi $(docker images -q) --force
```

```shell
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.170:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.171:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.172:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"


docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.170:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.171:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.172:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"

# on node170,node171,node172
docker exec -it ovn-run_nb_ovsdb ovs-appctl -t /var/run/ovn/ovnnb_db.ctl cluster/status OVN_Northbound
docker exec -it ovn-run_sb_ovsdb ovs-appctl -t /var/run/ovn/ovnsb_db.ctl cluster/status OVN_Southbound
# on Leader node170
docker exec -it ovn-run_nb_ovsdb ovn-nbctl --inactivity-probe=60000 set-connection ptcp:6641:0.0.0.0
docker exec -it ovn-run_sb_ovsdb ovn-sbctl --inactivity-probe=60000 set-connection ptcp:6642:0.0.0.0
```



```shell

# debug
docker stop  ovn-northd ovn-run_sb_ovsdb  ovn-run_nb_ovsdb
docker rm  ovn-northd ovn-run_sb_ovsdb  ovn-run_nb_ovsdb
rm /root/ovn/lib/*
rm /root/ovn/lib/.ovn*
rm /root/ovn/log/*
rm /root/ovn/run/*

docker restart  ovn-northd ovn-run_sb_ovsdb  ovn-run_nb_ovsdb
```




```shell
docker restart ovs-controller
```
### DEBUG CMD
```shell

docker ps -a
docker stop ovs-controller ovs-vswitchd ovsdb-server
docker rm ovs-controller ovs-vswitchd ovsdb-server 
```


```shell
tcpdump -nni enp1s0.400 port 4789
```
