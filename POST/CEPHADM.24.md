# STEP ZERO
```
## docker run -it --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash

docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04 bash

docker run -it --rm --hostname ceph-install --name ceph-install -v /var/run/docker.sock:/var/run/docker.sock harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04 bash


```
# STEP 0
```

apt install openssh-server sshpass pdsh -y && \
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa  -q -P ""

cat <<EOF>/etc/ssh/ssh_config
Host node*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

cat <<EOF>>/etc/hosts
192.168.200.140 node140
192.168.200.141 node141
192.168.200.142 node142
192.168.200.143 node143
192.168.200.144 node144
192.168.200.145 node145
EOF

cat <<EOF>hosts
node140
node141
node142
node143
node144
node145
EOF

declare -a arr=( 140 141 142 143 144 145 )
echo 'root' >pass_file
chmod 0400 pass_file
for i in "${arr[@]}"
do
sshpass -f pass_file ssh-copy-id root@node${i}
ssh root@node${i}  "df -h"
done

pdsh -w ^hosts -R ssh 'uptime'
pdsh -w ^hosts -R ssh 'echo "192.168.200.140 node140" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.141 node141" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.142 node142" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.143 node143" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.144 node144" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.145 node145" >> /etc/hosts'

pdsh -w ^hosts -R ssh 'cat /etc/hosts'
pdsh -w ^hosts -R ssh "apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release && apt update" && \
pdsh -w ^hosts -R ssh "apt-get -y install docker.io containerd" && \
pdsh -w ^hosts -R ssh "apt install -y ntpdate && ntpdate -u pool.ntp.org" && \
pdsh -w ^hosts -R ssh "sed -i '/#NTP=/a NTP=time.google.com' /etc/systemd/timesyncd.conf" && \
pdsh -w ^hosts -R ssh "systemctl restart systemd-timesyncd  && timedatectl" && \
pdsh -w ^hosts -R ssh "apt list --installed |grep ^lvm"

# STEP 1

### example
###
### export SSL_CERT_FILE=/etc/<PRIVATE-CERT>.crt
### cephadm add-repo --release  quincy --gpg-url https://<YOUR-MIRROR>x.y.z/<PRIVATE-CERT>/<download.ceph.com.release.gpg> --repo-url https://<YOUR-MIRROR>x.y.z/download.ceph.com/
### apt update
### 

cat <<EOF>host-master
node140
EOF

pdsh -w ^host-master -R ssh "curl --silent --remote-name --location https://raw.githubusercontent.com/ceph/ceph/reef/src/cephadm/cephadm.py"
pdsh -w ^host-master -R ssh "chmod +x cephadm.py"
pdsh -w ^host-master -R ssh "mv cephadm.py /usr/bin/cephadm"
pdsh -w ^host-master -R ssh "cephadm add-repo --release reef"
pdsh -w ^host-master -R ssh "apt update"



pdsh -w ^host-master -R ssh "cephadm install"
pdsh -w ^host-master -R ssh "mkdir -p /etc/ceph"


pdsh -w ^host-master -R ssh "cephadm --image nexus3-quay-io.iblog.pro/ceph/ceph:v18.2 bootstrap  --mon-ip 192.168.200.140"

### example
### cephadm --image x.y.z/ceph/ceph:v18.2 bootstrap  \
###  --registry-url x.y.z  --registry-json '{ "url": "z.y.z", "username": "<LOGIN>", "password": "<Password>" }'    --mon-ip <MON-IP>
###
### OR
###
### pdsh -w ^host-master -R ssh "cephadm bootstrap --mon-ip 192.168.200.140"
###

....
node140: Generating a dashboard self-signed certificate...
node140: Creating initial admin user...
node140: Fetching dashboard port number...
node140: Ceph Dashboard is now available at:
node140:
node140:             URL: https://node140.cloud.local:8443/
node140:            User: admin
node140:        Password: ld2ye5m8gr
node140:
node140: Enabling client.admin keyring and conf on hosts with "admin" label
node140: Saving cluster configuration to /var/lib/ceph/39771332-43e5-11ee-acdd-c9cea774700e/config directory
node140: Enabling autotune for osd_memory_target
node140: You can access the Ceph CLI as following in case of multi-cluster or non-default config:
node140:
node140:        sudo /usr/sbin/cephadm shell --fsid 39771332-43e5-11ee-acdd-c9cea774700e -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring
node140:
node140: Or, if you are only running a single cluster on this host:
node140:
node140:        sudo /usr/sbin/cephadm shell
node140:
node140: Please consider enabling telemetry to help improve Ceph:
node140:
node140:        ceph telemetry on
node140:
node140: For more information see:
node140:
node140:        https://docs.ceph.com/en/latest/mgr/telemetry/
node140:
node140: Bootstrap complete.
....
```



https://docs.ceph.com/en/octopus/man/8/cephadm/

