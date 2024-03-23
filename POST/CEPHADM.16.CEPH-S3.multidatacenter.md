```

watch -n 2 ceph -s

                                                                   |------------------------node170:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc1):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc1)
                                                                   |
                                                                   |------------------------node171:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc1):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc1)
               |------(node3:vlan200,vlan400,vlan600,vlan800) -----|
               |                                                   |------------------------node172:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc1):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc1)
               |                                                   |
               |                                                   |------------------------node173:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc1):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc1)
               |
               |
               |                                                   |------------------------node130:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc2):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc2)
               |                                                   |
               |                                                   |------------------------node131:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc2):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc2)
               |------(node6:vlan200,vlan400,vlan600,vlan800) -----|
               |                                                   |------------------------node132:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc2):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc2)
               |                                                   |
               |                                                   |------------------------node133:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc2):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc2)
               |
               |
               |
               |                                                   |------------------------node140:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc3):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc3)
               |                                                   |
               |                                                   |------------------------node141:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc3):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc3)
               |------(node5:vlan200,vlan400,vlan600,vlan800) -----|
                                                                   |------------------------node142:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc3):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc3)
                                                                   |
                                                                   |------------------------node143:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-multidc,rack:cloudstack-dc3):sdd(ssd-class,root:zone-multidc,rack:cloudstack-dc3)




                |----DC1 (node130,noe131,nodd132) (mng:1,mon:1)
				|
                |----DC2 (node140,noe141,nodd142) (mng:1,mon:1)
				|
                |----DC3 (node170,noe133,nodd142) (mng:1,mon:1)

 

## NODE 5

### STEP 1

ceph osd set nobackfill
ceph osd set norebalance

ceph osd crush rm-device-class osd.1 && ceph osd crush set-device-class ssd osd.1
ceph osd crush rm-device-class osd.2 && ceph osd crush set-device-class ssd osd.2

ceph osd crush rm-device-class osd.4 && ceph osd crush set-device-class ssd osd.4
ceph osd crush rm-device-class osd.5 && ceph osd crush set-device-class ssd osd.5

ceph osd crush rm-device-class osd.7 && ceph osd crush set-device-class ssd osd.7
ceph osd crush rm-device-class osd.8 && ceph osd crush set-device-class ssd osd.8


ceph osd crush add-bucket zone-multidc root
ceph osd crush add-bucket dc1-ssd datacenter
ceph osd crush add-bucket node140-ssd host
ceph osd crush add-bucket node141-ssd host
ceph osd crush add-bucket node142-ssd host

ceph osd crush add-bucket node140-room room
ceph osd crush add-bucket cloudstack-dc1 rack

ceph osd crush move dc1-ssd root=zone-multidc
ceph osd crush move node140-room root=zone-multidc  datacenter=dc1-ssd
ceph osd crush move cloudstack-dc1 root=zone-multidc datacenter=dc1-ssd room=node140-room


ceph osd crush move node140-ssd root=zone-multidc datacenter=dc1-ssd room=node140-room rack=cloudstack-dc1
ceph osd crush move node141-ssd root=zone-multidc datacenter=dc1-ssd room=node140-room rack=cloudstack-dc1
ceph osd crush move node142-ssd root=zone-multidc datacenter=dc1-ssd room=node140-room rack=cloudstack-dc1


ceph osd crush move osd.1 root=zone-multidc datacenter=dc1-ssd host=node140-ssd room=node140-room rack=cloudstack-dc1
ceph osd crush move osd.2 root=zone-multidc datacenter=dc1-ssd host=node140-ssd room=node140-room rack=cloudstack-dc1

ceph osd crush move osd.4 root=zone-multidc datacenter=dc1-ssd host=node141-ssd room=node140-room rack=cloudstack-dc1
ceph osd crush move osd.5 root=zone-multidc datacenter=dc1-ssd host=node141-ssd room=node140-room rack=cloudstack-dc1

ceph osd crush move osd.7 root=zone-multidc datacenter=dc1-ssd host=node142-ssd room=node140-room rack=cloudstack-dc1
ceph osd crush move osd.8 root=zone-multidc datacenter=dc1-ssd host=node142-ssd room=node140-room rack=cloudstack-dc1

ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill




## NODE 6

### STEP 1
ceph osd set nobackfill
ceph osd set norebalance

ceph osd crush rm-device-class osd.13 && ceph osd crush set-device-class ssd osd.13
ceph osd crush rm-device-class osd.14 && ceph osd crush set-device-class ssd osd.14

ceph osd crush rm-device-class osd.16 && ceph osd crush set-device-class ssd osd.16
ceph osd crush rm-device-class osd.17 && ceph osd crush set-device-class ssd osd.17

ceph osd crush rm-device-class osd.19 && ceph osd crush set-device-class ssd osd.19
ceph osd crush rm-device-class osd.20 && ceph osd crush set-device-class ssd osd.20

ceph osd crush add-bucket dc2-ssd datacenter
ceph osd crush add-bucket node130-ssd host
ceph osd crush add-bucket node131-ssd host
ceph osd crush add-bucket node132-ssd host

ceph osd crush add-bucket node130-room room
ceph osd crush add-bucket cloudstack-dc2 rack

ceph osd crush move dc2-ssd root=zone-multidc
ceph osd crush move node130-room root=zone-multidc  datacenter=dc2-ssd
ceph osd crush move cloudstack-dc2 root=zone-multidc datacenter=dc2-ssd room=node130-room


ceph osd crush move node130-ssd root=zone-multidc datacenter=dc2-ssd room=node130-room rack=cloudstack-dc2
ceph osd crush move node131-ssd root=zone-multidc datacenter=dc2-ssd room=node130-room rack=cloudstack-dc2
ceph osd crush move node132-ssd root=zone-multidc datacenter=dc2-ssd room=node130-room rack=cloudstack-dc2


ceph osd crush move osd.13 root=zone-multidc datacenter=dc2-ssd host=node130-ssd room=node130-room rack=cloudstack-dc2
ceph osd crush move osd.14 root=zone-multidc datacenter=dc2-ssd host=node130-ssd room=node130-room rack=cloudstack-dc2

ceph osd crush move osd.16 root=zone-multidc datacenter=dc2-ssd host=node131-ssd room=node130-room rack=cloudstack-dc2
ceph osd crush move osd.17 root=zone-multidc datacenter=dc2-ssd host=node131-ssd room=node130-room rack=cloudstack-dc2

ceph osd crush move osd.19 root=zone-multidc datacenter=dc2-ssd host=node132-ssd room=node130-room rack=cloudstack-dc2
ceph osd crush move osd.20 root=zone-multidc datacenter=dc2-ssd host=node132-ssd room=node130-room rack=cloudstack-dc2


ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill


## NODE 3

### STEP 1

ceph osd set nobackfill
ceph osd set norebalance


ceph osd crush rm-device-class osd.25 && ceph osd crush set-device-class ssd osd.25
ceph osd crush rm-device-class osd.26 && ceph osd crush set-device-class ssd osd.26

ceph osd crush rm-device-class osd.10 && ceph osd crush set-device-class ssd osd.10
ceph osd crush rm-device-class osd.11 && ceph osd crush set-device-class ssd osd.11

ceph osd crush rm-device-class osd.22 && ceph osd crush set-device-class ssd osd.22
ceph osd crush rm-device-class osd.23 && ceph osd crush set-device-class ssd osd.23

ceph osd crush add-bucket dc3-ssd datacenter
ceph osd crush add-bucket node143-ssd host
ceph osd crush add-bucket node133-ssd host
ceph osd crush add-bucket node170-ssd host

ceph osd crush add-bucket node170-room room
ceph osd crush add-bucket cloudstack-dc3 rack

ceph osd crush move dc3-ssd root=zone-multidc
ceph osd crush move node170-room root=zone-multidc  datacenter=dc3-ssd
ceph osd crush move cloudstack-dc3 root=zone-multidc datacenter=dc3-ssd room=node170-room


ceph osd crush move node143-ssd root=zone-multidc datacenter=dc3-ssd room=node170-room rack=cloudstack-dc3
ceph osd crush move node133-ssd root=zone-multidc datacenter=dc3-ssd room=node170-room rack=cloudstack-dc3
ceph osd crush move node170-ssd root=zone-multidc datacenter=dc3-ssd room=node170-room rack=cloudstack-dc3

ceph osd crush move osd.25 root=zone-multidc datacenter=dc3-ssd host=node143-ssd room=node170-room rack=cloudstack-dc3
ceph osd crush move osd.26 root=zone-multidc datacenter=dc3-ssd host=node143-ssd room=node170-room rack=cloudstack-dc3

ceph osd crush move osd.10 root=zone-multidc datacenter=dc3-ssd host=node133-ssd room=node170-room rack=cloudstack-dc3
ceph osd crush move osd.11 root=zone-multidc datacenter=dc3-ssd host=node133-ssd room=node170-room rack=cloudstack-dc3

ceph osd crush move osd.22 root=zone-multidc datacenter=dc3-ssd host=node170-ssd room=node170-room rack=cloudstack-dc3
ceph osd crush move osd.23 root=zone-multidc datacenter=dc3-ssd host=node170-ssd room=node170-room rack=cloudstack-dc3





ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill







ceph osd set nobackfill
ceph osd set norebalance

# ceph osd crush rule create-replicated Zone_Multi_SSD zone-multidc host ssd
ceph osd crush rule create-replicated Zone_Multi_SSD_Rack zone-multidc rack ssd

ceph osd crush rule dump Zone_Multi_SSD 

ceph osd unset norebalance
ceph osd unset nobackfill



### CHANHE root=default


## NODE 5

### STEP 1

ceph osd set nobackfill
ceph osd set norebalance



ceph osd crush add-bucket dc1-hdd datacenter
ceph osd crush add-bucket node140-hdd host
ceph osd crush add-bucket node141-hdd host
ceph osd crush add-bucket node142-hdd host

ceph osd crush add-bucket node140-room-hdd room
ceph osd crush add-bucket cloudstack-dc1-hdd rack

ceph osd crush move dc1-hdd root=default
ceph osd crush move node140-room-hdd root=default  datacenter=dc1-hdd
ceph osd crush move cloudstack-dc1-hdd root=default datacenter=dc1-hdd room=node140-room-hdd


ceph osd crush move node140-hdd root=default datacenter=dc1-hdd room=node140-room-hdd rack=cloudstack-dc1-hdd
ceph osd crush move node141-hdd root=default datacenter=dc1-hdd room=node140-room-hdd rack=cloudstack-dc1-hdd
ceph osd crush move node142-hdd root=default datacenter=dc1-hdd room=node140-room-hdd rack=cloudstack-dc1-hdd


ceph osd crush move osd.0 root=default datacenter=dc1-hdd host=node140-hdd room=node140-room-hdd rack=cloudstack-dc1-hdd
ceph osd crush move osd.3 root=default datacenter=dc1-hdd host=node141-hdd room=node140-room-hdd rack=cloudstack-dc1-hdd
ceph osd crush move osd.6 root=default datacenter=dc1-hdd host=node142-hdd room=node140-room-hdd rack=cloudstack-dc1-hdd



ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill




## NODE 6

### STEP 1

ceph osd set nobackfill
ceph osd set norebalance


ceph osd crush add-bucket dc2-hdd datacenter
ceph osd crush add-bucket node130-hdd host
ceph osd crush add-bucket node131-hdd host
ceph osd crush add-bucket node132-hdd host

ceph osd crush add-bucket node130-room-hdd room
ceph osd crush add-bucket cloudstack-dc2-hdd rack

ceph osd crush move dc2-hdd root=default
ceph osd crush move node130-room-hdd root=default  datacenter=dc2-hdd
ceph osd crush move cloudstack-dc2-hdd root=default datacenter=dc2-hdd room=node130-room-hdd


ceph osd crush move node130-hdd root=default datacenter=dc2-hdd room=node130-room-hdd rack=cloudstack-dc2-hdd
ceph osd crush move node131-hdd root=default datacenter=dc2-hdd room=node130-room-hdd rack=cloudstack-dc2-hdd
ceph osd crush move node132-hdd root=default datacenter=dc2-hdd room=node130-room-hdd rack=cloudstack-dc2-hdd


ceph osd crush move osd.12 root=default datacenter=dc2-hdd host=node130-hdd room=node130-room-hdd rack=cloudstack-dc2-hdd
ceph osd crush move osd.15 root=default datacenter=dc2-hdd host=node131-hdd room=node130-room-hdd-hdd rack=cloudstack-dc2-hdd
ceph osd crush move osd.18 root=default datacenter=dc2-hdd host=node132-hdd room=node130-room-hdd rack=cloudstack-dc2-hdd



ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill


## NODE 3

### STEP 1

ceph osd set nobackfill
ceph osd set norebalance


ceph osd crush add-bucket dc3-hdd datacenter
ceph osd crush add-bucket node133-hdd host
ceph osd crush add-bucket node143-hdd host
ceph osd crush add-bucket node170-hdd host

ceph osd crush add-bucket node170-room-hdd room
ceph osd crush add-bucket cloudstack-dc3-hdd rack

ceph osd crush move dc3-hdd root=default
ceph osd crush move node170-room-hdd root=default  datacenter=dc3-hdd
ceph osd crush move cloudstack-dc3-hdd root=default datacenter=dc3-hdd room=node170-room-hdd


ceph osd crush move node133-hdd root=default datacenter=dc3-hdd room=node170-room-hdd rack=cloudstack-dc3-hdd
ceph osd crush move node143-hdd root=default datacenter=dc3-hdd room=node170-room-hdd rack=cloudstack-dc3-hdd
ceph osd crush move node170-hdd root=default datacenter=dc3-hdd room=node170-room-hdd rack=cloudstack-dc3-hdd


ceph osd crush move osd.21 root=default datacenter=dc2-hdd host=node143-hdd room=node130-room-hdd rack=cloudstack-dc2-hdd
ceph osd crush move osd.9 root=default datacenter=dc2-hdd host=node133-hdd room=node130-room-hdd-hdd rack=cloudstack-dc2-hdd
ceph osd crush move osd.24 root=default datacenter=dc2-hdd host=node170-hdd room=node130-room-hdd rack=cloudstack-dc2-hdd


ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill









root@node140:~# ceph osd tree | more
ID    CLASS  WEIGHT   TYPE NAME                            STATUS  REWEIGHT  PRI-AFF
 -34         0.52734  root zone-multidc
 -35         0.17578      datacenter dc1-ssd
 -39         0.17578          room node140-room
 -40         0.17578              rack cloudstack-dc1
 -36         0.05859                  host node140-ssd
   1    ssd  0.02930                      osd.1                up   1.00000  1.00000
   2    ssd  0.02930                      osd.2                up   1.00000  1.00000
 -37         0.05859                  host node141-ssd
   4    ssd  0.02930                      osd.4                up   1.00000  1.00000
   5    ssd  0.02930                      osd.5                up   1.00000  1.00000
 -38         0.05859                  host node142-ssd
   7    ssd  0.02930                      osd.7                up   1.00000  1.00000
   8    ssd  0.02930                      osd.8                up   1.00000  1.00000
 -55         0.17578      datacenter dc2-ssd
 -59         0.17578          room node130-room
 -60         0.17578              rack cloudstack-dc2
 -56         0.05859                  host node130-ssd
  13    ssd  0.02930                      osd.13               up   1.00000  1.00000
  14    ssd  0.02930                      osd.14               up   1.00000  1.00000
 -57         0.05859                  host node131-ssd
  16    ssd  0.02930                      osd.16               up   1.00000  1.00000
  17    ssd  0.02930                      osd.17               up   1.00000  1.00000
 -58         0.05859                  host node132-ssd
  19    ssd  0.02930                      osd.19               up   1.00000  1.00000
  20    ssd  0.02930                      osd.20               up   1.00000  1.00000
 -73         0.17578      datacenter dc3-ssd
 -77         0.17578          room node170-room
 -78         0.17578              rack cloudstack-dc3
 -75         0.05859                  host node133-ssd
  10    ssd  0.02930                      osd.10               up   1.00000  1.00000
  11    ssd  0.02930                      osd.11               up   1.00000  1.00000
 -74         0.05859                  host node143-ssd
  25    ssd  0.02930                      osd.25               up   1.00000  1.00000
  26    ssd  0.02930                      osd.26               up   1.00000  1.00000
 -76         0.05859                  host node170-ssd
  22    ssd  0.02930                      osd.22               up   1.00000  1.00000
  23    ssd  0.02930                      osd.23               up   1.00000  1.00000
  -1         0.35156  root default
 -91         0.08789      datacenter dc1-hdd
 -95         0.08789          room node140-room-hdd
 -96         0.08789              rack cloudstack-dc1-hdd
 -92         0.02930                  host node140-hdd
   0    hdd  0.02930                      osd.0                up   1.00000  1.00000
 -93         0.02930                  host node141-hdd
   3    hdd  0.02930                      osd.3                up   1.00000  1.00000
 -94         0.02930                  host node142-hdd
   6    hdd  0.02930                      osd.6                up   1.00000  1.00000
-109         0.08789      datacenter dc2-hdd
-113         0.08789          room node130-room-hdd
-114         0.08789              rack cloudstack-dc2-hdd
-110         0.02930                  host node130-hdd
  12    hdd  0.02930                      osd.12               up   1.00000  1.00000
-111         0.02930                  host node131-hdd
  15    hdd  0.02930                      osd.15               up   1.00000  1.00000
-112         0.02930                  host node132-hdd
  18    hdd  0.02930                      osd.18               up   1.00000  1.00000
-127         0.08789      datacenter dc3-hdd
-131         0.08789          room node170-room-hdd
-132         0.08789              rack cloudstack-dc3-hdd
-128         0.02930                  host node133-hdd
   9    hdd  0.02930                      osd.9                up   1.00000  1.00000
-129         0.02930                  host node143-hdd
  21    hdd  0.02930                      osd.21               up   1.00000  1.00000
-130         0.02930                  host node170-hdd
  24    hdd  0.02930                      osd.24               up   1.00000  1.00000
 -11               0      host node130
 -13               0      host node131
 -15               0      host node132
 -17               0      host node133
  -3               0      host node140
  -5               0      host node141
  -7               0      host node142
  -9               0      host node143
 -19               0      host node170
 -21         0.08789      host node171
  27    hdd  0.02930          osd.27                           up   1.00000  1.00000
  28    hdd  0.02930          osd.28                           up   1.00000  1.00000
  29    hdd  0.02930          osd.29                           up   1.00000  1.00000
root@node140:~#










## NODE 5

### STEP 2

ceph osd tree
ceph pg dump osds

radosgw-admin realm create --default --rgw-realm=gold
radosgw-admin zonegroup delete --rgw-zonegroup=default
radosgw-admin realm default --default --rgw-realm=gold
radosgw-admin zone delete --rgw-zone=default

ceph tell mon.* injectargs --mon_allow_pool_delete true

ceph osd pool rm default.rgw.control default.rgw.control --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.data.root default.rgw.data.root --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.gc default.rgw.gc --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.log default.rgw.log --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.users.uid default.rgw.users.uid --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.meta default.rgw.meta   --yes-i-really-really-mean-it

radosgw-admin zonegroup create --rgw-zonegroup=us --master --default --endpoints=http://192.168.200.140:8400   --endpoints=http://192.168.200.141:8400  \
  --endpoints=http://192.168.200.131:8400   --endpoints=http://192.168.200.131:8400 \
  --endpoints=http://192.168.200.170:8400   --endpoints=http://192.168.200.143:8400
radosgw-admin zone create --rgw-zone=us-east --master --rgw-zonegroup=us  --endpoints=http://192.168.200.140:8400   --endpoints=http://192.168.200.141:8400  \
  --endpoints=http://192.168.200.131:8400   --endpoints=http://192.168.200.131:8400 \
  --endpoints=http://192.168.200.170:8400   --endpoints=http://192.168.200.143:8400 \
  --access-key=1234567 --secret=098765 --default

radosgw-admin user create --uid=repuser --display-name="Replication_user" --access-key=1234567 --secret=098765 --system
radosgw-admin caps add --uid=repuser --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"
radosgw-admin period update --rgw-realm=gold --commit
radosgw-admin zonegroup get --rgw-zonegroup=us

### STEP 3

rados df

ceph osd tree
ceph pg dump osds

ceph osd set nobackfill
ceph osd set norebalance

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_Node6_SSD

ceph osd tree
ceph pg dump osds
ceph -s
ceph pg dump osds
ceph -s

ceph osd unset norebalance
ceph osd unset nobackfill


### STEP 4

ceph -s

ceph osd set nobackfill
ceph osd set norebalance

radosgw-admin user create --uid=zone.user --display-name="ZoneUser" --access-key=SYSTEM_ACCESS_KEY --secret=SYSTEM_SECRET_KEY --system
radosgw-admin caps add --uid=zone.user --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"

ceph orch apply rgw gold us-east --placement="6 node140 node141 node130 node131 node170 node143"  --port=8400

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_Multi_SSD

ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill


### STEP 5

ceph osd set nobackfill
ceph osd set norebalance


wget https://dl.min.io/client/mc/release/linux-amd64/mc
mv mc /usr/bin/mc
chmod +x /usr/bin/mc
mc alias rm gcs; mc alias rm local; mc alias rm local; mc alias rm play; mc alias rm s3
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-armhf-root.tar.xz
mc alias set minio http://192.168.200.140:8400 SYSTEM_ACCESS_KEY SYSTEM_SECRET_KEY
mc ls minio
mc mb minio/test
mc tree minio
mc ls minio/test
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test1

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_Multi_SSD

ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill



ceph osd set nobackfill
ceph osd set norebalance

ceph osd crush rule create-replicated Zone_Node5_SSD zone-node5 host ssd
ceph osd crush rule dump Zone_Node5_SSD

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_Multi_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_Multi_SSD


ceph osd pool set us-east.rgw.meta  size 3
ceph osd pool set us-east.rgw.buckets.index  size 3
ceph osd pool set us-east.rgw.buckets.data  size 3
ceph osd pool set us-east.rgw.buckets.non-ec   size 3
ceph osd pool set us-east.rgw.control   size 3
ceph osd pool set us-east.rgw.log   size 3

ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill


# node140
ceph auth get-or-create client.rgw.ru-dc1 osd 'allow rwx' mon 'allow rwx'
radosgw-admin user create --uid=replica --display-name="Replication_user" --access-key=1234567890 --secret=0987654321 --system
radosgw-admin period update --commit


###  STEP 6

mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test2
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test3
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test4
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test5
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test6
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test7
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test8

ceph osd tree
ceph pg dump osds
ceph -s

### STEP 7

mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test10
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test11
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test12
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test13
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test14
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test15
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test16
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test17
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test18
ceph osd tree
ceph pg dump osds
ceph pg dump
ceph pg dump osds
ceph osd tree
ceph pg dump osds

### STEP 8

more logs
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test20
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test21
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test22
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test23
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test24

### STEP 9

ceph pg dump osds
ceph osd tree
ceph pg dump osds
ceph osd tree
ceph pg dump osds
ceph -s
ceph orch device ls
ceph orch ps
ceph -s
ceph orch ps
ceph -s
ceph orch ps
ceph -s
rados df


### LOGS

root@node140:~# ceph pg dump osds
root@node140:~# ceph orch device ls
root@node140:~# ceph -s
root@node140:~# rados df
root@node140:~# ceph osd tree






root@node140:~# ceph pg dump osds
OSD_STAT  USED     AVAIL    USED_RAW  TOTAL    HB_PEERS                                                             PG_SUM  PRIMARY_PG_SUM
29         80 MiB   30 GiB    80 MiB   30 GiB                                      [0,2,3,5,6,8,14,17,18,21,24,28]      18               5
28         80 MiB   30 GiB    80 MiB   30 GiB               [0,1,3,4,6,7,9,10,12,13,15,16,18,19,21,22,24,25,27,29]      17               6
27         80 MiB   30 GiB    80 MiB   30 GiB               [0,2,3,5,6,8,9,11,12,14,15,17,18,20,21,23,24,25,26,28]      12               5
26        1.2 GiB   29 GiB   1.2 GiB   30 GiB       [0,1,2,4,6,7,8,9,10,12,13,15,16,17,18,19,20,22,23,24,25,27,28]      19               9
25        1.1 GiB   29 GiB   1.1 GiB   30 GiB      [0,1,2,3,4,5,6,7,8,9,12,13,14,15,16,17,18,20,21,22,23,24,26,28]      22              12
24         80 MiB   30 GiB    80 MiB   30 GiB            [0,1,3,4,6,7,9,10,12,13,15,16,18,19,21,22,23,25,27,28,29]      14               3
23        959 MiB   29 GiB   959 MiB   30 GiB                    [0,2,6,7,8,9,11,12,13,14,17,18,20,21,22,24,26,29]      24               4
22        1.8 GiB   28 GiB   1.8 GiB   30 GiB   [0,1,2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,19,20,21,23,24,25,26,28]      31              11
21         80 MiB   30 GiB    80 MiB   30 GiB                            [0,3,6,8,9,11,12,15,17,20,22,24,27,28,29]      16               4
20        1.8 GiB   28 GiB   1.8 GiB   30 GiB       [0,1,2,4,5,6,7,8,10,11,12,13,15,16,17,18,19,21,22,23,25,26,29]      32              10
19        1.0 GiB   29 GiB   1.0 GiB   30 GiB                   [2,5,7,8,9,11,12,13,14,15,17,18,20,21,23,24,25,26]      25               5
18         80 MiB   30 GiB    80 MiB   30 GiB                     [0,1,3,4,6,7,9,10,13,16,17,19,20,21,24,25,27,28]      13               5
17        1.2 GiB   29 GiB   1.2 GiB   30 GiB    [0,1,2,3,4,5,6,8,10,11,12,13,14,15,16,18,19,20,21,22,23,24,26,29]      29              11
16        1.5 GiB   29 GiB   1.5 GiB   30 GiB          [0,1,2,4,5,6,7,8,10,11,13,14,15,17,19,20,22,23,24,25,26,28]      27              11
5         684 MiB   29 GiB   684 MiB   30 GiB  [0,1,2,3,4,6,7,8,9,10,11,12,14,15,16,17,18,19,20,21,22,23,24,26,29]      25              11
4         1.3 GiB   29 GiB   1.3 GiB   30 GiB               [1,3,5,6,7,8,9,10,12,13,15,16,17,18,19,20,22,23,24,25]      24               7
3         116 MiB   30 GiB   116 MiB   30 GiB                     [0,2,4,5,6,8,9,12,15,17,18,20,21,23,24,27,28,29]      27              11
2         1.3 GiB   29 GiB   1.3 GiB   30 GiB                   [0,1,3,4,5,7,8,9,10,11,13,14,16,18,19,21,22,23,25]      26               8
0          98 MiB   30 GiB    98 MiB   30 GiB                    [1,2,3,6,7,9,10,12,15,16,18,19,21,22,24,25,27,29]      18               3
1         1.4 GiB   29 GiB   1.4 GiB   30 GiB             [0,2,3,4,5,6,8,9,11,12,14,15,16,17,19,20,21,22,23,26,28]      27               7
6          99 MiB   30 GiB    99 MiB   30 GiB                      [0,1,3,4,5,7,8,9,10,12,13,15,18,21,22,24,25,27]      15               4
7         1.8 GiB   28 GiB   1.8 GiB   30 GiB      [0,1,3,5,6,8,9,10,11,13,14,15,16,17,18,19,20,21,22,24,25,26,28]      34               5
8         346 MiB   30 GiB   346 MiB   30 GiB        [0,1,2,3,4,5,6,7,9,10,11,12,13,14,15,19,20,21,22,24,25,26,29]      24               8
9          98 MiB   30 GiB    98 MiB   30 GiB                   [0,2,5,6,8,10,11,12,15,17,18,20,21,23,26,27,28,29]      16               5
10        725 MiB   29 GiB   725 MiB   30 GiB      [1,2,3,5,6,7,9,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,28]      23              14
11        1.2 GiB   29 GiB   1.2 GiB   30 GiB      [0,1,2,3,4,5,6,7,8,9,10,12,13,14,15,17,18,20,22,23,24,25,26,29]      27              14
12         80 MiB   30 GiB    80 MiB   30 GiB                    [0,3,4,6,7,9,11,13,14,15,16,18,19,22,24,25,27,29]      16               7
13        1.1 GiB   29 GiB   1.1 GiB   30 GiB                     [0,2,3,5,7,8,9,10,11,12,14,16,17,18,20,21,23,28]      34               8
14        1.3 GiB   29 GiB   1.3 GiB   30 GiB                  [0,1,2,4,6,7,8,10,11,12,13,15,16,17,18,20,21,22,25]      27               5
15         81 MiB   30 GiB    81 MiB   30 GiB                           [0,2,3,5,6,8,9,12,13,14,16,18,24,27,28,29]      13               7
sum        23 GiB  877 GiB    23 GiB  900 GiB
dumped osds

root@node140:~# ceph orch device ls
HOST     PATH      TYPE  DEVICE ID                         SIZE  AVAILABLE  REFRESHED  REJECT REASONS
node130  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         24m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node130  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         24m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node130  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         24m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         23m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         23m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         23m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         22m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         22m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         22m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         21m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         21m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         21m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node140  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         28m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node140  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         28m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node140  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         28m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         27m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         27m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         27m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         26m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         26m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         26m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         25m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         25m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         25m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node170  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         20m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node170  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         20m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node170  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         20m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node171  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         19m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node171  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         19m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node171  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         19m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
root@node140:~#

root@node140:~# ceph -s
  cluster:
    id:     7156dcb0-e8fe-11ee-99a3-a15389e6e101
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node170,node130 (age 29m)
    mgr: node140.ijbcdt(active, since 32m), standbys: node130.dlceul, node170.uhawrs
    osd: 30 osds: 30 up (since 19m), 30 in (since 19m)
    rgw: 6 daemons active (6 hosts, 1 zones)

  data:
    pools:   8 pools, 225 pgs
    objects: 1.97k objects, 6.6 GiB
    usage:   23 GiB used, 877 GiB / 900 GiB avail
    pgs:     225 active+clean

root@node140:~#


root@node140:~# rados df
POOL_NAME                      USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS       RD  WR_OPS       WR  USED COMPR  UNDER COMPR
.mgr                        4.5 MiB        2       0       6                   0        0         0     136  118 KiB     203  3.4 MiB         0 B          0 B
.rgw.root                   192 KiB       17       0      51                   0        0         0     131  148 KiB       0      0 B         0 B          0 B
us-east.rgw.buckets.data     20 GiB     1738       0    5214                   0        0         0       0      0 B    3142  4.1 GiB         0 B          0 B
us-east.rgw.buckets.index       0 B       11       0      33                   0        0         0    3124  2.4 MiB    1373  686 KiB         0 B          0 B
us-east.rgw.buckets.non-ec    4 KiB        0       0       0                   0        0         0    2348  1.7 MiB     563  389 KiB         0 B          0 B
us-east.rgw.control             0 B        8       0      24                   0        0         0       0      0 B       0      0 B         0 B          0 B
us-east.rgw.log             444 KiB      179       0     537                   0        0         0    2373  2.2 MiB    1378   18 KiB         0 B          0 B
us-east.rgw.meta            140 KiB       10       0      30                   0        0         0      43   33 KiB      22   10 KiB         0 B          0 B

total_objects    1965
total_used       23 GiB
total_avail      877 GiB
total_space      900 GiB
root@node140:~#

root@node140:~# ceph osd tree 
ID    CLASS  WEIGHT   TYPE NAME                            STATUS  REWEIGHT  PRI-AFF
 -34         0.52734  root zone-multidc
 -35         0.17578      datacenter dc1-ssd
 -39         0.17578          room node140-room
 -40         0.17578              rack cloudstack-dc1
 -36         0.05859                  host node140-ssd
   1    ssd  0.02930                      osd.1                up   1.00000  1.00000
   2    ssd  0.02930                      osd.2                up   1.00000  1.00000
 -37         0.05859                  host node141-ssd
   4    ssd  0.02930                      osd.4                up   1.00000  1.00000
   5    ssd  0.02930                      osd.5                up   1.00000  1.00000
 -38         0.05859                  host node142-ssd
   7    ssd  0.02930                      osd.7                up   1.00000  1.00000
   8    ssd  0.02930                      osd.8                up   1.00000  1.00000
 -55         0.17578      datacenter dc2-ssd
 -59         0.17578          room node130-room
 -60         0.17578              rack cloudstack-dc2
 -56         0.05859                  host node130-ssd
  13    ssd  0.02930                      osd.13               up   1.00000  1.00000
  14    ssd  0.02930                      osd.14               up   1.00000  1.00000
 -57         0.05859                  host node131-ssd
  16    ssd  0.02930                      osd.16               up   1.00000  1.00000
  17    ssd  0.02930                      osd.17               up   1.00000  1.00000
 -58         0.05859                  host node132-ssd
  19    ssd  0.02930                      osd.19               up   1.00000  1.00000
  20    ssd  0.02930                      osd.20               up   1.00000  1.00000
 -73         0.17578      datacenter dc3-ssd
 -77         0.17578          room node170-room
 -78         0.17578              rack cloudstack-dc3
 -75         0.05859                  host node133-ssd
  10    ssd  0.02930                      osd.10               up   1.00000  1.00000
  11    ssd  0.02930                      osd.11               up   1.00000  1.00000
 -74         0.05859                  host node143-ssd
  25    ssd  0.02930                      osd.25               up   1.00000  1.00000
  26    ssd  0.02930                      osd.26               up   1.00000  1.00000
 -76         0.05859                  host node170-ssd
  22    ssd  0.02930                      osd.22               up   1.00000  1.00000
  23    ssd  0.02930                      osd.23               up   1.00000  1.00000
  -1         0.35156  root default
 -91         0.08789      datacenter dc1-hdd
 -95         0.08789          room node140-room-hdd
 -96         0.08789              rack cloudstack-dc1-hdd
 -92         0.02930                  host node140-hdd
   0    hdd  0.02930                      osd.0                up   1.00000  1.00000
 -93         0.02930                  host node141-hdd
   3    hdd  0.02930                      osd.3                up   1.00000  1.00000
 -94         0.02930                  host node142-hdd
   6    hdd  0.02930                      osd.6                up   1.00000  1.00000
-109         0.08789      datacenter dc2-hdd
-113         0.08789          room node130-room-hdd
-114         0.08789              rack cloudstack-dc2-hdd
-110         0.02930                  host node130-hdd
  12    hdd  0.02930                      osd.12               up   1.00000  1.00000
-111         0.02930                  host node131-hdd
  15    hdd  0.02930                      osd.15               up   1.00000  1.00000
-112         0.02930                  host node132-hdd
  18    hdd  0.02930                      osd.18               up   1.00000  1.00000
-127         0.08789      datacenter dc3-hdd
-131         0.08789          room node170-room-hdd
-132         0.08789              rack cloudstack-dc3-hdd
-128         0.02930                  host node133-hdd
   9    hdd  0.02930                      osd.9                up   1.00000  1.00000
-129         0.02930                  host node143-hdd
  21    hdd  0.02930                      osd.21               up   1.00000  1.00000
-130         0.02930                  host node170-hdd
  24    hdd  0.02930                      osd.24               up   1.00000  1.00000
 -11               0      host node130
 -13               0      host node131
 -15               0      host node132
 -17               0      host node133
  -3               0      host node140
  -5               0      host node141
  -7               0      host node142
  -9               0      host node143
 -19               0      host node170
 -21         0.08789      host node171
  27    hdd  0.02930          osd.27                           up   1.00000  1.00000
  28    hdd  0.02930          osd.28                           up   1.00000  1.00000
  29    hdd  0.02930          osd.29                           up   1.00000  1.00000
root@node140:~#




ceph osd set nobackfill
ceph osd set norebalance

ceph osd crush rule create-replicated Zone_Multi_SSD_Rack zone-multidc rack ssd

ceph osd crush rule dump Zone_Multi_SSD_Rack 

ceph osd unset norebalance
ceph osd unset nobackfill




rados df

ceph osd tree
ceph pg dump osds

ceph osd set nobackfill
ceph osd set norebalance

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_Multi_SSD_Rack
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_Multi_SSD_Rack
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_Multi_SSD_Rack
ceph osd pool set us-east.rgw.log  crush_rule Zone_Multi_SSD_Rack
ceph osd pool set us-east.rgw.meta  crush_rule Zone_Multi_SSD_Rack

ceph osd tree
ceph pg dump osds
ceph -s
ceph pg dump osds
ceph -s

ceph osd unset norebalance
ceph osd unset nobackfill



root@node140:~# ceph pg dump osds pgs_brief | grep 10 | more
3.a      active+clean   [2,10,19]           2   [2,10,19]               2
3.b      active+clean   [13,7,10]          13   [13,7,10]              13
8.2      active+clean   [10,2,13]          10   [10,2,13]              10
3.4      active+clean   [4,17,10]           4   [4,17,10]               4
8.e      active+clean   [17,2,10]          17   [17,2,10]              17
3.5      active+clean   [10,16,7]          10   [10,16,7]              10
6.0      active+clean   [10,2,14]          10   [10,2,14]              10
7.1      active+clean   [10,14,7]          10   [10,14,7]              10
7.5      active+clean   [7,19,10]           7   [7,19,10]               7
3.0      active+clean   [8,10,16]           8   [8,10,16]               8
5.6      active+clean   [2,19,10]           2   [2,19,10]               2
3.d      active+clean   [10,7,19]          10   [10,7,19]              10
3.c      active+clean   [5,10,20]           5   [5,10,20]               5
5.a      active+clean   [16,10,1]          16   [16,10,1]              16
7.b      active+clean   [10,5,17]          10   [10,5,17]              10
8.5      active+clean   [10,14,1]          10   [10,14,1]              10
6.14     active+clean   [4,20,10]           4   [4,20,10]               4
2.10     active+clean   [29,24,6]          29   [29,24,6]              29
8.1b     active+clean   [10,2,16]          10   [10,2,16]              10
3.10     active+clean   [5,14,23]           5   [5,14,23]               5
5.16     active+clean   [5,10,16]           5   [5,10,16]               5
6.17     active+clean   [10,7,19]          10   [10,7,19]              10
3.12     active+clean   [10,2,14]          10   [10,2,14]              10
6.10     active+clean   [16,11,7]          16   [16,11,7]              16
3.15     active+clean   [10,16,8]          10   [10,16,8]              10
8.1f     active+clean   [10,1,14]          10   [10,1,14]              10
3.14     active+clean   [10,20,2]          10   [10,20,2]              10
7.10     active+clean   [11,2,16]          11   [11,2,16]              11
4.10     active+clean   [21,6,29]          21   [21,6,29]              21
5.10     active+clean   [11,20,7]          11   [11,20,7]              11
8.10     active+clean   [25,2,13]          25   [25,2,13]              25
7.19     active+clean   [13,2,10]          13   [13,2,10]              13
5.19     active+clean   [13,5,10]          13   [13,5,10]              13
29         100 MiB   30 GiB   100 MiB   30 GiB                    [0,2,3,5,6,8,9,11,12,14,15,17,18,20,21,23,24,26,28]      18               5
28         100 MiB   30 GiB   100 MiB   30 GiB                 [0,1,3,4,6,7,9,10,12,13,15,16,18,19,21,22,24,25,27,29]      17               6
27         100 MiB   30 GiB   100 MiB   30 GiB                 [0,2,3,5,6,8,9,11,12,14,15,17,18,20,21,23,24,25,26,28]      12               5
26         1.2 GiB   29 GiB   1.2 GiB   30 GiB     [0,1,2,3,4,5,6,7,8,9,10,12,13,15,16,17,18,19,20,21,22,24,25,27,28]      23               9
24         100 MiB   30 GiB   100 MiB   30 GiB           [0,1,3,4,6,7,9,10,12,13,15,16,18,19,21,22,23,25,26,27,28,29]      14               3
22         1.6 GiB   28 GiB   1.6 GiB   30 GiB     [0,1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,20,21,23,24,25,28]      36              12
21         100 MiB   30 GiB   100 MiB   30 GiB           [0,2,3,5,6,8,9,11,12,14,15,17,18,19,20,22,23,24,26,27,28,29]      16               4
20         1.4 GiB   29 GiB   1.4 GiB   30 GiB     [0,1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,18,19,21,22,23,24,25,26,29]      29              10
19        1018 MiB   29 GiB  1018 MiB   30 GiB             [0,2,3,4,5,6,7,8,9,11,12,14,15,17,18,20,21,23,24,25,26,28]      21               5
18         100 MiB   30 GiB   100 MiB   30 GiB              [0,1,3,4,6,7,9,10,12,13,15,16,17,19,20,21,22,24,25,27,28]      13               5
17         1.2 GiB   29 GiB   1.2 GiB   30 GiB        [0,1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,18,20,21,22,23,24,26,29]      28              11
16         2.2 GiB   28 GiB   2.2 GiB   30 GiB     [0,1,2,3,4,5,6,7,8,9,10,11,12,13,15,17,18,19,21,22,23,24,25,26,28]      32              11
5          934 MiB   29 GiB   934 MiB   30 GiB   [0,2,3,4,6,7,8,9,10,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,29]      23              11
4          1.5 GiB   28 GiB   1.5 GiB   30 GiB        [0,1,3,5,6,7,9,10,12,13,14,15,16,17,18,19,20,21,22,24,25,26,28]      25               7
2          1.4 GiB   29 GiB   1.4 GiB   30 GiB           [0,1,3,4,6,7,9,10,11,12,13,14,15,16,18,19,21,22,23,24,25,29]      28               8
0          100 MiB   30 GiB   100 MiB   30 GiB                 [1,2,3,4,6,7,9,10,12,13,15,16,18,19,21,22,24,25,27,29]      18               3
6          100 MiB   30 GiB   100 MiB   30 GiB                  [0,1,3,4,5,7,8,9,10,12,13,15,16,18,19,21,22,24,25,27]      15               4
7          1.8 GiB   28 GiB   1.8 GiB   30 GiB  [0,2,3,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28]      33               5
8          364 MiB   30 GiB   364 MiB   30 GiB     [0,1,3,4,6,7,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,29]      25               8
9          100 MiB   30 GiB   100 MiB   30 GiB           [0,2,3,5,6,7,8,10,11,12,14,15,17,18,20,21,23,24,26,27,28,29]      16               5
10        1014 MiB   29 GiB  1014 MiB   30 GiB     [0,1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,19,20,21,22,24,25,28]      26              13
11         1.5 GiB   28 GiB   1.5 GiB   30 GiB        [0,1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,20,21,23,24,26,29]      28              14
12         100 MiB   30 GiB   100 MiB   30 GiB              [0,1,3,4,6,7,9,10,11,13,14,15,16,18,19,21,22,24,25,27,29]      16               7
13         766 MiB   29 GiB   766 MiB   30 GiB             [0,1,2,3,5,6,7,8,9,10,11,12,14,15,17,18,20,21,23,24,26,28]      23               8
14         899 MiB   29 GiB   899 MiB   30 GiB    [0,1,2,3,4,6,7,8,9,10,11,12,13,15,16,18,19,20,21,22,23,24,25,26,29]      27               5
15         100 MiB   30 GiB   100 MiB   30 GiB           [0,2,3,5,6,8,9,11,12,13,14,16,17,18,20,21,23,24,26,27,28,29]      13               7


```
