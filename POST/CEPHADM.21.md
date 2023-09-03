
# STEP ZERO
```
## docker run -it --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash

docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04 bash

docker run -it --rm --hostname ceph-install --name ceph-install -v /var/run/docker.sock:/var/run/docker.sock harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04 bash


```
# STEP 0
```

apt install openssh-server -y
ssh-keygen
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa  -q -P ""

echo "192.168.200.140 node140" >>/etc/hosts
echo "192.168.200.141 node141" >>/etc/hosts
echo "192.168.200.142 node142" >>/etc/hosts


ssh-copy-id root@node140
ssh-copy-id root@node141
ssh-copy-id root@node142


for i in {0..2}
do
ssh root@192.168.200.14${i} 'echo "192.168.200.140 node140" >> /etc/hosts'
ssh root@192.168.200.14${i} 'echo "192.168.200.141 node141" >> /etc/hosts'
ssh root@192.168.200.14${i} 'echo "192.168.200.142 node142" >> /etc/hosts'
done


for i in {0..2}
do
ssh root@192.168.200.14${i} 'cat /etc/hosts'
done


for i in {0..2}
do
ssh root@192.168.200.14${i} "apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release && apt update"
ssh root@192.168.200.14${i} "apt-get -y install docker.io containerd"
ssh root@192.168.200.14${i} "apt install -y ntpdate && ntpdate -u pool.ntp.org"
ssh root@192.168.200.14${i} "sed -i '/#NTP=/a NTP=time.google.com' /etc/systemd/timesyncd.conf"
ssh root@192.168.200.14${i} "systemctl restart systemd-timesyncd  && timedatectl"
done

for i in {0..2}
do
ssh root@192.168.200.14${i} "apt list --installed |grep ^lvm"
done

# STEP 1

ssh root@192.168.200.140 "curl --silent --remote-name --location https://raw.githubusercontent.com/ceph/ceph/reef/src/cephadm/cephadm.py"
ssh root@192.168.200.140 "chmod +x cephadm.py"
ssh root@192.168.200.140 "mv cephadm.py /usr/bin/cephadm"
ssh root@192.168.200.140 "cephadm add-repo --release reef"
ssh root@192.168.200.140 "apt update"


ssh root@192.168.200.140 "cephadm install"
ssh root@192.168.200.140 "mkdir -p /etc/ceph"
ssh root@192.168.200.140 "cephadm bootstrap --mon-ip 192.168.200.140"

....
Creating initial admin user...
Fetching dashboard port number...
Ceph Dashboard is now available at:


             URL: https://node140.cloud.local:8443/
            User: admin
        Password: wrt02o2zvj

Enabling client.admin keyring and conf on hosts with "admin" label
Saving cluster configuration to /var/lib/ceph/025b1176-4379-11ee-8726-5da9d31147f4/config directory

Enabling autotune for osd_memory_target
You can access the Ceph CLI as following in case of multi-cluster or non-default config:

        sudo /usr/sbin/cephadm shell --fsid 2443d22e-4184-11ee-aedb-cfe589610f02 -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring

Or, if you are only running a single cluster on this host:

        sudo /usr/sbin/cephadm shell

Please consider enabling telemetry to help improve Ceph:

        ceph telemetry on

For more information see:

        https://docs.ceph.com/en/latest/mgr/telemetry/


....
```