```
pdsh -w ^host-master -R ssh "cephadm list-networks"

pdsh -w ^host-master -R ssh "cephadm shell -- ceph -s"
pdsh -w ^host-master -R ssh "cephadm install ceph-common"

pdsh -w ^host-master -R ssh "cephadm pull"
pdsh -w ^host-master -R ssh "cephadm ls"

pdsh -w ^host-master -R ssh "ceph config get mon"
pdsh -w ^host-master -R ssh "ceph config get mgr"


pdsh -w ^host-master -R ssh "ceph config set mon public_network 192.168.200.0/24"
pdsh -w ^host-master -R ssh "ceph config set global cluster_network 192.168.201.0/24"

pdsh -w ^host-master -R ssh "ceph config get mon"
pdsh -w ^host-master -R ssh "ceph config get mgr"

............

root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph config get mon"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: WHO     MASK  LEVEL     OPTION                                 VALUE                                                                                                       RO
node140: mon           advanced  auth_allow_insecure_global_id_reclaim  false
node140: global        advanced  cluster_network                        192.168.201.0/24                                                                                            *
node140: global        basic     container_image                        nexus3-quay-io.iblog.pro/ceph/ceph@sha256:5956967dd7ca651bd87db787fc3e32be74ea1ac3ee2237f872008e40e5a583d6  *
node140: mon           advanced  public_network                         192.168.200.0/24                                                                                            *

root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph config get mgr"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: WHO     MASK  LEVEL     OPTION                                VALUE                                                                                                       RO
node140: global        advanced  cluster_network                       192.168.201.0/24                                                                                            *
node140: global        basic     container_image                       nexus3-quay-io.iblog.pro/ceph/ceph@sha256:5956967dd7ca651bd87db787fc3e32be74ea1ac3ee2237f872008e40e5a583d6  *
node140: mgr           advanced  mgr/cephadm/container_init            True                                                                                                        *
node140: mgr           advanced  mgr/cephadm/migration_current         6                                                                                                           *
node140: mgr           advanced  mgr/dashboard/ALERTMANAGER_API_HOST   http://node140:9093                                                                                         *
node140: mgr           advanced  mgr/dashboard/GRAFANA_API_SSL_VERIFY  false                                                                                                       *
node140: mgr           advanced  mgr/dashboard/GRAFANA_API_URL         https://node140:3000                                                                                        *
node140: mgr           advanced  mgr/dashboard/ssl_server_port         8443                                                                                                        *
node140: mgr           advanced  mgr/orchestrator/orchestrator         cephadm

............



pdsh -w ^host-master -R ssh "ceph mgr module enable prometheus"
pdsh -w ^host-master -R ssh "ceph mgr module enable dashboard"

pdsh -w ^host-master -R ssh "ceph mgr module enable balancer"
pdsh -w ^host-master -R ssh "ceph balancer mode upmap"
pdsh -w ^host-master -R ssh "ceph balancer on"



pdsh -w ^host-master -R ssh "cephadm shell -- ceph -s"
sleep 240
pdsh -w ^host-master -R ssh "ceph orch ps"


# on node140

ssh root@192.168.200.140



cat <<EOF>/etc/ssh/ssh_config
Host node*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
apt install sshpass -y
declare -a arr=( 140 141 142 143 144 145 )
echo 'root' >pass_file
chmod 0400 pass_file
for i in "${arr[@]}"
do
sshpass -f pass_file ssh-copy-id -f -i /etc/ceph/ceph.pub root@node${i}
done

# ceph orch host add node141 node142

pdsh -w ^host-master -R ssh "ceph orch host add node141"
pdsh -w ^host-master -R ssh "ceph orch host add node142"

pdsh -w ^host-master -R ssh "ceph orch host ls"

pdsh -w ^host-master -R ssh "ceph orch apply mon node140,node141,node142"




pdsh -w ^host-master -R ssh "cephadm shell -- ceph -s"
sleep 240
pdsh -w ^host-master -R ssh "ceph orch ps"

pdsh -w ^host-master -R ssh "ceph orch apply mon node140,node141,node142"
pdsh -w ^host-master -R ssh "ceph orch device ls"
sleep 240
pdsh -w ^host-master -R ssh "cephadm shell -- ceph -s"
pdsh -w ^host-master -R ssh "ceph orch device ls"

............
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: Inferring fsid 39771332-43e5-11ee-acdd-c9cea774700e
node140: Inferring config /var/lib/ceph/39771332-43e5-11ee-acdd-c9cea774700e/mon.node140/config
node140: Using ceph image with id 'e0db6e7ec3f1' and tag 'v18.2' created on 2023-08-24 21:44:17 +0500 +05
node140: nexus3-quay-io.iblog.pro/ceph/ceph@sha256:5956967dd7ca651bd87db787fc3e32be74ea1ac3ee2237f872008e40e5a583d6
node140:   cluster:
node140:     id:     39771332-43e5-11ee-acdd-c9cea774700e
node140:     health: HEALTH_WARN
node140:             OSD count 0 < osd_pool_default_size 3
node140:
node140:   services:
node140:     mon: 3 daemons, quorum node140,node142,node141 (age 101s)
node140:     mgr: node140.zbnczp(active, since 11m), standbys: node141.ltbvun
node140:     osd: 0 osds: 0 up, 0 in
node140:
node140:   data:
node140:     pools:   0 pools, 0 pgs
node140:     objects: 0 objects, 0 B
node140:     usage:   0 B used, 0 B / 0 B avail
node140:     pgs:
node140:
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: HOST     PATH      TYPE  DEVICE ID                         SIZE  AVAILABLE  REFRESHED  REJECT REASONS
node140: node140  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  Yes        12m ago
node140: node140  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        12m ago
node140: node140  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        12m ago
node140: node141  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  Yes        2m ago
node140: node141  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        2m ago
node140: node141  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        2m ago
node140: node142  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  Yes        116s ago
node140: node142  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        116s ago
node140: node142  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        116s ago
............



pdsh -w ^host-master -R ssh "ceph orch host add node143"
pdsh -w ^host-master -R ssh "ceph orch host add node144"
pdsh -w ^host-master -R ssh "ceph orch host add node145"

pdsh -w ^host-master -R ssh "ceph orch host ls"
pdsh -w ^host-master -R ssh "ceph orch device ls"
pdsh -w ^host-master -R ssh "ceph orch ps"
pdsh -w ^host-master -R ssh "cephadm shell -- ceph -s"
```

