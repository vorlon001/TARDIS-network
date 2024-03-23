
```
### STEP 0

watch -n 2 ceph -s


### STEP 1
ceph osd set nobackfill
ceph osd set norebalance

ceph osd crush rm-device-class osd.12 && ceph osd crush set-device-class ssd osd.12
ceph osd crush rm-device-class osd.13 && ceph osd crush set-device-class ssd osd.13

ceph osd crush rm-device-class osd.15 && ceph osd crush set-device-class ssd osd.15
ceph osd crush rm-device-class osd.16 && ceph osd crush set-device-class ssd osd.16

ceph osd crush rm-device-class osd.18 && ceph osd crush set-device-class ssd osd.18
ceph osd crush rm-device-class osd.19 && ceph osd crush set-device-class ssd osd.19

ceph osd crush rm-device-class osd.21 && ceph osd crush set-device-class ssd osd.21
ceph osd crush rm-device-class osd.22 && ceph osd crush set-device-class ssd osd.22


ceph osd crush add-bucket zone-26 root 



ceph osd crush add-bucket ssd-node130 host
ceph osd crush add-bucket ssd-node131 host
ceph osd crush add-bucket ssd-node132 host
ceph osd crush add-bucket ssd-node133 host

ceph osd crush move ssd-node130 root=zone-26
ceph osd crush move ssd-node131 root=zone-26
ceph osd crush move ssd-node132 root=zone-26
ceph osd crush move ssd-node133 root=zone-26


ceph osd crush add-bucket zone-26 root

ceph osd crush move osd.12 root=zone-26 host=ssd-node130
ceph osd crush move osd.13 root=zone-26 host=ssd-node130

ceph osd crush move osd.15 root=zone-26 host=ssd-node131
ceph osd crush move osd.16 root=zone-26 host=ssd-node131

ceph osd crush move osd.18 root=zone-26 host=ssd-node132
ceph osd crush move osd.19 root=zone-26 host=ssd-node132

ceph osd crush move osd.21 root=zone-26 host=ssd-node133
ceph osd crush move osd.22 root=zone-26 host=ssd-node133



ceph osd crush rm-device-class osd.1 && ceph osd crush set-device-class ssd osd.1
ceph osd crush rm-device-class osd.2 && ceph osd crush set-device-class ssd osd.2

ceph osd crush rm-device-class osd.4 && ceph osd crush set-device-class ssd osd.4
ceph osd crush rm-device-class osd.5 && ceph osd crush set-device-class ssd osd.5

ceph osd crush rm-device-class osd.7 && ceph osd crush set-device-class ssd osd.7
ceph osd crush rm-device-class osd.8 && ceph osd crush set-device-class ssd osd.8

ceph osd crush rm-device-class osd.10 && ceph osd crush set-device-class ssd osd.10
ceph osd crush rm-device-class osd.11 && ceph osd crush set-device-class ssd osd.11

ceph osd crush add-bucket ssd-node140 host
ceph osd crush add-bucket ssd-node141 host
ceph osd crush add-bucket ssd-node142 host
ceph osd crush add-bucket ssd-node143 host

ceph osd crush move ssd-node140 root=zone-26
ceph osd crush move ssd-node141 root=zone-26
ceph osd crush move ssd-node142 root=zone-26
ceph osd crush move ssd-node143 root=zone-26


ceph osd crush move osd.1 root=zone-26 host=ssd-node140
ceph osd crush move osd.2 root=zone-26 host=ssd-node140

ceph osd crush move osd.4 root=zone-26 host=ssd-node141
ceph osd crush move osd.5 root=zone-26 host=ssd-node141

ceph osd crush move osd.7 root=zone-26 host=ssd-node142
ceph osd crush move osd.8 root=zone-26 host=ssd-node142

ceph osd crush move osd.10 root=zone-26 host=ssd-node143
ceph osd crush move osd.11 root=zone-26 host=ssd-node143


ceph osd crush rule create-replicated Zone_26_SSD zone-26 host ssd
ceph osd crush rule dump Zone_26_SSD

ceph orch device ls
ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill

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

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_26_SSD

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

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_26_SSD

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

ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_26_SSD

ceph osd tree
ceph pg dump osds

ceph osd unset norebalance
ceph osd unset nobackfill


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
OSD_STAT  USED     AVAIL    USED_RAW  TOTAL    HB_PEERS                                                  PG_SUM  PRIMARY_PG_SUM
23         73 MiB   30 GiB    73 MiB   30 GiB                        [0,3,5,6,8,9,14,16,17,19,20,21,22]      19               6
22        2.2 GiB   28 GiB   2.2 GiB   30 GiB        [0,1,3,4,5,7,8,9,10,11,12,13,15,17,18,19,20,21,23]      34               5
21        1.7 GiB   28 GiB   1.7 GiB   30 GiB         [0,1,2,3,4,5,6,8,9,11,14,15,16,17,18,19,20,22,23]      32               6
20         73 MiB   30 GiB    73 MiB   30 GiB                [0,1,3,4,6,7,9,12,14,15,17,18,19,21,22,23]      24              10
19        659 MiB   29 GiB   659 MiB   30 GiB           [0,1,2,4,5,7,8,9,11,12,13,14,15,18,20,21,22,23]      25               6
18        627 MiB   29 GiB   627 MiB   30 GiB            [0,1,2,3,4,5,6,7,8,10,11,12,15,17,19,20,21,23]      31              11
17         73 MiB   30 GiB    73 MiB   30 GiB                     [0,3,5,6,8,9,13,14,15,16,18,20,22,23]      23               5
16        938 MiB   29 GiB   938 MiB   30 GiB      [0,1,2,3,4,5,7,8,9,10,11,12,13,15,17,18,19,20,21,22]      30              10
5         1.4 GiB   29 GiB   1.4 GiB   30 GiB     [0,1,2,3,4,6,7,8,10,11,12,13,14,15,16,18,19,20,21,22]      28              14
4         1.3 GiB   29 GiB   1.3 GiB   30 GiB        [0,1,2,3,5,6,7,9,10,11,13,14,15,16,18,19,20,21,22]      36              14
3          74 MiB   30 GiB    74 MiB   30 GiB                    [0,1,2,4,6,7,8,9,11,13,16,17,19,20,23]      23               5
2         1.5 GiB   29 GiB   1.5 GiB   30 GiB     [1,3,4,5,6,7,8,9,10,11,12,13,14,15,18,19,20,21,22,23]      34              13
0          73 MiB   30 GiB    73 MiB   30 GiB                       [1,3,4,6,9,10,12,14,15,17,18,20,23]      24               6
1         1.0 GiB   29 GiB   1.0 GiB   30 GiB    [0,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,21,22]      37              14
6          74 MiB   30 GiB    74 MiB   30 GiB                      [0,1,3,4,5,7,8,10,12,14,17,20,21,23]      23               6
7         2.1 GiB   28 GiB   2.1 GiB   30 GiB  [0,1,2,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23]      32              13
8         1.1 GiB   29 GiB   1.1 GiB   30 GiB     [0,1,2,3,4,5,7,9,10,12,13,14,15,16,17,18,19,20,21,22]      26               9
9          74 MiB   30 GiB    74 MiB   30 GiB                    [0,2,3,6,8,10,11,14,16,17,19,20,22,23]      27              10
10        1.8 GiB   28 GiB   1.8 GiB   30 GiB            [1,2,3,4,5,6,7,8,9,11,12,15,16,18,19,20,21,22]      30              11
11        1.7 GiB   28 GiB   1.7 GiB   30 GiB           [0,1,2,3,4,5,8,9,10,12,13,15,16,17,18,19,22,23]      29              11
12        1.0 GiB   29 GiB   1.0 GiB   30 GiB         [0,2,4,6,8,9,10,11,13,14,16,17,18,19,20,21,22,23]      29              10
13        878 MiB   29 GiB   878 MiB   30 GiB       [1,2,3,4,7,8,9,10,11,12,14,16,17,18,19,20,21,22,23]      22               8
14         73 MiB   30 GiB    73 MiB   30 GiB                       [0,3,6,7,9,10,12,13,15,17,18,20,23]      32              17
15        1.2 GiB   29 GiB   1.2 GiB   30 GiB       [0,1,2,5,7,8,9,10,11,12,13,14,16,17,18,19,20,22,23]      25               5
sum        22 GiB  698 GiB    22 GiB  720 GiB
dumped osds
root@node140:~# rados df
POOL_NAME                      USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS       RD  WR_OPS       WR  USED COMPR  UNDER COMPR
.mgr                        4.0 MiB        2       0       6                   0        0         0     136  118 KiB     203  3.4 MiB         0 B          0 B
.rgw.root                   192 KiB       17       0      51                   0        0         0      89  100 KiB       0      0 B         0 B          0 B
us-east.rgw.buckets.data     21 GiB     1738       0    5214                   0        0         0       0      0 B    4731  6.2 GiB         0 B          0 B
us-east.rgw.buckets.index       0 B       11       0      33                   0        0         0    4296  3.3 MiB    1869  945 KiB         0 B          0 B
us-east.rgw.buckets.non-ec      0 B        0       0       0                   0        0         0    2658  1.9 MiB     651  441 KiB         0 B          0 B
us-east.rgw.control             0 B        8       0      24                   0        0         0       0      0 B       0      0 B         0 B          0 B
us-east.rgw.log             432 KiB      179       0     537                   0        0         0    3244  2.9 MiB    1981   35 KiB         0 B          0 B
us-east.rgw.meta            116 KiB       10       0      30                   0        0         0      41   34 KiB      24   11 KiB         0 B          0 B

total_objects    1965
total_used       22 GiB
total_avail      698 GiB
total_space      720 GiB



root@node140:~# ceph osd tree
ID   CLASS  WEIGHT   TYPE NAME             STATUS  REWEIGHT  PRI-AFF
-28         0.46875  root zone-26
-31         0.05859      host ssd-node130
 12    ssd  0.02930          osd.12            up   1.00000  1.00000
 13    ssd  0.02930          osd.13            up   1.00000  1.00000
-32         0.05859      host ssd-node131
 15    ssd  0.02930          osd.15            up   1.00000  1.00000
 16    ssd  0.02930          osd.16            up   1.00000  1.00000
-33         0.05859      host ssd-node132
 18    ssd  0.02930          osd.18            up   1.00000  1.00000
 19    ssd  0.02930          osd.19            up   1.00000  1.00000
-34         0.05859      host ssd-node133
 21    ssd  0.02930          osd.21            up   1.00000  1.00000
 22    ssd  0.02930          osd.22            up   1.00000  1.00000
-43         0.05859      host ssd-node140
  1    ssd  0.02930          osd.1             up   1.00000  1.00000
  2    ssd  0.02930          osd.2             up   1.00000  1.00000
-44         0.05859      host ssd-node141
  4    ssd  0.02930          osd.4             up   1.00000  1.00000
  5    ssd  0.02930          osd.5             up   1.00000  1.00000
-45         0.05859      host ssd-node142
  7    ssd  0.02930          osd.7             up   1.00000  1.00000
  8    ssd  0.02930          osd.8             up   1.00000  1.00000
-46         0.05859      host ssd-node143
 10    ssd  0.02930          osd.10            up   1.00000  1.00000
 11    ssd  0.02930          osd.11            up   1.00000  1.00000
 -1         0.23438  root default
-11         0.02930      host node130
 14    hdd  0.02930          osd.14            up   1.00000  1.00000
-13         0.02930      host node131
 17    hdd  0.02930          osd.17            up   1.00000  1.00000
-15         0.02930      host node132
 20    hdd  0.02930          osd.20            up   1.00000  1.00000
-17         0.02930      host node133
 23    hdd  0.02930          osd.23            up   1.00000  1.00000
 -3         0.02930      host node140
  0    hdd  0.02930          osd.0             up   1.00000  1.00000
 -5         0.02930      host node141
  3    ssd  0.02930          osd.3             up   1.00000  1.00000
 -7         0.02930      host node142
  6    hdd  0.02930          osd.6             up   1.00000  1.00000
 -9         0.02930      host node143
  9    hdd  0.02930          osd.9             up   1.00000  1.00000

root@node140:~# ceph orch device ls
HOST     PATH      TYPE  DEVICE ID                         SIZE  AVAILABLE  REFRESHED  REJECT REASONS
node130  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         8m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node130  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         8m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node130  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         8m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         7m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         7m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node131  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         7m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         6m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         6m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node132  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         6m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         4m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         4m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node133  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         4m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node140  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         12m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node140  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         12m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node140  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         12m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         11m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         11m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node141  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         11m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         10m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         10m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node142  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         10m ago    Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         9m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         9m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
node143  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         9m ago     Has a FileSystem, Insufficient space (<10 extents) on vgs, LVM detected
root@node140:~# ceph -s
  cluster:
    id:     8d88d9c6-e79e-11ee-a1d5-f9480453e0e8
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 43m)
    mgr: node140.chtkuc(active, since 46m), standbys: node141.nbymwo, node142.rgmuju
    osd: 24 osds: 24 up (since 35m), 24 in (since 35m)
    rgw: 3 daemons active (3 hosts, 1 zones)

  data:
    pools:   8 pools, 225 pgs
    objects: 1.97k objects, 6.6 GiB
    usage:   22 GiB used, 698 GiB / 720 GiB avail
    pgs:     225 active+clean

```
