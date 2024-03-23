
```
watch -n 2 ceph -s


                                                                   |------------------------node130:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-node6):sdd(ssd-class,root:zone-node6)
                                                                   |
                                                                   |------------------------node131:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-node6):sdd(ssd-class,root:zone-node6)
               |------(node6:vlan200,vlan400,vlan600,vlan800) -----|
               |                                                   |------------------------node132:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-node6):sdd(ssd-class,root:zone-node6)
               |                                                   |
               |                                                   |------------------------node133:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-node6):sdd(ssd-class,root:zone-node6)
               |
               |
               |
               |                                                   |------------------------node140:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-node5):sdd(ssd-class,root:zone-node5)
               |                                                   |
               |                                                   |------------------------node141:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-node5):sdd(ssd-class,root:zone-node5)
               |------(node5:vlan200,vlan400,vlan600,vlan800) -----|
                                                                   |------------------------node142:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-node5):sdd(ssd-class,root:zone-node5)
                                                                   |
                                                                   |------------------------node143:sdb(hdd-class,root:default):sdc(ssd-class,root:zone-node5):sdd(ssd-class,root:zone-node5)




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

ceph osd crush rm-device-class osd.10 && ceph osd crush set-device-class ssd osd.10
ceph osd crush rm-device-class osd.11 && ceph osd crush set-device-class ssd osd.11


ceph osd crush add-bucket zone-node5 root

ceph osd crush add-bucket ssd-node130 host
ceph osd crush add-bucket ssd-node131 host
ceph osd crush add-bucket ssd-node132 host
ceph osd crush add-bucket ssd-node133 host

ceph osd crush move ssd-node130 root=zone-node5
ceph osd crush move ssd-node131 root=zone-node5
ceph osd crush move ssd-node132 root=zone-node5
ceph osd crush move ssd-node133 root=zone-node5


ceph osd crush add-bucket zone-node6 root

ceph osd crush move osd.1 root=zone-node5 host=ssd-node140
ceph osd crush move osd.2 root=zone-node5 host=ssd-node140

ceph osd crush move osd.4 root=zone-node5 host=ssd-node141
ceph osd crush move osd.5 root=zone-node5 host=ssd-node141

ceph osd crush move osd.7 root=zone-node5 host=ssd-node142
ceph osd crush move osd.8 root=zone-node5 host=ssd-node142

ceph osd crush move osd.10 root=zone-node5 host=ssd-node143
ceph osd crush move osd.11 root=zone-node5 host=ssd-node143


ceph osd crush rule create-replicated Zone_Node5_SSD zone-node5 host ssd
ceph osd crush rule dump Zone_Node5_SSD

ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill




## NODE 6

ceph osd set nobackfill
ceph osd set norebalance

ceph osd crush rm-device-class osd.1 && ceph osd crush set-device-class ssd osd.1
ceph osd crush rm-device-class osd.2 && ceph osd crush set-device-class ssd osd.2

ceph osd crush rm-device-class osd.4 && ceph osd crush set-device-class ssd osd.4
ceph osd crush rm-device-class osd.5 && ceph osd crush set-device-class ssd osd.5

ceph osd crush rm-device-class osd.7 && ceph osd crush set-device-class ssd osd.7
ceph osd crush rm-device-class osd.8 && ceph osd crush set-device-class ssd osd.8

ceph osd crush rm-device-class osd.10 && ceph osd crush set-device-class ssd osd.10
ceph osd crush rm-device-class osd.11 && ceph osd crush set-device-class ssd osd.11

ceph osd crush add-bucket ssd-node130 host
ceph osd crush add-bucket ssd-node131 host
ceph osd crush add-bucket ssd-node132 host
ceph osd crush add-bucket ssd-node133 host


ceph osd crush move ssd-node130 root=zone-node6
ceph osd crush move ssd-node131 root=zone-node6
ceph osd crush move ssd-node132 root=zone-node6
ceph osd crush move ssd-node133 root=zone-node6


ceph osd crush move osd.1 root=zone-node6 host=ssd-node130
ceph osd crush move osd.2 root=zone-node6 host=ssd-node130

ceph osd crush move osd.4 root=zone-node6 host=ssd-node131
ceph osd crush move osd.5 root=zone-node6 host=ssd-node131

ceph osd crush move osd.7 root=zone-node6 host=ssd-node132
ceph osd crush move osd.8 root=zone-node6 host=ssd-node132

ceph osd crush move osd.10 root=zone-node6 host=ssd-node133
ceph osd crush move osd.11 root=zone-node6 host=ssd-node133



ceph osd crush rule create-replicated Zone_Node6_SSD zone-node6 host ssd
ceph osd crush rule dump Zone_Node6_SSD

ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill



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

radosgw-admin zonegroup create --rgw-zonegroup=us --master --default --endpoints=http://192.168.200.140:8400 \
  --endpoints=http://192.168.200.141:8400   --endpoints=http://192.168.200.142:8400
radosgw-admin zone create --rgw-zone=us-east --master --rgw-zonegroup=us --endpoints=http://192.168.200.140:8400 \
  --endpoints=http://192.168.200.141:8400   --endpoints=http://192.168.200.142:8400 --access-key=1234567 --secret=098765 --default
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

ceph orch apply rgw gold us-east --placement="3 node140 node141 node142"  --port=8400

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_Node6_SSD

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

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_Node6_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_Node6_SSD

ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill



ceph osd set nobackfill
ceph osd set norebalance

ceph osd crush rule create-replicated Zone_Node5_SSD zone-node5 host ssd
ceph osd crush rule dump Zone_Node5_SSD

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_Node5_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_Node5_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_Node5_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_Node5_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_Node5_SSD


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
OSD_STAT  USED     AVAIL    USED_RAW  TOTAL    HB_PEERS                   PG_SUM  PRIMARY_PG_SUM
11         78 MiB   30 GiB    78 MiB   30 GiB     [0,2,3,4,5,6,7,8,9,10]      80              27
10        2.8 GiB   27 GiB   2.8 GiB   30 GiB   [0,1,2,3,4,5,6,7,8,9,11]      87              22
9          65 MiB   30 GiB    65 MiB   30 GiB    [0,2,3,4,5,6,7,8,10,11]       0               0
8         3.4 GiB   27 GiB   3.4 GiB   30 GiB  [0,1,2,3,4,5,6,7,9,10,11]      65              22
7         2.8 GiB   27 GiB   2.8 GiB   30 GiB    [0,1,2,3,4,5,6,8,10,11]      66              24
6          78 MiB   30 GiB    78 MiB   30 GiB    [0,1,3,4,5,7,8,9,10,11]      74              26
1         2.2 GiB   28 GiB   2.2 GiB   30 GiB    [0,2,3,4,5,6,7,8,10,11]      68              22
0          77 MiB   30 GiB    77 MiB   30 GiB    [1,2,3,4,6,7,8,9,10,11]      68              24
2         3.5 GiB   26 GiB   3.5 GiB   30 GiB  [0,1,3,4,5,6,7,8,9,10,11]      61              17
3          78 MiB   30 GiB    78 MiB   30 GiB  [0,1,2,4,5,6,7,8,9,10,11]      69              20
4         2.7 GiB   27 GiB   2.7 GiB   30 GiB  [0,1,2,3,5,6,7,8,9,10,11]      68              27
5         2.9 GiB   27 GiB   2.9 GiB   30 GiB    [0,1,2,3,4,6,7,8,10,11]      65              26
sum        21 GiB  339 GiB    21 GiB  360 GiB
dumped osds
root@node140:~#  ceph orch device ls
HOST     PATH      TYPE  DEVICE ID                         SIZE  AVAILABLE  REFRESHED  REJECT REASONS
node140  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         5m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node140  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         5m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node140  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         5m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         3m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         3m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         3m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
root@node140:~#

root@node140:~# ceph -s
  cluster:
    id:     78c57cac-e8e2-11ee-baa9-dd51b7ff7c6d
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 36m)
    mgr: node140.lviznw(active, since 40m), standbys: node142.npyhzb, node141.ldoqyl
    osd: 12 osds: 12 up (since 33m), 12 in (since 33m)
    rgw: 3 daemons active (3 hosts, 1 zones)

  data:
    pools:   9 pools, 257 pgs
    objects: 2.26k objects, 6.6 GiB
    usage:   21 GiB used, 339 GiB / 360 GiB avail
    pgs:     257 active+clean

  io:
    client:   16 KiB/s rd, 0 B/s wr, 15 op/s rd, 11 op/s wr

root@node140:~# rados df
POOL_NAME                      USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS       RD  WR_OPS       WR  USED COMPR  UNDER COMPR
.mgr                        4.5 MiB        2       0       6                   0        0         0     136  118 KiB     203  3.4 MiB         0 B          0 B
.rgw.root                   228 KiB       20       0      60                   0        0         0     224  252 KiB      29   20 KiB         0 B          0 B
us-east.rgw.buckets.data     20 GiB     1738       0    5214                   0        0         0    1850  6.6 GiB    4809  6.3 GiB         0 B          0 B
us-east.rgw.buckets.index       0 B       11       0      33                   0        0         0    4423  3.5 MiB    2471  1.5 MiB         0 B          0 B
us-east.rgw.buckets.non-ec      0 B        0       0       0                   0        0         0    2667  1.9 MiB     651  441 KiB         0 B          0 B
us-east.rgw.control             0 B        8       0      24                   0        0         0       0      0 B       0      0 B         0 B          0 B
us-east.rgw.log             3.6 MiB      467       0    1401                   0        0         0   49948   47 MiB    5732  784 KiB         0 B          0 B
us-east.rgw.meta            164 KiB       14       0      42                   0        0         0     629  560 KiB      28   12 KiB         0 B          0 B
us-east.rgw.otp                 0 B        0       0       0                   0        0         0       0      0 B       0      0 B         0 B          0 B

total_objects    2260
total_used       21 GiB
total_avail      339 GiB
total_space      360 GiB
root@node140:~#


root@node140:~# ceph osd tree
ID   CLASS  WEIGHT   TYPE NAME             STATUS  REWEIGHT  PRI-AFF
-16         0.23438  root zone-node5
-34         0.05859      host ssd-node140
  1    ssd  0.02930          osd.1             up   1.00000  1.00000
  2    ssd  0.02930          osd.2             up   1.00000  1.00000
-37         0.05859      host ssd-node141
  4    ssd  0.02930          osd.4             up   1.00000  1.00000
  5    ssd  0.02930          osd.5             up   1.00000  1.00000
-40         0.05859      host ssd-node142
  7    ssd  0.02930          osd.7             up   1.00000  1.00000
  8    ssd  0.02930          osd.8             up   1.00000  1.00000
-43         0.05859      host ssd-node143
  9    hdd  0.02930          osd.9             up   1.00000  1.00000
 10    ssd  0.02930          osd.10            up   1.00000  1.00000
 -1         0.11719  root default
 -3         0.02930      host node140
  0    hdd  0.02930          osd.0             up   1.00000  1.00000
 -5         0.02930      host node141
  3    hdd  0.02930          osd.3             up   1.00000  1.00000
 -7         0.02930      host node142
  6    hdd  0.02930          osd.6             up   1.00000  1.00000
 -9         0.02930      host node143
 11    ssd  0.02930          osd.11            up   1.00000  1.00000


## NODE 5

### node130

radosgw-admin realm create --default --rgw-realm=gold
radosgw-admin zonegroup delete --rgw-zonegroup=default
radosgw-admin realm default --default --rgw-realm=gold
radosgw-admin zone delete --rgw-zone=default


radosgw-admin user create --uid=repuser --display-name="Replication_user" --access-key=1234567 --secret=098765 --system
radosgw-admin period update --commit

ceph tell mon.* injectargs --mon_allow_pool_delete true

ceph osd pool rm default.rgw.control default.rgw.control --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.data.root default.rgw.data.root --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.gc default.rgw.gc --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.log default.rgw.log --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.users.uid default.rgw.users.uid --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.meta default.rgw.meta   --yes-i-really-really-mean-it

radosgw-admin realm pull --rgw-realm=gold --rgw-zone=nefelim --url=http://192.168.200.140:8400 --access-key=1234567890 --secret=0987654321 --default
radosgw-admin period update --commit

sleep 20

radosgw-admin zone create --rgw-realm=gold  --rgw-zone=nefelim --rgw-zonegroup=us
sleep 10
radosgw-admin zone modify --rgw-zone=nefelim --rgw-zonegroup=us --endpoints=http://192.168.200.130:9400  \
   --endpoints=http://192.168.200.131:9400 --endpoints=http://192.168.200.132:9400 --access-key=1234567 --secret=098765 --default
ceph orch apply rgw s3store-nefelim --placement="3 node130 node131 node132"  --realm gold --zone nefelim --port 9400
radosgw-admin period update --commit

sleep 10

radosgw-admin realm pull --rgw-realm=gold --rgw-zone=nefelim --url=http://192.168.200.140:8400 --access-key=1234567890 --secret=0987654321 --default
radosgw-admin period update --commit

sleep 10

radosgw-admin user create --uid=zone.user4 --display-name="ZoneUser4" --access-key=SYSTEM_ACCESS_KEY4 --secret=SYSTEM_SECRET_KEY4 --system --yes-i-really-mean-it
radosgw-admin caps add --uid=zone.user4 --caps="users=*;buckets=*;metadata=*;usage=*;zone=*" --yes-i-really-mean-it






ceph osd set nobackfill
ceph osd set norebalance

ceph osd crush rule create-replicated Zone_Node5_SSD zone-node6 host ssd
ceph osd crush rule dump Zone_Node6_SSD

ceph osd pool set nefelim.rgw.buckets.data crush_rule Zone_Node6_SSD
ceph osd pool set nefelim.rgw.buckets.non-ec crush_rule Zone_Node6_SSD
ceph osd pool set nefelim.rgw.buckets.index crush_rule Zone_Node6_SSD
ceph osd pool set nefelim.rgw.log  crush_rule Zone_Node6_SSD
ceph osd pool set nefelim.rgw.meta  crush_rule Zone_Node6_SSD


ceph osd pool set nefelim.rgw.meta  size 3
ceph osd pool set nefelim.rgw.buckets.index  size 3
ceph osd pool set nefelim.rgw.buckets.data  size 3
ceph osd pool set nefelim.rgw.buckets.non-ec   size 3
ceph osd pool set nefelim.rgw.control   size 3
ceph osd pool set nefelim.rgw.log   size 3

ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill



### LOGS

root@node130:~# ceph pg dump osds
root@node130:~# ceph orch device ls
root@node130:~# ceph -s
root@node130:~# rados df
root@node130:~# ceph osd tree

root@node130:~# ceph pg dump osds
OSD_STAT  USED     AVAIL    USED_RAW  TOTAL    HB_PEERS                   PG_SUM  PRIMARY_PG_SUM
11        2.1 GiB   28 GiB   2.1 GiB   30 GiB   [0,1,2,3,4,5,6,7,8,9,10]      44              19
10        2.3 GiB   28 GiB   2.3 GiB   30 GiB   [0,1,2,3,4,5,6,7,8,9,11]      50              18
9          97 MiB   30 GiB    97 MiB   30 GiB    [0,2,3,4,5,6,7,8,10,11]      49              18
8         2.0 GiB   28 GiB   2.0 GiB   30 GiB  [0,1,2,3,4,5,6,7,9,10,11]      44              10
7         2.1 GiB   28 GiB   2.1 GiB   30 GiB  [0,1,2,3,4,5,6,8,9,10,11]      47              13
6          80 MiB   30 GiB    80 MiB   30 GiB     [0,1,2,3,4,5,7,8,9,10]      48              13
1         2.4 GiB   28 GiB   2.4 GiB   30 GiB  [0,2,3,4,5,6,7,8,9,10,11]      49              22
0          97 MiB   30 GiB    97 MiB   30 GiB    [1,2,3,4,6,7,8,9,10,11]      52              19
2         2.1 GiB   28 GiB   2.1 GiB   30 GiB  [0,1,3,4,5,6,7,8,9,10,11]      48              19
3          97 MiB   30 GiB    97 MiB   30 GiB     [0,1,2,4,5,6,7,8,9,11]      46              15
4         3.3 GiB   27 GiB   3.3 GiB   30 GiB  [0,1,2,3,5,6,7,8,9,10,11]      59               9
5         1.9 GiB   28 GiB   1.9 GiB   30 GiB  [0,1,2,3,4,6,7,8,9,10,11]      43              18
sum        19 GiB  341 GiB    19 GiB  360 GiB
dumped osds
root@node130:~# ceph orch device ls
HOST     PATH      TYPE  DEVICE ID                         SIZE  AVAILABLE  REFRESHED  REJECT REASONS
node130  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         4m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node130  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         4m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node130  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         4m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         3m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         3m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         3m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         2m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         55s ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         55s ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         55s ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected

root@node130:~# ceph -s
  cluster:
    id:     7e554b98-e8e2-11ee-a2ef-11c40edf07a9
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node130,node132,node131 (age 35m)
    mgr: node130.uypnvo(active, since 38m), standbys: node132.tqjfpp, node131.cmgfbi
    osd: 12 osds: 12 up (since 31m), 12 in (since 31m)
    rgw: 3 daemons active (3 hosts, 1 zones)

  data:
    pools:   7 pools, 193 pgs
    objects: 2.32k objects, 6.6 GiB
    usage:   21 GiB used, 339 GiB / 360 GiB avail
    pgs:     193 active+clean

  io:
    client:   15 KiB/s rd, 33 MiB/s wr, 15 op/s rd, 26 op/s wr

root@node130:~# rados df
POOL_NAME                     USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS       RD  WR_OPS       WR  USED COMPR  UNDER COMPR
.mgr                       4.5 MiB        2       0       6                   0        0         0     136  118 KiB     203  3.4 MiB         0 B          0 B
.rgw.root                  384 KiB       34       0     102                   0        0         0     139  161 KiB      64   43 KiB         0 B          0 B
nefelim.rgw.buckets.data    20 GiB     1716       0    5148                   0        0         0      16   16 KiB    1302  4.2 GiB         0 B          0 B
nefelim.rgw.buckets.index      0 B       11       0      33                   0        0         0     117   89 KiB      56   42 KiB         0 B          0 B
nefelim.rgw.control            0 B        8       0      24                   0        0         0       0      0 B       0      0 B         0 B          0 B
nefelim.rgw.log            4.3 MiB      530       0    1590                   0        0         0    2778  2.7 MiB     903   78 KiB         0 B          0 B
nefelim.rgw.meta           164 KiB       18       0      54                   0        0         0      38   30 KiB       3      0 B         0 B          0 B

total_objects    2319
total_used       21 GiB
total_avail      339 GiB
total_space      360 GiB

root@node130:~# ceph osd tree
ID   CLASS  WEIGHT   TYPE NAME             STATUS  REWEIGHT  PRI-AFF
-28         0.23438  root zone-node6
-16         0.05859      host ssd-node130
  1    ssd  0.02930          osd.1             up   1.00000  1.00000
  2    ssd  0.02930          osd.2             up   1.00000  1.00000
-17         0.05859      host ssd-node131
  4    ssd  0.02930          osd.4             up   1.00000  1.00000
  5    ssd  0.02930          osd.5             up   1.00000  1.00000
-18         0.05859      host ssd-node132
  7    ssd  0.02930          osd.7             up   1.00000  1.00000
  8    ssd  0.02930          osd.8             up   1.00000  1.00000
-19         0.05859      host ssd-node133
 10    ssd  0.02930          osd.10            up   1.00000  1.00000
 11    ssd  0.02930          osd.11            up   1.00000  1.00000
 -1         0.11719  root default
 -3         0.02930      host node130
  0    hdd  0.02930          osd.0             up   1.00000  1.00000
 -5         0.02930      host node131
  3    hdd  0.02930          osd.3             up   1.00000  1.00000
 -7         0.02930      host node132
  6    hdd  0.02930          osd.6             up   1.00000  1.00000
 -9         0.02930      host node133
  9    hdd  0.02930          osd.9             up   1.00000  1.00000

```