```
root@node140:~# ceph orch device ls
HOST     PATH      TYPE  DEVICE ID                         SIZE  AVAILABLE  REFRESHED  REJECT REASONS
node140  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         5s ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         5s ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        5s ago
node141  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         13m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        13m ago
node141  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        13m ago
node142  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         12m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        12m ago
node142  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        12m ago
node143  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node143  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        6m ago
node143  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        6m ago
node144  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         5m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node144  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        5m ago
node144  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        5m ago
node145  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         2m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node145  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        2m ago
node145  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        2m ago
node145  /dev/sde  hdd   QEMU_HARDDISK_drive-scsi0-0-0-4  30.0G  Yes        2m ago
node145  /dev/sdf  hdd   QEMU_HARDDISK_drive-scsi0-0-0-5  30.0G  Yes        2m ago
node145  /dev/sdg  hdd   QEMU_HARDDISK_drive-scsi0-0-0-6  30.0G  Yes        2m ago
```

# STEP 3
# node140

```shell
pdsh -w ^host-master -R ssh "cephadm shell -- ceph -s"

pdsh -w ^host-master -R ssh "ceph orch daemon add osd node140:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node141:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node142:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node143:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node144:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node145:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch device ls"


pdsh -w ^host-master -R ssh "ceph orch daemon add osd node140:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node141:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node142:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node143:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node144:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node145:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch device ls"


pdsh -w ^host-master -R ssh "ceph orch daemon add osd node140:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node141:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node142:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node143:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node144:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node145:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch device ls"
```

```shell
root@node140:~# ceph orch device ls
HOST     PATH      TYPE  DEVICE ID                         SIZE  AVAILABLE  REFRESHED  REJECT REASONS
node140  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         9m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         9m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         9m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         9m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         9m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         9m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         8m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         8m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         8m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node143  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         7m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node143  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         7m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node143  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         7m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node144  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node144  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node144  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         6m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node145  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         5m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node145  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         5m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node145  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         5m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked

root@node140:~# ceph -s
  cluster:
    id:     39771332-43e5-11ee-acdd-c9cea774700e
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 47m)
    mgr: node140.zbnczp(active, since 56m), standbys: node141.ltbvun
    osd: 36 osds: 36 up (since 96s), 36 in (since 113s)

  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 577 KiB
    usage:   2.0 GiB used, 1.1 TiB / 1.1 TiB avail
    pgs:     1 active+clean

```

```shell
pdsh -w ^host-master -R ssh "ceph orch ls osd --export"
sleep 5
pdsh -w ^host-master -R ssh "ceph orch ls osd"
sleep 5
pdsh -w ^host-master -R ssh "ceph orch device ls"
sleep 5
pdsh -w ^host-master -R ssh "ceph osd tree"
sleep 5
pdsh -w ^host-master -R ssh "cephadm ceph-volume lvm list"
sleep 5
pdsh -w ^host-master -R ssh "cephadm ceph-volume lvm list --format json"
```

```shell
pdsh -w ^host-master -R ssh "ceph dashboard ac-user-show"
["admin"]
```

# STEP 4
```shell
pdsh -w ^host-master -R ssh "ceph orch device ls"
pdsh -w ^host-master -R ssh "cephadm shell -- ceph -s"
pdsh -w ^host-master -R ssh "ceph orch apply mgr node140,node141,node142"
pdsh -w ^host-master -R ssh "cephadm shell -- ceph -s"
pdsh -w ^host-master -R ssh "ceph osd df tree"
pdsh -w ^host-master -R ssh "ceph orch status"
pdsh -w ^host-master -R ssh "ceph orch device ls --wide"
pdsh -w ^host-master -R ssh "ceph orch ps"
pdsh -w ^host-master -R ssh "ceph mon dump"
```



### Testing ...........



```shell
ssh root@192.168.200.140 'ceph orch host label add node140 rgw'
ssh root@192.168.200.140 'ceph orch host label add node141 rgw'
ssh root@192.168.200.140 'ceph orch host label add node142 rgw'
```

```
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node172"
.....
```

```shell

for i in {0..17}
do
ceph osd crush rm-device-class osd.${i}
done

```

```
# node140
ceph osd crush set-device-class ssd osd.0
ceph osd crush set-device-class ssd osd.6
ceph osd crush set-device-class ssd osd.12
# node141
ceph osd crush set-device-class ssd osd.1
ceph osd crush set-device-class ssd osd.7
ceph osd crush set-device-class ssd osd.13
# node142
ceph osd crush set-device-class ssd osd.2
ceph osd crush set-device-class ssd osd.8
ceph osd crush set-device-class ssd osd.14
# node143
ceph osd crush set-device-class hdd osd.3
ceph osd crush set-device-class hdd osd.9
ceph osd crush set-device-class hdd osd.15
# node144
ceph osd crush set-device-class hdd osd.4
ceph osd crush set-device-class hdd osd.10
ceph osd crush set-device-class hdd osd.16
# node145
ceph osd crush set-device-class hdd osd.5
ceph osd crush set-device-class hdd osd.11
ceph osd crush set-device-class hdd osd.17

```

```shell
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph osd tree" | more
```

```shell
ceph osd crush add-bucket zone-node5 root
ceph osd crush move node140 root=zone-node5
ceph osd crush move node141 root=zone-node5
ceph osd crush move node142 root=zone-node5

```



```shell
ceph osd crush rule create-replicated Zone_Node5_SSD zone-node5 host ssd
ceph osd crush rule dump Zone_Node5_SSD
```
```
{
    "rule_id": 1,
    "rule_name": "Zone_Node5_SSD",
    "type": 1,
    "steps": [
        {
            "op": "take",
            "item": -23,
            "item_name": "zone-node5~ssd"
        },
        {
            "op": "chooseleaf_firstn",
            "num": 0,
            "type": "host"
        },
        {
            "op": "emit"
        }
    ]
}
```