```
https://docs.ceph.com/en/octopus/man/8/cephadm/

ssh root@192.168.200.140 "cephadm list-networks"

ssh root@192.168.200.140 "cephadm shell -- ceph -s"
ssh root@192.168.200.140 "cephadm install ceph-common"

ssh root@192.168.200.140 "cephadm pull"
ssh root@192.168.200.140 "cephadm ls"

ssh root@192.168.200.140 "ceph config get mon"
ssh root@192.168.200.140 "ceph config get mgr"


ssh root@192.168.200.140 "ceph config set mon public_network 192.168.200.0/24"
ssh root@192.168.200.140 "ceph config set global cluster_network 192.168.201.0/24"

ssh root@192.168.200.140 "ceph config get mon"
ssh root@192.168.200.140 "ceph config get mgr"

............
root@node140:~# ceph config get mon
WHO     MASK  LEVEL     OPTION                                 VALUE                                                                                      RO
mon           advanced  auth_allow_insecure_global_id_reclaim  false
global        advanced  cluster_network                        192.168.201.0/24                                                                           *
global        basic     container_image                        quay.io/ceph/ceph@sha256:bffa28055a8df508962148236bcc391ff3bbf271312b2e383c6aa086c086c82c  *
mon           advanced  public_network                         192.168.200.0/24                                                                           *
root@node140:~# ceph config get mgr
WHO     MASK  LEVEL     OPTION                                VALUE                                                                                      RO
global        advanced  cluster_network                       192.168.201.0/24                                                                           *
global        basic     container_image                       quay.io/ceph/ceph@sha256:bffa28055a8df508962148236bcc391ff3bbf271312b2e383c6aa086c086c82c  *
mgr           advanced  mgr/cephadm/container_init            True                                                                                       *
mgr           advanced  mgr/cephadm/migration_current         6                                                                                          *
mgr           advanced  mgr/dashboard/ALERTMANAGER_API_HOST   http://node140:9093                                                                        *
mgr           advanced  mgr/dashboard/GRAFANA_API_SSL_VERIFY  false                                                                                      *
mgr           advanced  mgr/dashboard/GRAFANA_API_URL         https://node140:3000                                                                       *
mgr           advanced  mgr/dashboard/ssl_server_port         8443                                                                                       *
mgr           advanced  mgr/orchestrator/orchestrator         cephadm
............



ssh root@192.168.200.140 "ceph mgr module enable prometheus"
ssh root@192.168.200.140 "ceph mgr module enable dashboard"

ssh root@192.168.200.140 "ceph mgr module enable balancer"
ssh root@192.168.200.140 "ceph balancer mode upmap"
ssh root@192.168.200.140 "ceph balancer on"



ssh root@192.168.200.140 "cephadm shell -- ceph -s"
sleep 240
ssh root@192.168.200.140 "ceph orch ps"


# on node140
ssh root@192.168.200.140

ssh-copy-id -f -i /etc/ceph/ceph.pub root@node140
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node141
ssh-copy-id -f -i /etc/ceph/ceph.pub root@node142


# ceph orch host add node141 node142

ssh root@192.168.200.140 "ceph orch host add node141"
ssh root@192.168.200.140 "ceph orch host add node142"

ssh root@192.168.200.140 "ceph orch host ls"

ssh root@192.168.200.140 "ceph orch apply mon node140,node141,node142"




ssh root@192.168.200.140 "cephadm shell -- ceph -s"
sleep 240
ssh root@192.168.200.140 "ceph orch ps"

ssh root@192.168.200.140 "ceph orch apply mon node140,node141,node142"
ssh root@192.168.200.140 "ceph orch device ls"
sleep 240
ssh root@192.168.200.140 "cephadm shell -- ceph -s"
ssh root@192.168.200.140 "ceph orch device ls"

............
root@ceph-install:/# ssh root@192.168.200.140 "cephadm shell -- ceph -s"
Inferring fsid 2443d22e-4184-11ee-aedb-cfe589610f02
Inferring config /var/lib/ceph/2443d22e-4184-11ee-aedb-cfe589610f02/mon.node140/config
Using ceph image with id '14060fbd7be7' and tag 'v18' created on 2023-08-04 04:44:28 +0500 +05
quay.io/ceph/ceph@sha256:bffa28055a8df508962148236bcc391ff3bbf271312b2e383c6aa086c086c82c
  cluster:
    id:     2443d22e-4184-11ee-aedb-cfe589610f02
    health: HEALTH_WARN
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 4m)
    mgr: node140.lqnacf(active, since 12m), standbys: node141.mhhbqm
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:

root@ceph-install:/# ssh root@192.168.200.140 "ceph orch device ls"
HOST     PATH      TYPE  DEVICE ID                         SIZE  AVAILABLE  REFRESHED  REJECT REASONS
node140  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  Yes        14m ago
node140  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        14m ago
node140  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        14m ago
node141  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  Yes        6m ago
node141  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        6m ago
node141  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        6m ago
node142  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  Yes        5m ago
node142  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        5m ago
node142  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        5m ago
............

# STEP 3
# node140

ssh root@192.168.200.140 "cephadm shell -- ceph -s"

ssh root@192.168.200.140 "ceph orch daemon add osd node140:/dev/sdb" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch daemon add osd node141:/dev/sdb" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch daemon add osd node142:/dev/sdb" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch device ls"

ssh root@192.168.200.140 "ceph orch daemon add osd node140:/dev/sdc" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch daemon add osd node141:/dev/sdc" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch daemon add osd node142:/dev/sdc" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch device ls"

ssh root@192.168.200.140 "ceph orch daemon add osd node140:/dev/sdd" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch daemon add osd node141:/dev/sdd" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch daemon add osd node142:/dev/sdd" && \
sleep 30 && \
ssh root@192.168.200.140 "ceph orch device ls"


ssh root@192.168.200.140 "ceph orch ls osd --export"
ssh root@192.168.200.140 "ceph orch ls osd"
ssh root@192.168.200.140 "ceph orch device ls"
ssh root@192.168.200.140 "ceph osd tree"
ssh root@192.168.200.140 "cephadm ceph-volume lvm list"
ssh root@192.168.200.140 "cephadm ceph-volume lvm list --format json"



ssh root@192.168.200.140 "ceph dashboard ac-user-show"
["admin"]


# STEP 4
ssh root@192.168.200.140 "ceph orch device ls"
ssh root@192.168.200.140 "cephadm shell -- ceph -s"
ssh root@192.168.200.140 "ceph orch apply mgr node140,node141,node142"
ssh root@192.168.200.140 "cephadm shell -- ceph -s"
ssh root@192.168.200.140 "ceph osd df tree"
ssh root@192.168.200.140 "ceph orch status"



..................
root@ceph-install:/# ssh root@192.168.200.140 "cephadm shell -- ceph -s"
Inferring fsid 2443d22e-4184-11ee-aedb-cfe589610f02
Inferring config /var/lib/ceph/2443d22e-4184-11ee-aedb-cfe589610f02/mon.node140/config
Using ceph image with id '14060fbd7be7' and tag 'v18' created on 2023-08-04 04:44:28 +0500 +05
quay.io/ceph/ceph@sha256:bffa28055a8df508962148236bcc391ff3bbf271312b2e383c6aa086c086c82c
  cluster:
    id:     2443d22e-4184-11ee-aedb-cfe589610f02
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 20m)
    mgr: node140.lqnacf(active, since 28m), standbys: node141.mhhbqm, node142.qnjuiq
    osd: 9 osds: 9 up (since 3m), 9 in (since 4m)

  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 577 KiB
    usage:   242 MiB used, 270 GiB / 270 GiB avail
    pgs:     1 active+clean

root@ceph-install:/# ssh root@192.168.200.140 "ceph osd df tree"
ID  CLASS  WEIGHT   REWEIGHT  SIZE     RAW USE  DATA     OMAP  META     AVAIL    %USE  VAR   PGS  STATUS  TYPE NAME
-1         0.26367         -  270 GiB  242 MiB  7.1 MiB   0 B  235 MiB  270 GiB  0.09  1.00    -          root default
-3         0.08789         -   90 GiB   81 MiB  2.4 MiB   0 B   78 MiB   90 GiB  0.09  1.00    -              host node140
 0    hdd  0.02930   1.00000   30 GiB   27 MiB  620 KiB   0 B   26 MiB   30 GiB  0.09  0.99    0      up          osd.0
 3    hdd  0.02930   1.00000   30 GiB   27 MiB  1.2 MiB   0 B   26 MiB   30 GiB  0.09  1.01    1      up          osd.3
 6    hdd  0.02930   1.00000   30 GiB   27 MiB  620 KiB   0 B   26 MiB   30 GiB  0.09  0.99    0      up          osd.6
-5         0.08789         -   90 GiB   81 MiB  2.4 MiB   0 B   78 MiB   90 GiB  0.09  1.00    -              host node141
 1    hdd  0.02930   1.00000   30 GiB   27 MiB  620 KiB   0 B   26 MiB   30 GiB  0.09  0.99    0      up          osd.1
 4    hdd  0.02930   1.00000   30 GiB   27 MiB  620 KiB   0 B   26 MiB   30 GiB  0.09  0.99    0      up          osd.4
 7    hdd  0.02930   1.00000   30 GiB   27 MiB  1.2 MiB   0 B   26 MiB   30 GiB  0.09  1.01    1      up          osd.7
-7         0.08789         -   90 GiB   81 MiB  2.4 MiB   0 B   78 MiB   90 GiB  0.09  1.00    -              host node142
 2    hdd  0.02930   1.00000   30 GiB   27 MiB  620 KiB   0 B   26 MiB   30 GiB  0.09  0.99    0      up          osd.2
 5    hdd  0.02930   1.00000   30 GiB   27 MiB  1.2 MiB   0 B   26 MiB   30 GiB  0.09  1.01    1      up          osd.5
 8    hdd  0.02930   1.00000   30 GiB   27 MiB  620 KiB   0 B   26 MiB   30 GiB  0.09  0.99    0      up          osd.8
                       TOTAL  270 GiB  242 MiB  7.1 MiB   0 B  235 MiB  270 GiB  0.09
MIN/MAX VAR: 0.99/1.01  STDDEV: 0

................





ssh root@192.168.200.140 "ceph orch device ls --wide"

......................
root@ceph-install:/# ssh root@192.168.200.140 "ceph orch device ls --wide"
HOST     PATH      TYPE  TRANSPORT  RPM  DEVICE ID                         SIZE  HEALTH  IDENT  FAULT  AVAILABLE  REFRESHED  REJECT REASONS
node140  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         5m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         5m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         5m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         4m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         4m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         4m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked

root@ceph-install:/# ssh root@192.168.200.140 "ceph orch device ls node140 --wide"
HOST     PATH      TYPE  TRANSPORT  RPM  DEVICE ID                         SIZE  HEALTH  IDENT  FAULT  AVAILABLE  REFRESHED  REJECT REASONS
node140  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
......................

ssh root@192.168.200.140 "ceph orch ps"


........................
root@ceph-install:/# ssh root@192.168.200.140 "ceph orch ps"
NAME                   HOST     PORTS             STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID
alertmanager.node140   node140  *:9093,9094       running (2m)      2m ago  30m    14.5M        -  0.25.0   c8568f914cd2  1f03de8827c0
ceph-exporter.node140  node140                    running (30m)     2m ago  30m    8248k        -  18.2.0   14060fbd7be7  e3141f36eb73
ceph-exporter.node141  node141                    running (23m)     6m ago  23m    7824k        -  18.2.0   14060fbd7be7  eab65c51c2a9
ceph-exporter.node142  node142                    running (22m)     2m ago  22m    8299k        -  18.2.0   14060fbd7be7  dcc4851b7ded
crash.node140          node140                    running (30m)     2m ago  30m    7107k        -  18.2.0   14060fbd7be7  d2d8d00cd78a
crash.node141          node141                    running (23m)     6m ago  23m    7111k        -  18.2.0   14060fbd7be7  557f3fc98e97
crash.node142          node142                    running (22m)     2m ago  22m    7104k        -  18.2.0   14060fbd7be7  5ed0249e2f62
grafana.node140        node140  *:3000            running (29m)     2m ago  29m    74.2M        -  9.4.7    2c41d148cca3  0ce1f6d581a3
mgr.node140.lqnacf     node140  *:9283,8765,8443  running (31m)     2m ago  31m     496M        -  18.2.0   14060fbd7be7  6bf64e65abeb
mgr.node141.mhhbqm     node141  *:8443,9283,8765  running (23m)     6m ago  23m     426M        -  18.2.0   14060fbd7be7  e3645971afa8
mgr.node142.qnjuiq     node142  *:8443,9283,8765  running (2m)      2m ago   2m     203M        -  18.2.0   14060fbd7be7  e9989d1b4220
mon.node140            node140                    running (31m)     2m ago  31m    50.4M    2048M  18.2.0   14060fbd7be7  3caf6e448acc
mon.node141            node141                    running (22m)     6m ago  22m    37.2M    2048M  18.2.0   14060fbd7be7  c6c6188fb921
mon.node142            node142                    running (22m)     2m ago  22m    38.9M    2048M  18.2.0   14060fbd7be7  2ba70b950921
node-exporter.node140  node140  *:9100            running (30m)     2m ago  30m    8427k        -  1.5.0    0da6a335fe13  91de73b23524
node-exporter.node141  node141  *:9100            running (23m)     6m ago  23m    8603k        -  1.5.0    0da6a335fe13  5d253f6ce76e
node-exporter.node142  node142  *:9100            running (21m)     2m ago  22m    8303k        -  1.5.0    0da6a335fe13  931be7dc63c1
osd.0                  node140                    running (14m)     2m ago  14m    61.9M    4096M  18.2.0   14060fbd7be7  7086c722a454
osd.1                  node141                    running (13m)     6m ago  13m    58.0M    4096M  18.2.0   14060fbd7be7  0474d7074bd0
osd.2                  node142                    running (12m)     2m ago  12m    59.4M    1178M  18.2.0   14060fbd7be7  7f298c4bc57f
osd.3                  node140                    running (11m)     2m ago  11m    55.9M    4096M  18.2.0   14060fbd7be7  12fd5c78ed7d
osd.4                  node141                    running (10m)     6m ago  10m    51.0M    4096M  18.2.0   14060fbd7be7  e19847fd9192
osd.5                  node142                    running (9m)      2m ago   9m    55.1M    1178M  18.2.0   14060fbd7be7  212452e75aef
osd.6                  node140                    running (7m)      2m ago   7m    53.7M    4096M  18.2.0   14060fbd7be7  2f342e207f13
osd.7                  node141                    running (6m)      6m ago   6m    11.7M    4096M  18.2.0   14060fbd7be7  069eeeec56bf
osd.8                  node142                    running (5m)      2m ago   5m    55.5M    1178M  18.2.0   14060fbd7be7  0e4e673b04ec
prometheus.node140     node140  *:9095            running (21m)     2m ago  29m    68.0M        -  2.43.0   a07b618ecd1d  d2f9a9304562
........................




ssh root@192.168.200.140 "ceph mon dump"
...........................
root@ceph-install:/# ssh root@192.168.200.140 "ceph mon dump"
epoch 3
fsid 2443d22e-4184-11ee-aedb-cfe589610f02
last_changed 2023-08-23T07:20:47.430265+0000
created 2023-08-23T07:11:22.519248+0000
min_mon_release 18 (reef)
election_strategy: 1
0: [v2:192.168.200.140:3300/0,v1:192.168.200.140:6789/0] mon.node140
1: [v2:192.168.200.142:3300/0,v1:192.168.200.142:6789/0] mon.node142
2: [v2:192.168.200.141:3300/0,v1:192.168.200.141:6789/0] mon.node141
dumped monmap epoch 3
...........................




# STEP 5

ssh root@192.168.200.140 "ceph telemetry on --license sharing-1-0"

ssh root@192.168.200.140 'ceph orch host label add node140 rgw'
ssh root@192.168.200.140 'ceph orch host label add node141 rgw'
ssh root@192.168.200.140 'ceph orch host label add node142 rgw'



...........................
root@ceph-install:/# ssh root@192.168.200.140 "ceph orch ps"
NAME                   HOST     PORTS             STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID
alertmanager.node140   node140  *:9093,9094       running (3m)      3m ago  32m    14.5M        -  0.25.0   c8568f914cd2  1f03de8827c0
ceph-exporter.node140  node140                    running (32m)     3m ago  32m    8248k        -  18.2.0   14060fbd7be7  e3141f36eb73
ceph-exporter.node141  node141                    running (24m)     7m ago  24m    7824k        -  18.2.0   14060fbd7be7  eab65c51c2a9
ceph-exporter.node142  node142                    running (23m)     3m ago  23m    8299k        -  18.2.0   14060fbd7be7  dcc4851b7ded
crash.node140          node140                    running (32m)     3m ago  32m    7107k        -  18.2.0   14060fbd7be7  d2d8d00cd78a
crash.node141          node141                    running (24m)     7m ago  24m    7111k        -  18.2.0   14060fbd7be7  557f3fc98e97
crash.node142          node142                    running (23m)     3m ago  23m    7104k        -  18.2.0   14060fbd7be7  5ed0249e2f62
grafana.node140        node140  *:3000            running (31m)     3m ago  31m    74.2M        -  9.4.7    2c41d148cca3  0ce1f6d581a3
mgr.node140.lqnacf     node140  *:9283,8765,8443  running (33m)     3m ago  33m     496M        -  18.2.0   14060fbd7be7  6bf64e65abeb
mgr.node141.mhhbqm     node141  *:8443,9283,8765  running (24m)     7m ago  24m     426M        -  18.2.0   14060fbd7be7  e3645971afa8
mgr.node142.qnjuiq     node142  *:8443,9283,8765  running (4m)      3m ago   4m     203M        -  18.2.0   14060fbd7be7  e9989d1b4220
mon.node140            node140                    running (33m)     3m ago  33m    50.4M    2048M  18.2.0   14060fbd7be7  3caf6e448acc
mon.node141            node141                    running (23m)     7m ago  23m    37.2M    2048M  18.2.0   14060fbd7be7  c6c6188fb921
mon.node142            node142                    running (23m)     3m ago  23m    38.9M    2048M  18.2.0   14060fbd7be7  2ba70b950921
node-exporter.node140  node140  *:9100            running (32m)     3m ago  32m    8427k        -  1.5.0    0da6a335fe13  91de73b23524
node-exporter.node141  node141  *:9100            running (24m)     7m ago  24m    8603k        -  1.5.0    0da6a335fe13  5d253f6ce76e
node-exporter.node142  node142  *:9100            running (23m)     3m ago  23m    8303k        -  1.5.0    0da6a335fe13  931be7dc63c1
osd.0                  node140                    running (15m)     3m ago  15m    61.9M    4096M  18.2.0   14060fbd7be7  7086c722a454
osd.1                  node141                    running (15m)     7m ago  15m    58.0M    4096M  18.2.0   14060fbd7be7  0474d7074bd0
osd.2                  node142                    running (14m)     3m ago  14m    59.4M    1178M  18.2.0   14060fbd7be7  7f298c4bc57f
osd.3                  node140                    running (13m)     3m ago  13m    55.9M    4096M  18.2.0   14060fbd7be7  12fd5c78ed7d
osd.4                  node141                    running (12m)     7m ago  12m    51.0M    4096M  18.2.0   14060fbd7be7  e19847fd9192
osd.5                  node142                    running (11m)     3m ago  11m    55.1M    1178M  18.2.0   14060fbd7be7  212452e75aef
osd.6                  node140                    running (8m)      3m ago   8m    53.7M    4096M  18.2.0   14060fbd7be7  2f342e207f13
osd.7                  node141                    running (8m)      7m ago   8m    11.7M    4096M  18.2.0   14060fbd7be7  069eeeec56bf
osd.8                  node142                    running (7m)      3m ago   7m    55.5M    1178M  18.2.0   14060fbd7be7  0e4e673b04ec
prometheus.node140     node140  *:9095            running (23m)     3m ago  31m    68.0M        -  2.43.0   a07b618ecd1d  d2f9a9304562
...........................

# так мы узнаем clusterID
ssh root@192.168.200.140 "ceph fsid"

```shell
root@ceph-install:/# ssh root@192.168.200.140 "ceph fsid"
025b1176-4379-11ee-8726-5da9d31147f4
```



