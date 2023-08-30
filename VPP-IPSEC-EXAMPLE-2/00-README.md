### Create 4 vm ubuntu 22.04. create vm https://github.com/vorlon001/libvirt-home-labs/tree/v2
- network one: Virtio network device
- network two: e1000
- network three: e1000
- network four: e1000
- all network attach to switch ovs, mode trunk

### Network VM Ubuntu 22.04LTS

```shell
scp * 192.168.200.170:. && scp * 192.168.200.171:. && scp * 192.168.200.172:. && scp * 192.168.200.173:. && scp * 192.168.200.174:.
```

```

 ------------------------------------------------------------(VLAN 800 192.168.203.0/24 )------------------------------------------|
 |    |            |                                 |                        |                       |                            |
 |    |            |                                 |                        |                       |                            |
 |    |            |                                 |                        |                       |                            |
  \     \            \                                 \                        \                      \                           |
   |     |            |                                 |                        |                      |                          |
-------------------------------------------------------------(VLAN 200 192.168.200.0/24 )---------------|-------------------------||
|  |  |  |         |  |                              |  |                     |  |                   |  |                         ||             
| /   | /          | /                               | /                      | /                    | /                          ||               
||    ||           ||                                ||                       ||                     ||                           ||               
||    ||           ||                                ||                       ||                     ||                           ||               
||    ||           ||                                ||                       ||                     ||                           ||               
||    ||           (multi-ipsec-gw01, VXLAN, VPP)    ||                       ||                     ||                           ||
||    ||            node171 ------(VLAN 802)-------- node172                  ||                     ||                           ||               
||    ||              |       (10.100.0.0/24)  | (multi-ipsec-gw01, VPP)      ||                     ||                           ||  
||    ||              |                        |       |                      ||                     ||                           ||               
||    ||              |                        |       |                      ||                     ||                           ||               
||    ||              |------------            |       |                      ||                     ||                           ||               
||    ||                          |            |       |                      ||                     ||                           ||
||    (multi-ipsec-gw01-client)   |            |       ------(VLAN 803)--- node173                   ||                           ||
||    ( netplan )                 |            |       |                   ( netplan )               ||                           ||
||     node170                    |            |       |   (10.0.0.0/24)   (ipsec-gw01, VPP)         ||                           ||
||    |                           |            |       |                    |                        ||                           ||
||    |                           |            |       |                    |                        ||                           ||
||    |                           |            |       |                    |                        ||                           ||
||    ---------( VLAN 801) -------|            |       |                    ------( VLAN 804 )---- node174                        ||
||         ( 172.16.0.0/24 )                   |       |                        (192.168.0.0/24)   (ipsec-gw01-client, netplan)   ||
||                                             |       |                                                                          ||
||                                             |       |                                                                          ||
||                                             |       |                                                                          ||
||                                             |       |                                                                          ||
||                                             |-----| |------(VLAN 803)--- node163                      |------------------------||
||                                                   | |    (10.0.0.0/24)  ( netplan )                   ||------------------------|
||                  (multi-ipsec-gw02, VXLAN, VPP)   | |                   (ipsec-gw01, VPP)             ||                       ||
||                   node161 ------(VLAN 802)--------| |                        |                        ||                       ||
||                     |                       |       |                        |                        ||                       ||
|------|               |                       |       |                        |                        ||                       ||
||----||               ------------|           |       |                        ------( VLAN 804 )---- node164                     \\
||    ||                           |           |       |                            (192.168.1.0/24)  (ipsec-gw02-client, netplan)  \\
||   (multi-ipsec-gw01-client)     |           |       |                                                                             \\
||   ( netplan )                   |           |       |                                                                              \\
||   node160                       |           |       |                                                                               \\
||     |                           |           |       |                                                                                ||
||     |                           |           |       |                                                                                ||
||     ---------( VLAN 805) -------|           |       |                                                 |-(VLAN 800 192.168.203.0/24)--||
||             ( 172.16.1.0/24 )               |       |                                                 ||-(VLAN 200 192.168.200.0/24 )-|
||                                             |       |                                                 || 
||                                             |       |                                                 ||
||                                             |       |                                                 ||
||                                             |-----| |                                                 ||
||                                                   | |------(VLAN 803)--- node153                      ||
||                  (multi-ipsec-gw03, VXLAN, VPP)   |      (10.0.0.0/24)  ( netplan )                   ||
||                   node151 ------(VLAN 802)--------|                     (ipsec-gw01, VPP)             ||
|\                     |                                                        |                        ||
| \----|               |                                                        |                        ||
\-----||               ------------|                                            |                        ||
      ||                           |                                            ------( VLAN 804 )---- node154
     (multi-ipsec-gw03-client)     |                                                (192.168.0.0/24)   (ipsec-gw03-client, netplan)
     ( netplan )                   |
     node150                       |
       |                           |
       |                           |
       ---------( VLAN 806) -------|
             ( 172.16.2.0/24 )













```



### RTFM
```shell

root@node3:/KVM/init.kvm.v26# ovs-appctl fdb/show sw1
 port  VLAN  MAC                Age
 2181     0  fa:16:3e:41:bb:21  291
 2182     0  fa:16:3e:48:7b:13  200
 2183   400  fa:16:3e:e0:fa:47  171
.........
root@node3:/KVM/init.kvm.v26# ovs-vsctl list interface | grep 'name\|ofport' | grep -v 'status\|ofport_request'


```