```shell
ceph osd pool create kube_zone_node5_ssd 32
ceph osd pool application enable kube_zone_node5_ssd rbd
ceph osd pool set kube_zone_node5_ssd crush_rule Zone_Node5_SSD
```
```
pool 'kube_zone_node5_ssd' created
enabled application 'rbd' on pool 'kube_zone_node5_ssd'
set pool 2 crush_rule to Zone_Node5_SSD
```


```shell
root@node140:~# ceph device ls
DEVICE                           HOST:DEV                                                                 DAEMONS                                    WEAR  LIFE EXPECTANCY
QEMU_HARDDISK_drive-scsi0-0-0-0  node140:sda node141:sda node142:sda                                      mon.node140 mon.node141 mon.node142
QEMU_HARDDISK_drive-scsi0-0-0-1  node140:sdb node141:sdb node142:sdb node143:sdb node144:sdb node145:sdb  osd.0 osd.1 osd.2 osd.3 osd.4 osd.5
QEMU_HARDDISK_drive-scsi0-0-0-2  node140:sdc node141:sdc node142:sdc node143:sdc node144:sdc node145:sdc  osd.10 osd.11 osd.6 osd.7 osd.8 osd.9
QEMU_HARDDISK_drive-scsi0-0-0-3  node140:sdd node141:sdd node142:sdd node143:sdd node144:sdd node145:sdd  osd.12 osd.13 osd.14 osd.15 osd.16 osd.17

root@node140:~# ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
hdd    270 GiB  269 GiB  526 MiB   526 MiB       0.19
ssd    270 GiB  269 GiB  577 MiB   577 MiB       0.21
TOTAL  540 GiB  539 GiB  1.1 GiB   1.1 GiB       0.20

--- POOLS ---
POOL                 ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                  1    1  1.7 MiB        2  5.1 MiB      0     85 GiB
kube_zone_node5_ssd   2   32      0 B        0      0 B      0     85 GiB


root@node140:~# ceph pg dump osds
OSD_STAT  USED     AVAIL    USED_RAW  TOTAL    HB_PEERS                                PG_SUM  PRIMARY_PG_SUM
17         47 MiB   30 GiB    47 MiB   30 GiB             [0,2,3,9,10,12,13,14,15,16]       0               0
16         47 MiB   30 GiB    47 MiB   30 GiB                [3,4,5,6,7,8,9,11,15,17]       0               0
5          65 MiB   30 GiB    65 MiB   30 GiB             [4,6,8,9,10,12,13,14,15,16]       1               0
4          64 MiB   30 GiB    64 MiB   30 GiB                 [1,2,3,5,6,7,8,9,10,11]       0               0
3          64 MiB   30 GiB    64 MiB   30 GiB              [0,1,2,4,5,10,11,14,16,17]       0               0
2          64 MiB   30 GiB    64 MiB   30 GiB              [0,1,3,7,9,12,13,15,16,17]       7               1
0          64 MiB   30 GiB    64 MiB   30 GiB                [1,2,3,4,5,7,8,13,14,17]      13               4
1          64 MiB   30 GiB    64 MiB   30 GiB  [0,2,3,4,5,6,8,9,10,11,12,14,15,16,17]      13               6
6          64 MiB   30 GiB    64 MiB   30 GiB               [1,2,3,4,5,7,11,13,14,16]      13               6
7          64 MiB   30 GiB    64 MiB   30 GiB              [4,5,6,8,9,10,11,12,14,16]       6               3
8          64 MiB   30 GiB    64 MiB   30 GiB               [0,1,3,6,7,9,12,13,16,17]      13               4
9          65 MiB   30 GiB    65 MiB   30 GiB              [0,1,4,5,8,10,11,13,14,16]       1               1
10         65 MiB   30 GiB    65 MiB   30 GiB                [2,3,5,6,7,8,9,11,15,17]       1               0
11         64 MiB   30 GiB    64 MiB   30 GiB             [3,4,6,9,10,12,13,14,15,16]       0               0
12         64 MiB   30 GiB    64 MiB   30 GiB               [1,2,3,4,5,8,11,13,16,17]       6               1
13         64 MiB   30 GiB    64 MiB   30 GiB              [0,2,6,8,9,10,11,12,14,17]      13               4
14         64 MiB   30 GiB    64 MiB   30 GiB              [0,1,3,6,9,12,13,15,16,17]      12               3
15         47 MiB   30 GiB    47 MiB   30 GiB              [0,1,4,5,8,10,11,14,16,17]       0               0
sum       1.1 GiB  539 GiB   1.1 GiB  540 GiB
dumped osds

```

```shell
radosgw-admin realm create --default --rgw-realm=zone5
```
```
{
    "id": "04de377a-e366-429e-8d84-75d235409bd0",
    "name": "zone5",
    "current_period": "ac8fbc94-6159-4a29-902c-622f8fb11b88",
    "epoch": 1
}
```

```shell
radosgw-admin zonegroup delete --rgw-zonegroup=default
```
```
failed to load zonegroup: (2) No such file or directory
```

```shell
radosgw-admin realm default --default --rgw-realm=zone5
```
```shell
radosgw-admin zone delete --rgw-zone=default
```
```
failed to load zone: (2) No such file or directory
```

```shell
ceph tell mon.* injectargs --mon_allow_pool_delete true
```
```
mon.node140: {}
mon.node140: mon_allow_pool_delete = 'true'
mon.node142: {}
mon.node142: mon_allow_pool_delete = 'true'
mon.node141: {}
mon.node141: mon_allow_pool_delete = 'true'
```

```shell
ceph osd pool rm default.rgw.control default.rgw.control --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.data.root default.rgw.data.root --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.gc default.rgw.gc --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.log default.rgw.log --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.users.uid default.rgw.users.uid --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.meta default.rgw.meta   --yes-i-really-really-mean-it
```
```
pool 'default.rgw.control' does not exist
pool 'default.rgw.data.root' does not exist
pool 'default.rgw.gc' does not exist
pool 'default.rgw.log' does not exist
pool 'default.rgw.users.uid' does not exist
pool 'default.rgw.meta' does not exist
```

```shell
root@node140:~# ceph osd pool ls
.mgr
kube_zone_node5_ssd
.rgw.root
root@node140:~# ceph osd pool stats kube_zone_node5_ssd
pool kube_zone_node5_ssd id 2
  nothing is going on
```

```shell
radosgw-admin zonegroup create --rgw-zonegroup=ru --master --default --endpoints=http://192.168.200.140:9000,http://192.168.200.141:9000,http://192.168.200.141:9000
```
```
{
    "id": "5091017a-a382-4e9d-917a-8f3128bafbad",
    "name": "ru",
    "api_name": "ru",
    "is_master": true,
    "endpoints": [
        "http://192.168.200.140:9000",
        "http://192.168.200.141:9000",
        "http://192.168.200.141:9000"
    ],
    "hostnames": [],
    "hostnames_s3website": [],
    "master_zone": "",
    "zones": [],
    "placement_targets": [
        {
            "name": "default-placement",
            "tags": [],
            "storage_classes": []
        }
    ],
    "default_placement": "default-placement",
    "realm_id": "04de377a-e366-429e-8d84-75d235409bd0",
    "sync_policy": {
        "groups": []
    },
    "enabled_features": [
        "resharding"
    ]
}
```

```shell
radosgw-admin zone create --rgw-zone=kube_zone_node5_ssd --master --rgw-zonegroup=ru --endpoints=http://192.168.20.140:9000,http://192.168.200.141:9000,http://192.168.20.142:9000  \
  --access-key=1234567 --secret=098765 --default
```
```
{
    "id": "2a0ce75e-d119-46c4-82a1-d2fee219c62f",
    "name": "kube_zone_node5_ssd",
    "domain_root": "kube_zone_node5_ssd.rgw.meta:root",
    "control_pool": "kube_zone_node5_ssd.rgw.control",
    "gc_pool": "kube_zone_node5_ssd.rgw.log:gc",
    "lc_pool": "kube_zone_node5_ssd.rgw.log:lc",
    "log_pool": "kube_zone_node5_ssd.rgw.log",
    "intent_log_pool": "kube_zone_node5_ssd.rgw.log:intent",
    "usage_log_pool": "kube_zone_node5_ssd.rgw.log:usage",
    "roles_pool": "kube_zone_node5_ssd.rgw.meta:roles",
    "reshard_pool": "kube_zone_node5_ssd.rgw.log:reshard",
    "user_keys_pool": "kube_zone_node5_ssd.rgw.meta:users.keys",
    "user_email_pool": "kube_zone_node5_ssd.rgw.meta:users.email",
    "user_swift_pool": "kube_zone_node5_ssd.rgw.meta:users.swift",
    "user_uid_pool": "kube_zone_node5_ssd.rgw.meta:users.uid",
    "otp_pool": "kube_zone_node5_ssd.rgw.otp",
    "system_key": {
        "access_key": "1234567",
        "secret_key": "098765"
    },
    "placement_pools": [
        {
            "key": "default-placement",
            "val": {
                "index_pool": "kube_zone_node5_ssd.rgw.buckets.index",
                "storage_classes": {
                    "STANDARD": {
                        "data_pool": "kube_zone_node5_ssd.rgw.buckets.data"
                    }
                },
                "data_extra_pool": "kube_zone_node5_ssd.rgw.buckets.non-ec",
                "index_type": 0,
                "inline_data": true
            }
        }
    ],
    "realm_id": "04de377a-e366-429e-8d84-75d235409bd0",
    "notif_pool": "kube_zone_node5_ssd.rgw.log:notif"
}
```


```shell
radosgw-admin user create --uid=repuser --display-name="Replication_user" --access-key=1234567 --secret=098765 --system
```
```
2023-08-26T19:42:16.458+0500 7fcacf696a40  0 period (ac8fbc94-6159-4a29-902c-622f8fb11b88 does not have zone 2a0ce75e-d119-46c4-82a1-d2fee219c62f configured
{
    "user_id": "repuser",
    "display_name": "Replication_user",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "repuser",
            "access_key": "1234567",
            "secret_key": "098765"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "system": true,
    "default_placement": "",
    "default_storage_class": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
```

```shell
radosgw-admin caps add --uid=repuser --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"
```
```
2023-08-26T19:43:18.064+0500 7f26cab01a40  0 period (ac8fbc94-6159-4a29-902c-622f8fb11b88 does not have zone 2a0ce75e-d119-46c4-82a1-d2fee219c62f configured
{
    "user_id": "repuser",
    "display_name": "Replication_user",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "repuser",
            "access_key": "1234567",
            "secret_key": "098765"
        }
    ],
    "swift_keys": [],
    "caps": [
        {
            "type": "buckets",
            "perm": "*"
        },
        {
            "type": "metadata",
            "perm": "*"
        },
        {
            "type": "usage",
            "perm": "*"
        },
        {
            "type": "users",
            "perm": "*"
        },
        {
            "type": "zone",
            "perm": "*"
        }
    ],
    "op_mask": "read, write, delete",
    "system": true,
    "default_placement": "",
    "default_storage_class": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
```

```shell
radosgw-admin period update --rgw-realm=zone5 --commit
```

```shell
radosgw-admin zonegroup get --rgw-zonegroup=ru
```



```shell

ceph orch apply rgw s3store_zone_node5 --placement="3 node170 node170 node171"  --realm zone5 --zone kube_zone_node5_ssd --port 9000
## or 
ceph orch apply rgw s3store_zone_node5 --placement="label:rgw count-per-host:1" --realm zone5 --zone kube_zone_node5_ssd --port 9000

```

```
root@node140:~# ceph orch ps | grep s3store_zone_node5
rgw.s3store_zone_node5.node140.lhwdrr  node140  *:9000            running (13s)      6s ago   13s    83.2M        -  18.2.0   e0db6e7ec3f1  c637c03efc86
rgw.s3store_zone_node5.node141.inlxoj  node141  *:9000            running (14s)      6s ago   14s    85.3M        -  18.2.0   e0db6e7ec3f1  e2d6c6b23f65
rgw.s3store_zone_node5.node142.ttexwt  node142  *:9000            running (12s)      6s ago   12s    83.1M        -  18.2.0   e0db6e7ec3f1  4efa316a3920
```



```shell

radosgw-admin user create --uid=zone.user --display-name="ZoneUser" --access-key=SYSTEM_ACCESS_KEY --secret=SYSTEM_SECRET_KEY --system
radosgw-admin caps add --uid=zone.user --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"
...
    "keys": [
        {
            "user": "zone.user",
            "access_key": "SYSTEM_ACCESS_KEY",
            "secret_key": "SYSTEM_SECRET_KEY"
        }
    ],
...

```


```shell

docker run -it  --rm harbor.iblog.pro/test/minio:main.mc bash

mc alias set minio http://192.168.200.141:9000 SYSTEM_ACCESS_KEY SYSTEM_SECRET_KEY
mc alias rm gcs; mc alias rm local; mc alias rm local; mc alias rm play; mc alias rm s3

mc ls minio
mc mb minio/test

echo "23123" > data

mc cp data minio/test/data
mc rm minio/test/data

exit

```

```shell
ceph osd pool set kube_zone_node5_ssd.rgw.buckets.data crush_rule Zone_Node5_SSD
ceph osd pool set kube_zone_node5_ssd.rgw.buckets.index crush_rule Zone_Node5_SSD
ceph osd pool set kube_zone_node5_ssd.rgw.buckets.non-ec crush_rule Zone_Node5_SSD
```

### Test S3

```shell
docker run -it  --rm harbor.iblog.pro/test/minio:main.mc bash

wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-root.tar.xz
wget https://cloud.debian.org/images/cloud/bookworm/20230802-1460/debian-12-generic-amd64-20230802-1460.qcow2
mc alias set minio http://192.168.200.141:9000 SYSTEM_ACCESS_KEY SYSTEM_SECRET_KEY
mc alias rm gcs; mc alias rm local; mc alias rm local; mc alias rm play; mc alias rm s3

mc ls minio
mc mb minio/test

mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test/jammy-server-cloudimg-amd64-root.tar.xz
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test/jammy-server-cloudimg-amd64-root-2.tar.xz
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test/jammy-server-cloudimg-amd64-root-3.tar.xz
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test/jammy-server-cloudimg-amd64-root-4.tar.xz
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test/jammy-server-cloudimg-amd64-root-5.tar.xz
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test/test/jammy-server-cloudimg-amd64-root.tar.xz

mc cp debian-12-generic-amd64-20230802-1460.qcow2 minio/test/debian-12-generic-amd64-20230802-1460.qcow2
mc cp debian-12-generic-amd64-20230802-1460.qcow2 minio/test/debian-12-generic-amd64-20230802-1460.qcow2
mc cp debian-12-generic-amd64-20230802-1460.qcow2 minio/test/test/debian-12-generic-amd64-20230802-1460.qcow2


mc ls minio
mc tree minio
mc ls minio/test

```


```ceph
root@node140:~# ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
hdd    270 GiB  269 GiB  564 MiB   564 MiB       0.20
ssd    270 GiB  259 GiB   11 GiB    11 GiB       3.94
TOTAL  540 GiB  529 GiB   11 GiB    11 GiB       2.07

--- POOLS ---
POOL                                    ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                                     1    1  1.1 MiB        2  3.4 MiB      0     85 GiB
kube_zone_node5_ssd                      2   32      0 B        0      0 B      0     81 GiB
.rgw.root                                3   32  5.2 KiB       17  192 KiB      0     85 GiB
kube_zone_node5_ssd.rgw.log              4   32   34 KiB      179  516 KiB      0     85 GiB
kube_zone_node5_ssd.rgw.control          5   32      0 B        8      0 B      0     85 GiB
kube_zone_node5_ssd.rgw.meta             6   32  1.6 KiB       10   96 KiB      0     85 GiB
kube_zone_node5_ssd.rgw.buckets.index    7   32      0 B       11      0 B      0     81 GiB
kube_zone_node5_ssd.rgw.buckets.data     8   32  3.3 GiB      870   10 GiB   3.96     81 GiB
kube_zone_node5_ssd.rgw.buckets.non-ec   9    1      0 B        0      0 B      0     85 GiB
```

```shell

root@node140:~# ceph -s
  cluster:
    id:     28034564-4424-11ee-9218-8d474942c528
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 35m)
    mgr: node140.bowhtj(active, since 38m), standbys: node141.ixpsme
    osd: 18 osds: 18 up (since 17m), 18 in (since 17m)
    rgw: 3 daemons active (3 hosts, 1 zones)

  data:
    pools:   9 pools, 257 pgs
    objects: 1.10k objects, 3.3 GiB
    usage:   11 GiB used, 529 GiB / 540 GiB avail
    pgs:     255 active+clean
             2   active+clean+scrubbing

  io:
    client:   88 KiB/s rd, 0 B/s wr, 73 op/s rd, 74 op/s wr
    recovery: 0 B/s, 0 objects/s

  progress:


root@node140:~# ceph pg dump osds
OSD_STAT  USED     AVAIL    USED_RAW  TOTAL    HB_PEERS                     PG_SUM  PRIMARY_PG_SUM
17         51 MiB   30 GiB    51 MiB   30 GiB  [0,3,4,9,10,12,13,14,15,16]      52              12
16         51 MiB   30 GiB    51 MiB   30 GiB     [3,4,5,6,7,8,9,11,15,17]      49              14
5          69 MiB   30 GiB    69 MiB   30 GiB  [3,4,6,9,10,12,13,14,15,16]      62              13
4          73 MiB   30 GiB    73 MiB   30 GiB    [3,5,6,7,8,9,11,15,16,17]      57              27
3          68 MiB   30 GiB    68 MiB   30 GiB   [0,1,2,4,5,10,11,14,16,17]      60              25
2         916 MiB   29 GiB   916 MiB   30 GiB    [0,1,3,6,7,9,12,13,16,17]      23               5
0         1.4 GiB   29 GiB   1.4 GiB   30 GiB     [1,2,3,4,5,7,8,13,14,17]      34              12
1         966 MiB   29 GiB   966 MiB   30 GiB   [0,2,6,8,9,10,11,12,13,14]      30              12
6         764 MiB   29 GiB   764 MiB   30 GiB     [1,2,3,4,5,7,8,11,13,14]      29              12
7         1.2 GiB   29 GiB   1.2 GiB   30 GiB   [0,2,6,8,9,10,11,12,14,16]      25               9
8         1.2 GiB   29 GiB   1.2 GiB   30 GiB    [0,1,3,6,7,9,12,13,16,17]      33              13
9          69 MiB   30 GiB    69 MiB   30 GiB   [0,1,4,5,8,10,11,14,16,17]      52              19
10         69 MiB   30 GiB    69 MiB   30 GiB    [3,5,6,7,8,9,11,15,16,17]      55              19
11         68 MiB   30 GiB    68 MiB   30 GiB  [3,4,6,9,10,12,13,14,15,16]      47              11
12        1.4 GiB   29 GiB   1.4 GiB   30 GiB     [1,2,3,4,5,7,8,11,13,14]      33               4
13        1.4 GiB   29 GiB   1.4 GiB   30 GiB    [0,2,4,6,8,9,10,11,12,14]      41              15
14        1.5 GiB   29 GiB   1.5 GiB   30 GiB   [0,1,3,6,7,12,13,15,16,17]      40              14
15         68 MiB   30 GiB    68 MiB   30 GiB   [0,1,4,5,8,10,11,14,16,17]      49              21
sum        11 GiB  529 GiB    11 GiB  540 GiB
dumped osds

root@node140:~# ceph osd tree
ID   CLASS  WEIGHT   TYPE NAME         STATUS  REWEIGHT  PRI-AFF
-22         0.26367  root zone-node5
 -3         0.08789      host node140
  0    ssd  0.02930          osd.0         up   1.00000  1.00000
  6    ssd  0.02930          osd.6         up   1.00000  1.00000
 12    ssd  0.02930          osd.12        up   1.00000  1.00000
 -5         0.08789      host node141
  1    ssd  0.02930          osd.1         up   1.00000  1.00000
  7    ssd  0.02930          osd.7         up   1.00000  1.00000
 13    ssd  0.02930          osd.13        up   1.00000  1.00000
 -7         0.08789      host node142
  2    ssd  0.02930          osd.2         up   1.00000  1.00000
  8    ssd  0.02930          osd.8         up   1.00000  1.00000
 14    ssd  0.02930          osd.14        up   1.00000  1.00000
 -1         0.26367  root default
 -9         0.08789      host node143
  3    hdd  0.02930          osd.3         up   1.00000  1.00000
  9    hdd  0.02930          osd.9         up   1.00000  1.00000
 15    hdd  0.02930          osd.15        up   1.00000  1.00000
-11         0.08789      host node144
  4    hdd  0.02930          osd.4         up   1.00000  1.00000
 10    hdd  0.02930          osd.10        up   1.00000  1.00000
 16    hdd  0.02930          osd.16        up   1.00000  1.00000
-13         0.08789      host node145
  5    hdd  0.02930          osd.5         up   1.00000  1.00000
 11    hdd  0.02930          osd.11        up   1.00000  1.00000
 17    hdd  0.02930          osd.17        up   1.00000  1.00000


root@node140:~# ceph osd df
ID  CLASS  WEIGHT   REWEIGHT  SIZE     RAW USE  DATA     OMAP  META     AVAIL    %USE  VAR   PGS  STATUS
 0    ssd  0.02930   1.00000   30 GiB  1.4 GiB  1.3 GiB   0 B   65 MiB   29 GiB  4.59  2.21   34      up
 6    ssd  0.02930   1.00000   30 GiB  765 MiB  699 MiB   0 B   65 MiB   29 GiB  2.49  1.20   29      up
12    ssd  0.02930   1.00000   30 GiB  1.4 GiB  1.4 GiB   0 B   65 MiB   29 GiB  4.74  2.28   33      up
 1    ssd  0.02930   1.00000   30 GiB  966 MiB  901 MiB   0 B   65 MiB   29 GiB  3.14  1.51   30      up
 7    ssd  0.02930   1.00000   30 GiB  1.2 GiB  1.1 GiB   0 B   65 MiB   29 GiB  3.99  1.92   25      up
13    ssd  0.02930   1.00000   30 GiB  1.4 GiB  1.3 GiB   0 B   65 MiB   29 GiB  4.68  2.25   41      up
 2    ssd  0.02930   1.00000   30 GiB  916 MiB  851 MiB   0 B   65 MiB   29 GiB  2.98  1.43   23      up
 8    ssd  0.02930   1.00000   30 GiB  1.2 GiB  1.1 GiB   0 B   65 MiB   29 GiB  3.90  1.88   33      up
14    ssd  0.02930   1.00000   30 GiB  1.5 GiB  1.4 GiB   0 B   65 MiB   29 GiB  4.94  2.37   40      up
 3    hdd  0.02930   1.00000   30 GiB   69 MiB  3.2 MiB   0 B   65 MiB   30 GiB  0.22  0.11   60      up
 9    hdd  0.02930   1.00000   30 GiB   69 MiB  3.8 MiB   0 B   65 MiB   30 GiB  0.23  0.11   52      up
15    hdd  0.02930   1.00000   30 GiB   69 MiB  3.2 MiB   0 B   65 MiB   30 GiB  0.22  0.11   49      up
 4    hdd  0.02930   1.00000   30 GiB   73 MiB  3.2 MiB   0 B   69 MiB   30 GiB  0.24  0.11   58      up
10    hdd  0.02930   1.00000   30 GiB   69 MiB  3.8 MiB   0 B   65 MiB   30 GiB  0.23  0.11   54      up
16    hdd  0.02930   1.00000   30 GiB   69 MiB  3.2 MiB   0 B   65 MiB   30 GiB  0.22  0.11   49      up
 5    hdd  0.02930   1.00000   30 GiB   69 MiB  3.8 MiB   0 B   65 MiB   30 GiB  0.23  0.11   60      up
11    hdd  0.02930   1.00000   30 GiB   69 MiB  3.2 MiB   0 B   65 MiB   30 GiB  0.22  0.11   49      up
17    hdd  0.02930   1.00000   30 GiB   51 MiB  3.2 MiB   0 B   48 MiB   30 GiB  0.17  0.08   52      up
                       TOTAL  540 GiB   11 GiB   10 GiB   0 B  1.1 GiB  529 GiB  2.08
MIN/MAX VAR: 0.08/2.37  STDDEV: 1.95


root@node140:~# ceph orch device ls --wide
HOST     PATH      TYPE  TRANSPORT  RPM  DEVICE ID                         SIZE  HEALTH  IDENT  FAULT  AVAILABLE  REFRESHED  REJECT REASONS
node140  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         27m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         27m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node140  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         27m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         27m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         27m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node141  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         27m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         26m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         26m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node142  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         26m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node143  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         25m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node143  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         25m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node143  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         25m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node144  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         24m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node144  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         24m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node144  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         24m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node145  /dev/sdb  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G          N/A    N/A    No         23m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node145  /dev/sdc  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G          N/A    N/A    No         23m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node145  /dev/sdd  hdd                   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G          N/A    N/A    No         23m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked


root@node140:~# ceph osd status
ID  HOST      USED  AVAIL  WR OPS  WR DATA  RD OPS  RD DATA  STATE
 0  node140  1410M  28.6G      0        0       0        0   exists,up
 1  node141   965M  29.0G      0        0       0        0   exists,up
 2  node142   916M  29.1G      0        0       0        0   exists,up
 3  node143  68.6M  29.9G      0        0       0        0   exists,up
 4  node144  72.6M  29.9G      0        0       0        0   exists,up
 5  node145  69.2M  29.9G      0        0       0        0   exists,up
 6  node140   764M  29.2G      0        0       0        0   exists,up
 7  node141  1225M  28.7G      0        0       0        0   exists,up
 8  node142  1198M  28.8G      0        0       0        0   exists,up
 9  node143  69.1M  29.9G      0        0       0        0   exists,up
10  node144  69.1M  29.9G      0        0       1        0   exists,up
11  node145  68.5M  29.9G      0        0       0        0   exists,up
12  node140  1455M  28.5G      0        0       0        0   exists,up
13  node141  1438M  28.5G      0        0       0        0   exists,up
14  node142  1516M  28.5G      0        0       0        0   exists,up
15  node143  68.6M  29.9G      0        0       2        0   exists,up
16  node144  68.5M  29.9G      0        0       1        0   exists,up
17  node145  50.9M  29.9G      0        0       0        0   exists,up

root@node140:~# ceph osd tree
ID   CLASS  WEIGHT   TYPE NAME         STATUS  REWEIGHT  PRI-AFF
-22         0.26367  root zone-node5
 -3         0.08789      host node140
  0    ssd  0.02930          osd.0         up   1.00000  1.00000
  6    ssd  0.02930          osd.6         up   1.00000  1.00000
 12    ssd  0.02930          osd.12        up   1.00000  1.00000
 -5         0.08789      host node141
  1    ssd  0.02930          osd.1         up   1.00000  1.00000
  7    ssd  0.02930          osd.7         up   1.00000  1.00000
 13    ssd  0.02930          osd.13        up   1.00000  1.00000
 -7         0.08789      host node142
  2    ssd  0.02930          osd.2         up   1.00000  1.00000
  8    ssd  0.02930          osd.8         up   1.00000  1.00000
 14    ssd  0.02930          osd.14        up   1.00000  1.00000
 -1         0.26367  root default
 -9         0.08789      host node143
  3    hdd  0.02930          osd.3         up   1.00000  1.00000
  9    hdd  0.02930          osd.9         up   1.00000  1.00000
 15    hdd  0.02930          osd.15        up   1.00000  1.00000
-11         0.08789      host node144
  4    hdd  0.02930          osd.4         up   1.00000  1.00000
 10    hdd  0.02930          osd.10        up   1.00000  1.00000
 16    hdd  0.02930          osd.16        up   1.00000  1.00000
-13         0.08789      host node145
  5    hdd  0.02930          osd.5         up   1.00000  1.00000
 11    hdd  0.02930          osd.11        up   1.00000  1.00000
 17    hdd  0.02930          osd.17        up   1.00000  1.00000

```

