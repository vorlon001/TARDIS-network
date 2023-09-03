
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
192.168.200.170 node170
192.168.200.171 node171
192.168.200.172 node172
192.168.200.180 node180
192.168.200.181 node181
192.168.200.182 node182
EOF


cat <<EOF>hosts
node140
node141
node142
node143
node144
node145
node170
node171
node172
node180
node181
node182
EOF

declare -a arr=( 140 141 142 143 144 145 170 171 172 180 181 182 )
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
pdsh -w ^hosts -R ssh 'echo "192.168.200.145 node145" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.170 node170" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.171 node171" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.172 node172" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.180 node180" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.181 node181" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.182 node182" >> /etc/hosts'


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
declare -a arr=( 140 141 142 143 144 145 170 171 172 180 181 182 )
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

pdsh -w ^host-master -R ssh "ceph orch host add node170"
pdsh -w ^host-master -R ssh "ceph orch host add node171"
pdsh -w ^host-master -R ssh "ceph orch host add node172"

pdsh -w ^host-master -R ssh "ceph orch host add node180"
pdsh -w ^host-master -R ssh "ceph orch host add node181"
pdsh -w ^host-master -R ssh "ceph orch host add node182"

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
node170  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         11m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node170  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        11m ago
node170  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        11m ago
node171  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         10m ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node171  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        10m ago
node171  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        10m ago
node172  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         9m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node172  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        9m ago
node172  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        9m ago
node180  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         8m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node180  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        8m ago
node180  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        8m ago
node181  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         7m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node181  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        7m ago
node181  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        7m ago
node182  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         7m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node182  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  Yes        7m ago
node182  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  Yes        7m ago
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
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node170:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node171:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node172:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node180:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node181:/dev/sdb" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node182:/dev/sdb" && \
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
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node170:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node171:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node172:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node180:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node181:/dev/sdc" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node182:/dev/sdc" && \
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
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node170:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node171:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node172:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node180:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node181:/dev/sdd" && \
sleep 30 && \
pdsh -w ^host-master -R ssh "ceph orch daemon add osd node182:/dev/sdd" && \
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
node145  /dev/sde  hdd   QEMU_HARDDISK_drive-scsi0-0-0-4  30.0G  Yes        5m ago
node145  /dev/sdf  hdd   QEMU_HARDDISK_drive-scsi0-0-0-5  30.0G  Yes        5m ago
node145  /dev/sdg  hdd   QEMU_HARDDISK_drive-scsi0-0-0-6  30.0G  Yes        5m ago
node170  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         4m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node170  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         4m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node170  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         4m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node171  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         3m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node171  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         3m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node171  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         3m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node172  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         3m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node172  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         3m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node172  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         3m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node180  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         2m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node180  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         2m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node180  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         2m ago     Insufficient space (<10 extents) on vgs, LVM detected, locked
node181  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         77s ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node181  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         77s ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node181  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         77s ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node182  /dev/sdb  hdd   QEMU_HARDDISK_drive-scsi0-0-0-1  30.0G  No         24s ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node182  /dev/sdc  hdd   QEMU_HARDDISK_drive-scsi0-0-0-2  30.0G  No         24s ago    Insufficient space (<10 extents) on vgs, LVM detected, locked
node182  /dev/sdd  hdd   QEMU_HARDDISK_drive-scsi0-0-0-3  30.0G  No         24s ago    Insufficient space (<10 extents) on vgs, LVM detected, locked

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

```shell
node140: osd.0                  node140                    running (40m)     2m ago  40m    71.7M    4096M  18.2.0   e0db6e7ec3f1  ee74f60994ac
node140: osd.1                  node141                    running (39m)     3m ago  39m    71.6M    4096M  18.2.0   e0db6e7ec3f1  4ab105992f8d
node140: osd.2                  node142                    running (38m)     2m ago  38m    71.0M    1178M  18.2.0   e0db6e7ec3f1  a5f58bbabc16
node140: osd.3                  node170                    running (37m)     0s ago  37m    69.7M    1126M  18.2.0   e0db6e7ec3f1  7e6a92d64372
node140: osd.4                  node171                    running (36m)     9m ago  36m    66.0M    1126M  18.2.0   e0db6e7ec3f1  4b2c7a3b62d2
node140: osd.5                  node172                    running (35m)     8m ago  35m    67.0M    1126M  18.2.0   e0db6e7ec3f1  7775fc95b41a
node140: osd.6                  node180                    running (34m)     7m ago  34m    65.6M    1126M  18.2.0   e0db6e7ec3f1  ea9619431113
node140: osd.7                  node181                    running (33m)     6m ago  33m    67.3M    1126M  18.2.0   e0db6e7ec3f1  b92394e78e44
node140: osd.8                  node182                    running (33m)     5m ago  33m    67.9M    1126M  18.2.0   e0db6e7ec3f1  e31915754165
node140: osd.9                  node143                    running (32m)     2m ago  32m    67.8M    1126M  18.2.0   e0db6e7ec3f1  fdd128963787
node140: osd.10                 node144                    running (31m)    66s ago  31m    68.1M    1126M  18.2.0   e0db6e7ec3f1  df57e8d7fbee
node140: osd.11                 node145                    running (28m)    66s ago  28m    69.2M    1126M  18.2.0   e0db6e7ec3f1  080101d4f0e1
node140: osd.12                 node140                    running (26m)     2m ago  26m    68.1M    4096M  18.2.0   e0db6e7ec3f1  0894dd6d6fd3
node140: osd.13                 node141                    running (25m)     3m ago  25m    69.7M    4096M  18.2.0   e0db6e7ec3f1  9285ae12b385
node140: osd.14                 node142                    running (24m)     2m ago  24m    68.0M    1178M  18.2.0   e0db6e7ec3f1  80143c35a6ae
node140: osd.15                 node143                    running (23m)     2m ago  23m    68.6M    1126M  18.2.0   e0db6e7ec3f1  ea4798d487ed
node140: osd.16                 node144                    running (22m)    66s ago  22m    68.0M    1126M  18.2.0   e0db6e7ec3f1  3479e5135ed9
node140: osd.17                 node145                    running (21m)    66s ago  21m    67.7M    1126M  18.2.0   e0db6e7ec3f1  6f3d6992825e
node140: osd.18                 node170                    running (20m)     0s ago  20m    66.9M    1126M  18.2.0   e0db6e7ec3f1  799b375b4947
node140: osd.19                 node171                    running (20m)     9m ago  20m    62.5M    1126M  18.2.0   e0db6e7ec3f1  cccf6e2fec88
node140: osd.20                 node172                    running (19m)     8m ago  19m    62.3M    1126M  18.2.0   e0db6e7ec3f1  524d20478e5d
node140: osd.21                 node180                    running (18m)     7m ago  18m    63.3M    1126M  18.2.0   e0db6e7ec3f1  637d4141c353
node140: osd.22                 node181                    running (17m)     6m ago  17m    65.0M    1126M  18.2.0   e0db6e7ec3f1  d670c6f1f506
node140: osd.23                 node182                    running (16m)     5m ago  16m    65.8M    1126M  18.2.0   e0db6e7ec3f1  41391d2cb3e9
node140: osd.24                 node140                    running (15m)     2m ago  15m    66.9M    4096M  18.2.0   e0db6e7ec3f1  88848253cd46
node140: osd.25                 node141                    running (14m)     3m ago  14m    65.6M    4096M  18.2.0   e0db6e7ec3f1  8db43f260192
node140: osd.26                 node142                    running (13m)     2m ago  13m    64.8M    1178M  18.2.0   e0db6e7ec3f1  456d3fc09318
node140: osd.27                 node143                    running (13m)     2m ago  13m    64.4M    1126M  18.2.0   e0db6e7ec3f1  8a31c9bd66c8
node140: osd.28                 node144                    running (12m)    66s ago  12m    66.2M    1126M  18.2.0   e0db6e7ec3f1  b4680c7dc003
node140: osd.29                 node145                    running (11m)    66s ago  11m    63.7M    1126M  18.2.0   e0db6e7ec3f1  72a3275cb794
node140: osd.30                 node170                    running (10m)     0s ago  10m    65.4M    1126M  18.2.0   e0db6e7ec3f1  ac232abab50a
node140: osd.31                 node171                    running (9m)      9m ago   9m    11.7M    1126M  18.2.0   e0db6e7ec3f1  01ceb25c221f
node140: osd.32                 node172                    running (8m)      8m ago   8m    11.7M    1126M  18.2.0   e0db6e7ec3f1  6ca3cc850269
node140: osd.33                 node180                    running (7m)      7m ago   7m    11.7M    1126M  18.2.0   e0db6e7ec3f1  4e5933a8a1b8
node140: osd.34                 node181                    running (6m)      6m ago   6m    11.7M    1126M  18.2.0   e0db6e7ec3f1  3be98a66f0d2
node140: osd.35                 node182                    running (6m)      5m ago   6m    13.1M    1126M  18.2.0   e0db6e7ec3f1  aef8e36b38d2
```

```shell
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep node140 | grep osd"
node140: osd.0                  node140                    running (40m)     3m ago  40m    71.7M    4096M  18.2.0   e0db6e7ec3f1  ee74f60994ac
node140: osd.12                 node140                    running (27m)     3m ago  27m    68.1M    4096M  18.2.0   e0db6e7ec3f1  0894dd6d6fd3
node140: osd.24                 node140                    running (16m)     3m ago  16m    66.9M    4096M  18.2.0   e0db6e7ec3f1  88848253cd46

root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep node141 | grep osd"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.1                  node141                    running (40m)     4m ago  40m    71.6M    4096M  18.2.0   e0db6e7ec3f1  4ab105992f8d
node140: osd.13                 node141                    running (26m)     4m ago  26m    69.7M    4096M  18.2.0   e0db6e7ec3f1  9285ae12b385
node140: osd.25                 node141                    running (16m)     4m ago  16m    65.6M    4096M  18.2.0   e0db6e7ec3f1  8db43f260192
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node141"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.1                  node141                    running (40m)     5m ago  40m    71.6M    4096M  18.2.0   e0db6e7ec3f1  4ab105992f8d
node140: osd.13                 node141                    running (26m)     5m ago  26m    69.7M    4096M  18.2.0   e0db6e7ec3f1  9285ae12b385
node140: osd.25                 node141                    running (16m)     5m ago  16m    65.6M    4096M  18.2.0   e0db6e7ec3f1  8db43f260192
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node142"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.2                  node142                    running (39m)     3m ago  39m    71.0M    1178M  18.2.0   e0db6e7ec3f1  a5f58bbabc16
node140: osd.14                 node142                    running (26m)     3m ago  26m    68.0M    1178M  18.2.0   e0db6e7ec3f1  80143c35a6ae
node140: osd.26                 node142                    running (15m)     3m ago  15m    64.8M    1178M  18.2.0   e0db6e7ec3f1  456d3fc09318
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node143"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.9                  node143                    running (33m)     4m ago  33m    67.8M    1126M  18.2.0   e0db6e7ec3f1  fdd128963787
node140: osd.15                 node143                    running (25m)     4m ago  25m    68.6M    1126M  18.2.0   e0db6e7ec3f1  ea4798d487ed
node140: osd.27                 node143                    running (14m)     4m ago  14m    64.4M    1126M  18.2.0   e0db6e7ec3f1  8a31c9bd66c8
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node144"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.10                 node144                    running (32m)     2m ago  32m    68.1M    1126M  18.2.0   e0db6e7ec3f1  df57e8d7fbee
node140: osd.16                 node144                    running (24m)     2m ago  24m    68.0M    1126M  18.2.0   e0db6e7ec3f1  3479e5135ed9
node140: osd.28                 node144                    running (13m)     2m ago  13m    66.2M    1126M  18.2.0   e0db6e7ec3f1  b4680c7dc003
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node145"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.11                 node145                    running (30m)     2m ago  30m    69.2M    1126M  18.2.0   e0db6e7ec3f1  080101d4f0e1
node140: osd.17                 node145                    running (23m)     2m ago  23m    67.7M    1126M  18.2.0   e0db6e7ec3f1  6f3d6992825e
node140: osd.29                 node145                    running (13m)     2m ago  13m    63.7M    1126M  18.2.0   e0db6e7ec3f1  72a3275cb794
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node170"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.3                  node170                    running (42m)     4m ago  42m    69.7M    1126M  18.2.0   e0db6e7ec3f1  7e6a92d64372
node140: osd.18                 node170                    running (25m)     4m ago  25m    66.9M    1126M  18.2.0   e0db6e7ec3f1  799b375b4947
node140: osd.30                 node170                    running (15m)     4m ago  15m    65.4M    1126M  18.2.0   e0db6e7ec3f1  ac232abab50a
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node171"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.4                  node171                    running (41m)     3m ago  41m    68.7M    1126M  18.2.0   e0db6e7ec3f1  4b2c7a3b62d2
node140: osd.19                 node171                    running (24m)     3m ago  24m    66.7M    1126M  18.2.0   e0db6e7ec3f1  cccf6e2fec88
node140: osd.31                 node171                    running (14m)     3m ago  14m    65.1M    1126M  18.2.0   e0db6e7ec3f1  01ceb25c221f
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node172"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.5                  node172                    running (37m)    10m ago  37m    67.0M    1126M  18.2.0   e0db6e7ec3f1  7775fc95b41a
node140: osd.20                 node172                    running (21m)    10m ago  21m    62.3M    1126M  18.2.0   e0db6e7ec3f1  524d20478e5d
node140: osd.32                 node172                    running (10m)    10m ago  10m    11.7M    1126M  18.2.0   e0db6e7ec3f1  6ca3cc850269
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node180"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.6                  node180                    running (36m)     9m ago  36m    65.6M    1126M  18.2.0   e0db6e7ec3f1  ea9619431113
node140: osd.21                 node180                    running (20m)     9m ago  20m    63.3M    1126M  18.2.0   e0db6e7ec3f1  637d4141c353
node140: osd.33                 node180                    running (9m)      9m ago   9m    11.7M    1126M  18.2.0   e0db6e7ec3f1  4e5933a8a1b8
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node181"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.7                  node181                    running (36m)     9m ago  36m    67.3M    1126M  18.2.0   e0db6e7ec3f1  b92394e78e44
node140: osd.22                 node181                    running (19m)     9m ago  19m    65.0M    1126M  18.2.0   e0db6e7ec3f1  d670c6f1f506
node140: osd.34                 node181                    running (9m)      9m ago   9m    11.7M    1126M  18.2.0   e0db6e7ec3f1  3be98a66f0d2
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph orch ps | grep osd | grep node182"
node140: Warning: Permanently added 'node140' (ED25519) to the list of known hosts.
node140: osd.8                  node182                    running (35m)     8m ago  35m    67.9M    1126M  18.2.0   e0db6e7ec3f1  e31915754165
node140: osd.23                 node182                    running (18m)     8m ago  18m    65.8M    1126M  18.2.0   e0db6e7ec3f1  41391d2cb3e9
node140: osd.35                 node182                    running (8m)      8m ago   8m    13.1M    1126M  18.2.0   e0db6e7ec3f1  aef8e36b38d2
```
```shell

for i in {0..35}
do
ceph osd crush rm-device-class osd.${i}
done

```

```
# node140
ceph osd crush set-device-class ssd osd.0
ceph osd crush set-device-class ssd osd.12
ceph osd crush set-device-class ssd osd.24
# node141
ceph osd crush set-device-class ssd osd.1
ceph osd crush set-device-class ssd osd.13
ceph osd crush set-device-class ssd osd.25
# node142
ceph osd crush set-device-class ssd osd.2
ceph osd crush set-device-class ssd osd.14
ceph osd crush set-device-class ssd osd.26
# node143
ceph osd crush set-device-class ssd osd.9
ceph osd crush set-device-class ssd osd.15
ceph osd crush set-device-class ssd osd.27
# node144
ceph osd crush set-device-class ssd osd.10
ceph osd crush set-device-class ssd osd.16
ceph osd crush set-device-class ssd osd.28
# node145
ceph osd crush set-device-class ssd osd.11
ceph osd crush set-device-class ssd osd.17
ceph osd crush set-device-class ssd osd.29
# node170
ceph osd crush set-device-class hdd osd.3
ceph osd crush set-device-class hdd osd.18
ceph osd crush set-device-class hdd osd.30
# node171
ceph osd crush set-device-class hdd osd.4
ceph osd crush set-device-class hdd osd.19
ceph osd crush set-device-class hdd osd.31
# node172
ceph osd crush set-device-class hdd osd.5
ceph osd crush set-device-class hdd osd.20
ceph osd crush set-device-class hdd osd.32

# node180
ceph osd crush set-device-class default osd.6
ceph osd crush set-device-class default osd.21
ceph osd crush set-device-class default osd.33
# node181
ceph osd crush set-device-class default osd.7
ceph osd crush set-device-class default osd.22
ceph osd crush set-device-class default osd.34
# node182
ceph osd crush set-device-class default osd.8
ceph osd crush set-device-class default osd.23
ceph osd crush set-device-class default osd.35

```

```shell
root@ceph-install:/# pdsh -w ^host-master -R ssh "ceph osd tree" | more
```

```shell
ceph osd crush add-bucket zone-node5 root
ceph osd crush move node140 root=zone-node5
ceph osd crush move node141 root=zone-node5
ceph osd crush move node142 root=zone-node5
ceph osd crush move node143 root=zone-node5
ceph osd crush move node144 root=zone-node5
ceph osd crush move node145 root=zone-node5


ceph osd crush add-bucket zone-node3 root
ceph osd crush move node170 root=zone-node3
ceph osd crush move node171 root=zone-node3
ceph osd crush move node172 root=zone-node3
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
            "item": -54,
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
ceph osd crush rule create-replicated Zone_Node3_HDD zone-node3 host hdd
ceph osd crush rule dump Zone_Node3_HDD
```
```
{
    "rule_id": 3,
    "rule_name": "Zone_Node3_HDD",
    "type": 1,
    "steps": [
        {
            "op": "take",
            "item": -59,
            "item_name": "zone-node3~hdd"
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
ceph osd pool create kube_zone_node3_hdd 32
ceph osd pool application enable kube_zone_node3_hdd rbd
ceph osd pool set kube_zone_node3_hdd crush_rule Zone_Node3_HDD
```

```
pool 'kube_zone_node3_hdd' created
enabled application 'rbd' on pool 'kube_zone_node3_hdd'
set pool 3 crush_rule to Zone_Node3_HDD
```


```shell

root@node140:~# ceph device ls
DEVICE                           HOST:DEV                                                                                                                                         DAEMONS                                                                              WEAR  LIFE EXPECTANCY
QEMU_HARDDISK_drive-scsi0-0-0-0  node140:sda node141:sda node142:sda                                                                                                              mon.node140 mon.node141 mon.node142
QEMU_HARDDISK_drive-scsi0-0-0-1  node140:sdb node141:sdb node142:sdb node143:sdb node144:sdb node145:sdb node170:sdb node171:sdb node172:sdb node180:sdb node181:sdb node182:sdb  osd.0 osd.1 osd.10 osd.11 osd.2 osd.3 osd.4 osd.5 osd.6 osd.7 osd.8 osd.9
QEMU_HARDDISK_drive-scsi0-0-0-2  node140:sdc node141:sdc node142:sdc node143:sdc node144:sdc node145:sdc node170:sdc node171:sdc node172:sdc node180:sdc node181:sdc node182:sdc  osd.12 osd.13 osd.14 osd.15 osd.16 osd.17 osd.18 osd.19 osd.20 osd.21 osd.22 osd.23
QEMU_HARDDISK_drive-scsi0-0-0-3  node140:sdd node141:sdd node142:sdd node143:sdd node144:sdd node145:sdd node170:sdd node171:sdd node172:sdd node180:sdd node181:sdd node182:sdd  osd.24 osd.25 osd.26 osd.27 osd.28 osd.29 osd.30 osd.31 osd.32 osd.33 osd.34 osd.35

root@node140:~# ceph df
--- RAW STORAGE ---
CLASS       SIZE    AVAIL     USED  RAW USED  %RAW USED
default  270 GiB  269 GiB  621 MiB   621 MiB       0.22
hdd      270 GiB  269 GiB  620 MiB   620 MiB       0.22
ssd      540 GiB  539 GiB  1.2 GiB   1.2 GiB       0.22
TOTAL    1.1 TiB  1.1 TiB  2.4 GiB   2.4 GiB       0.22

--- POOLS ---
POOL                 ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                  1    1  1.9 MiB        2  5.7 MiB      0     85 GiB
kube_zone_node5_ssd   2   32      0 B        0      0 B      0    171 GiB
kube_zone_node3_hdd   3   32      0 B        0      0 B      0     85 GiB


root@node140:~# ceph pg dump osds
OSD_STAT  USED     AVAIL    USED_RAW  TOTAL    HB_PEERS                                                PG_SUM  PRIMARY_PG_SUM
35         69 MiB   30 GiB    69 MiB   30 GiB                 [0,22,24,25,26,27,28,29,30,31,32,33,34]       0               0
34         69 MiB   30 GiB    69 MiB   30 GiB                  [6,8,12,13,14,15,16,17,18,19,20,33,35]       1               0
33         69 MiB   30 GiB    69 MiB   30 GiB                       [0,1,2,3,4,8,9,10,11,20,22,32,34]       0               0
32         69 MiB   30 GiB    69 MiB   30 GiB            [4,6,18,19,24,25,26,27,28,29,30,31,33,34,35]       9               2
31         69 MiB   30 GiB    69 MiB   30 GiB            [3,5,12,13,14,15,16,17,18,20,21,22,23,30,32]      15               7
30         69 MiB   30 GiB    69 MiB   30 GiB                      [0,1,2,4,5,6,7,8,9,10,11,20,29,31]       9               3
29         69 MiB   30 GiB    69 MiB   30 GiB           [2,15,16,18,24,25,26,27,28,30,31,32,33,34,35]       3               2
28         69 MiB   30 GiB    69 MiB   30 GiB         [1,9,11,12,13,14,15,18,19,20,21,22,23,26,27,29]       8               2
27         69 MiB   30 GiB    69 MiB   30 GiB                  [0,1,3,4,5,6,7,8,11,13,14,16,17,26,28]       8               1
26         69 MiB   30 GiB    69 MiB   30 GiB          [0,1,9,13,15,24,25,27,28,29,30,31,32,33,34,35]       5               2
25         69 MiB   30 GiB    69 MiB   30 GiB          [11,12,14,15,16,17,18,19,20,21,22,23,24,26,28]       7               2
24         69 MiB   30 GiB    69 MiB   30 GiB                [1,2,3,4,5,6,7,8,9,10,11,23,25,27,28,29]       4               3
23         69 MiB   30 GiB    69 MiB   30 GiB         [6,7,12,21,22,24,25,26,27,28,29,30,31,32,33,34]       0               0
22         69 MiB   30 GiB    69 MiB   30 GiB                  [6,8,12,13,14,15,16,17,18,19,20,21,23]       0               0
21         69 MiB   30 GiB    69 MiB   30 GiB                       [0,1,2,3,4,8,9,10,11,20,22,32,34]       0               0
20         69 MiB   30 GiB    69 MiB   30 GiB            [4,6,18,19,21,24,25,26,27,28,29,30,31,34,35]      12               2
19         69 MiB   30 GiB    69 MiB   30 GiB            [3,5,12,13,14,15,16,17,18,20,21,22,23,30,32]       9               4
18         69 MiB   30 GiB    69 MiB   30 GiB                [0,1,2,4,5,6,7,8,9,10,11,17,19,20,31,32]      14               6
17         69 MiB   30 GiB    69 MiB   30 GiB              [2,16,18,24,25,26,27,28,30,31,32,33,34,35]       5               1
16         69 MiB   30 GiB    69 MiB   30 GiB                 [9,11,12,13,14,15,17,18,19,20,21,22,23]       2               0
5          69 MiB   30 GiB    69 MiB   30 GiB             [3,4,6,18,24,25,26,27,28,29,30,31,33,34,35]      11               3
4          69 MiB   30 GiB    69 MiB   30 GiB  [3,5,6,8,12,13,14,15,16,17,18,20,21,22,23,30,32,34,35]       8               3
3          69 MiB   30 GiB    69 MiB   30 GiB                      [0,1,2,4,5,6,7,8,9,10,11,19,26,31]       9               2
2          69 MiB   30 GiB    69 MiB   30 GiB                  [1,3,13,18,24,27,28,29,31,32,33,34,35]       6               1
0          69 MiB   30 GiB    69 MiB   30 GiB                      [1,2,3,4,5,6,7,8,9,10,11,13,28,35]       6               2
1          69 MiB   30 GiB    69 MiB   30 GiB               [0,2,15,16,17,18,19,20,21,22,23,24,26,27]       7               3
6          69 MiB   30 GiB    69 MiB   30 GiB                      [0,1,2,3,4,5,7,8,9,10,11,20,22,34]       1               1
7          69 MiB   30 GiB    69 MiB   30 GiB                  [6,8,12,13,14,15,16,17,18,19,20,33,35]       0               0
8          69 MiB   30 GiB    69 MiB   30 GiB                  [7,9,15,22,24,25,26,28,29,30,31,32,33]       1               0
9          69 MiB   30 GiB    69 MiB   30 GiB                         [0,1,2,3,4,5,6,7,8,10,11,28,35]       4               1
10         69 MiB   30 GiB    69 MiB   30 GiB              [9,11,12,13,14,15,17,18,19,20,21,22,23,25]       5               3
11         69 MiB   30 GiB    69 MiB   30 GiB             [10,12,13,24,25,26,27,28,30,31,32,33,34,35]       4               1
12         69 MiB   30 GiB    69 MiB   30 GiB                         [1,2,3,4,5,6,7,8,9,10,11,13,17]       1               0
13         69 MiB   30 GiB    69 MiB   30 GiB        [2,12,14,15,16,17,18,19,20,21,22,23,24,26,27,28]      10               3
14         69 MiB   30 GiB    69 MiB   30 GiB            [1,9,10,13,15,16,24,28,29,30,31,32,33,34,35]       4               2
15         69 MiB   30 GiB    69 MiB   30 GiB                  [0,1,3,4,5,6,7,8,11,13,14,16,25,26,28]       7               3
sum       2.4 GiB  1.1 TiB   2.4 GiB  1.1 TiB
dumped osds

```

```shell
radosgw-admin realm create --default --rgw-realm=zone5
```
```
{
    "id": "91522e8e-c946-4818-94b3-5f9854bc75b7",
    "name": "zone5",
    "current_period": "1d53ea04-69c7-4a0b-a2eb-07f9c6031302",
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
radosgw-admin zonegroup create --rgw-zonegroup=ru --master --default --endpoints=http://192.168.200.140:9000,http://192.168.200.141:9000,http://192.168.200.141:9000
```
```
{
    "id": "beb31732-a76c-4fa0-a413-01a09f94737d",
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
    "realm_id": "91522e8e-c946-4818-94b3-5f9854bc75b7",
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
    "id": "c0a98dff-bc65-4db8-8866-486a59df0715",
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
    "realm_id": "91522e8e-c946-4818-94b3-5f9854bc75b7",
    "notif_pool": "kube_zone_node5_ssd.rgw.log:notif"
}
```


```shell
radosgw-admin user create --uid=repuser --display-name="Replication_user" --access-key=1234567 --secret=098765 --system
```
```
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


### Test S3
### S3 RGW in default crush zone!!!!!!!!!!!!

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



```shell
root@node140:~# ceph -s
  cluster:
    id:     39771332-43e5-11ee-acdd-c9cea774700e
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 118m)
    mgr: node140.zbnczp(active, since 2h), standbys: node141.ltbvun, node142.xurvqw
    osd: 36 osds: 36 up (since 72m), 36 in (since 73m)
    rgw: 3 daemons active (3 hosts, 1 zones)

  data:
    pools:   10 pools, 289 pgs
    objects: 850 objects, 2.4 GiB
    usage:   9.7 GiB used, 1.0 TiB / 1.1 TiB avail
    pgs:     289 active+clean

  io:
    client:   36 KiB/s rd, 31 MiB/s wr, 45 op/s rd, 38 op/s wr
    recovery: 12 MiB/s, 3 objects/s

root@node140:~# ceph df
--- RAW STORAGE ---
CLASS       SIZE    AVAIL     USED  RAW USED  %RAW USED
default  270 GiB  262 GiB  7.9 GiB   7.9 GiB       2.92
hdd      270 GiB  269 GiB  640 MiB   640 MiB       0.23
ssd      540 GiB  539 GiB  1.3 GiB   1.3 GiB       0.23
TOTAL    1.1 TiB  1.0 TiB  9.8 GiB   9.8 GiB       0.90

--- POOLS ---
POOL                                    ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                                     1    1  1.9 MiB        2  5.7 MiB      0     82 GiB
kube_zone_node5_ssd                      2   32      0 B        0      0 B      0    171 GiB
kube_zone_node3_hdd                      3   32      0 B        0      0 B      0     85 GiB
.rgw.root                                4   32  5.2 KiB       17  192 KiB      0     82 GiB
kube_zone_node5_ssd.rgw.log              5   32   51 KiB      179  588 KiB      0     82 GiB
kube_zone_node5_ssd.rgw.control          6   32      0 B        8      0 B      0     82 GiB
kube_zone_node5_ssd.rgw.meta             7   32  1.6 KiB       10   96 KiB      0     82 GiB
kube_zone_node5_ssd.rgw.buckets.index    8   32      0 B       11      0 B      0     82 GiB
kube_zone_node5_ssd.rgw.buckets.data     9   32  2.4 GiB      623  7.2 GiB   2.85     82 GiB
kube_zone_node5_ssd.rgw.buckets.non-ec  10   32      0 B        0      0 B      0     82 GiB

root@node140:~# ceph pg dump osds
OSD_STAT  USED      AVAIL    USED_RAW  TOTAL    HB_PEERS                                          PG_SUM  PRIMARY_PG_SUM
35         840 MiB   29 GiB   840 MiB   30 GiB    [0,6,7,21,22,24,25,26,27,28,29,30,31,32,33,34]      71              17
34         692 MiB   29 GiB   692 MiB   30 GiB      [6,8,12,13,14,15,16,17,18,19,20,21,23,33,35]      68              21
33         904 MiB   29 GiB   904 MiB   30 GiB         [0,1,2,3,4,7,8,9,10,11,20,22,23,32,34,35]      76              27
32          72 MiB   30 GiB    72 MiB   30 GiB      [4,6,18,19,24,25,26,27,28,29,30,31,33,34,35]       9               2
31          72 MiB   30 GiB    72 MiB   30 GiB      [3,5,12,13,14,15,16,17,18,20,21,22,23,30,32]      15               7
30          72 MiB   30 GiB    72 MiB   30 GiB                [0,1,2,4,5,6,7,8,9,10,11,20,29,31]       9               3
29          72 MiB   30 GiB    72 MiB   30 GiB     [2,15,16,18,24,25,26,27,28,30,31,32,33,34,35]       3               2
28          72 MiB   30 GiB    72 MiB   30 GiB   [1,9,11,12,13,14,15,18,19,20,21,22,23,26,27,29]       8               2
27          72 MiB   30 GiB    72 MiB   30 GiB            [0,1,3,4,5,6,7,8,11,13,14,16,17,26,28]       8               1
26          72 MiB   30 GiB    72 MiB   30 GiB    [0,1,9,13,15,24,25,27,28,29,30,31,32,33,34,35]       5               2
25          72 MiB   30 GiB    72 MiB   30 GiB    [11,12,14,15,16,17,18,19,20,21,22,23,24,26,28]       7               2
24          72 MiB   30 GiB    72 MiB   30 GiB          [1,2,3,4,5,6,7,8,9,10,11,23,25,27,28,29]       4               3
23         887 MiB   29 GiB   887 MiB   30 GiB   [6,7,12,21,22,24,25,26,27,28,29,30,31,32,33,34]      78              19
22         975 MiB   29 GiB   975 MiB   30 GiB      [6,8,12,13,14,15,16,17,18,19,20,21,23,33,35]      86              33
21         1.1 GiB   29 GiB   1.1 GiB   30 GiB         [0,1,2,3,4,7,8,9,10,11,20,22,23,32,34,35]      87              29
20          72 MiB   30 GiB    72 MiB   30 GiB      [4,6,18,19,21,24,25,26,27,28,29,30,31,34,35]      12               2
19          72 MiB   30 GiB    72 MiB   30 GiB      [3,5,12,13,14,15,16,17,18,20,21,22,23,30,32]       9               4
18          72 MiB   30 GiB    72 MiB   30 GiB          [0,1,2,4,5,6,7,8,9,10,11,17,19,20,31,32]      14               6
17          72 MiB   30 GiB    72 MiB   30 GiB        [2,16,18,24,25,26,27,28,30,31,32,33,34,35]       5               1
16          72 MiB   30 GiB    72 MiB   30 GiB           [9,11,12,13,14,15,17,18,19,20,21,22,23]       2               0
5           72 MiB   30 GiB    72 MiB   30 GiB       [3,4,6,18,24,25,26,27,28,29,30,31,33,34,35]      11               3
4           72 MiB   30 GiB    72 MiB   30 GiB      [3,5,12,13,14,15,16,17,18,20,21,22,23,30,32]       8               3
3           72 MiB   30 GiB    72 MiB   30 GiB                [0,1,2,4,5,6,7,8,9,10,11,19,26,31]       9               2
2           76 MiB   30 GiB    76 MiB   30 GiB            [1,3,13,18,24,27,28,29,31,32,33,34,35]       6               1
0           72 MiB   30 GiB    72 MiB   30 GiB                [1,2,3,4,5,6,7,8,9,10,11,13,28,35]       6               2
1           72 MiB   30 GiB    72 MiB   30 GiB         [0,2,15,16,17,18,19,20,21,22,23,24,26,27]       7               3
6          662 MiB   29 GiB   662 MiB   30 GiB          [0,1,2,3,4,5,7,8,9,10,11,20,22,23,34,35]      62              23
7         1021 MiB   29 GiB  1021 MiB   30 GiB         [6,8,12,13,14,15,16,17,18,20,21,23,33,35]      71              24
8          961 MiB   29 GiB   961 MiB   30 GiB    [6,7,9,15,21,22,24,25,26,28,29,30,31,32,33,34]      76              32
9           72 MiB   30 GiB    72 MiB   30 GiB                   [0,1,2,3,4,5,6,7,8,10,11,28,35]       4               1
10          72 MiB   30 GiB    72 MiB   30 GiB        [9,11,12,13,14,15,17,18,19,20,21,22,23,25]       5               3
11          72 MiB   30 GiB    72 MiB   30 GiB       [10,12,13,24,25,26,27,28,30,31,32,33,34,35]       4               1
12          72 MiB   30 GiB    72 MiB   30 GiB                   [1,2,3,4,5,6,7,8,9,10,11,13,17]       1               0
13          72 MiB   30 GiB    72 MiB   30 GiB  [2,12,14,15,16,17,18,19,20,21,22,23,24,26,27,28]      10               3
14          72 MiB   30 GiB    72 MiB   30 GiB      [1,9,10,13,15,16,24,28,29,30,31,32,33,34,35]       4               2
15          72 MiB   30 GiB    72 MiB   30 GiB            [0,1,3,4,5,6,7,8,11,13,14,16,25,26,28]       7               3
sum        9.8 GiB  1.0 TiB   9.8 GiB  1.1 TiB
dumped osds


root@node140:~# ceph osd tree
...........
-57           0.26367  root zone-node3
 -9           0.08789      host node170
  3      hdd  0.02930          osd.3         up   1.00000  1.00000
 18      hdd  0.02930          osd.18        up   1.00000  1.00000
 30      hdd  0.02930          osd.30        up   1.00000  1.00000
-11           0.08789      host node171
  4      hdd  0.02930          osd.4         up   1.00000  1.00000
 19      hdd  0.02930          osd.19        up   1.00000  1.00000
 31      hdd  0.02930          osd.31        up   1.00000  1.00000
-13           0.08789      host node172
  5      hdd  0.02930          osd.5         up   1.00000  1.00000
 20      hdd  0.02930          osd.20        up   1.00000  1.00000
 32      hdd  0.02930          osd.32        up   1.00000  1.00000
...........
-53           0.52734  root zone-node5
 -3           0.08789      host node140
  0      ssd  0.02930          osd.0         up   1.00000  1.00000
 12      ssd  0.02930          osd.12        up   1.00000  1.00000
 24      ssd  0.02930          osd.24        up   1.00000  1.00000
 -5           0.08789      host node141
  1      ssd  0.02930          osd.1         up   1.00000  1.00000
 13      ssd  0.02930          osd.13        up   1.00000  1.00000
 25      ssd  0.02930          osd.25        up   1.00000  1.00000
 -7           0.08789      host node142
  2      ssd  0.02930          osd.2         up   1.00000  1.00000
 14      ssd  0.02930          osd.14        up   1.00000  1.00000
 26      ssd  0.02930          osd.26        up   1.00000  1.00000
-21           0.08789      host node143
  9      ssd  0.02930          osd.9         up   1.00000  1.00000
 15      ssd  0.02930          osd.15        up   1.00000  1.00000
 27      ssd  0.02930          osd.27        up   1.00000  1.00000
-23           0.08789      host node144
 10      ssd  0.02930          osd.10        up   1.00000  1.00000
 16      ssd  0.02930          osd.16        up   1.00000  1.00000
 28      ssd  0.02930          osd.28        up   1.00000  1.00000
-25           0.08789      host node145
 11      ssd  0.02930          osd.11        up   1.00000  1.00000
 17      ssd  0.02930          osd.17        up   1.00000  1.00000
 29      ssd  0.02930          osd.29        up   1.00000  1.00000
...........



root@node140:~# ceph pg dump osds
OSD_STAT  USED     AVAIL    USED_RAW  TOTAL    HB_PEERS                                          PG_SUM  PRIMARY_PG_SUM
35        840 MiB   29 GiB   840 MiB   30 GiB    [0,6,7,21,22,24,25,26,27,28,29,30,31,32,33,34]      71              17
34        692 MiB   29 GiB   692 MiB   30 GiB      [6,8,12,13,14,15,16,17,18,19,20,21,23,33,35]      68              21
33        909 MiB   29 GiB   909 MiB   30 GiB         [0,1,2,3,4,7,8,9,10,11,20,22,23,32,34,35]      76              27
32         72 MiB   30 GiB    72 MiB   30 GiB      [4,6,18,19,24,25,26,27,28,29,30,31,33,34,35]       9               2
31         72 MiB   30 GiB    72 MiB   30 GiB      [3,5,12,13,14,15,16,17,18,20,21,22,23,30,32]      15               7
30         72 MiB   30 GiB    72 MiB   30 GiB                [0,1,2,4,5,6,7,8,9,10,11,20,29,31]       9               3
29         72 MiB   30 GiB    72 MiB   30 GiB     [2,15,16,18,24,25,26,27,28,30,31,32,33,34,35]       3               2
28         72 MiB   30 GiB    72 MiB   30 GiB   [1,9,11,12,13,14,15,18,19,20,21,22,23,26,27,29]       8               2
27         72 MiB   30 GiB    72 MiB   30 GiB            [0,1,3,4,5,6,7,8,11,13,14,16,17,26,28]       8               1
26         72 MiB   30 GiB    72 MiB   30 GiB    [0,1,9,13,15,24,25,27,28,29,30,31,32,33,34,35]       5               2
25         72 MiB   30 GiB    72 MiB   30 GiB    [11,12,14,15,16,17,18,19,20,21,22,23,24,26,28]       7               2
24         72 MiB   30 GiB    72 MiB   30 GiB          [1,2,3,4,5,6,7,8,9,10,11,23,25,27,28,29]       4               3
23        891 MiB   29 GiB   891 MiB   30 GiB   [6,7,12,21,22,24,25,26,27,28,29,30,31,32,33,34]      78              19
22        975 MiB   29 GiB   975 MiB   30 GiB      [6,8,12,13,14,15,16,17,18,19,20,21,23,33,35]      86              33
21        1.1 GiB   29 GiB   1.1 GiB   30 GiB         [0,1,2,3,4,7,8,9,10,11,20,22,23,32,34,35]      87              29
20         72 MiB   30 GiB    72 MiB   30 GiB      [4,6,18,19,21,24,25,26,27,28,29,30,31,34,35]      12               2
19         72 MiB   30 GiB    72 MiB   30 GiB      [3,5,12,13,14,15,16,17,18,20,21,22,23,30,32]       9               4
18         72 MiB   30 GiB    72 MiB   30 GiB          [0,1,2,4,5,6,7,8,9,10,11,17,19,20,31,32]      14               6
17         72 MiB   30 GiB    72 MiB   30 GiB        [2,16,18,24,25,26,27,28,30,31,32,33,34,35]       5               1
16         72 MiB   30 GiB    72 MiB   30 GiB           [9,11,12,13,14,15,17,18,19,20,21,22,23]       2               0
5          72 MiB   30 GiB    72 MiB   30 GiB       [3,4,6,18,24,25,26,27,28,29,30,31,33,34,35]      11               3
4          72 MiB   30 GiB    72 MiB   30 GiB      [3,5,12,13,14,15,16,17,18,20,21,22,23,30,32]       8               3
3          72 MiB   30 GiB    72 MiB   30 GiB                [0,1,2,4,5,6,7,8,9,10,11,19,26,31]       9               2
2          76 MiB   30 GiB    76 MiB   30 GiB            [1,3,13,18,24,27,28,29,31,32,33,34,35]       6               1
0          72 MiB   30 GiB    72 MiB   30 GiB                [1,2,3,4,5,6,7,8,9,10,11,13,28,35]       6               2
1          72 MiB   30 GiB    72 MiB   30 GiB         [0,2,15,16,17,18,19,20,21,22,23,24,26,27]       7               3
6         662 MiB   29 GiB   662 MiB   30 GiB          [0,1,2,3,4,5,7,8,9,10,11,20,22,23,34,35]      62              23
7         1.0 GiB   29 GiB   1.0 GiB   30 GiB      [6,8,12,13,14,15,16,17,18,19,20,21,23,33,35]      71              24
8         961 MiB   29 GiB   961 MiB   30 GiB    [6,7,9,15,21,22,24,25,26,28,29,30,31,32,33,34]      76              32
9          72 MiB   30 GiB    72 MiB   30 GiB                   [0,1,2,3,4,5,6,7,8,10,11,28,35]       4               1
10         72 MiB   30 GiB    72 MiB   30 GiB        [9,11,12,13,14,15,17,18,19,20,21,22,23,25]       5               3
11         72 MiB   30 GiB    72 MiB   30 GiB       [10,12,13,24,25,26,27,28,30,31,32,33,34,35]       4               1
12         72 MiB   30 GiB    72 MiB   30 GiB                   [1,2,3,4,5,6,7,8,9,10,11,13,17]       1               0
13         72 MiB   30 GiB    72 MiB   30 GiB  [2,12,14,15,16,17,18,19,20,21,22,23,24,26,27,28]      10               3
14         72 MiB   30 GiB    72 MiB   30 GiB      [1,9,10,13,15,16,24,28,29,30,31,32,33,34,35]       4               2
15         72 MiB   30 GiB    72 MiB   30 GiB            [0,1,3,4,5,6,7,8,11,13,14,16,25,26,28]       7               3
sum       9.8 GiB  1.0 TiB   9.8 GiB  1.1 TiB
dumped osds


```


### exmaple
```shell
 radosgw-admin zonegroup placement add \
      --rgw-zonegroup ru \
      --placement-id default-placement \
      --storage-class ssd

 radosgw-admin zonegroup placement rm \
      --rgw-zonegroup ru \
      --placement-id default-placement \
      --storage-class STANDARD
```




```shell

root@node140:~# ceph df
--- RAW STORAGE ---
CLASS       SIZE    AVAIL     USED  RAW USED  %RAW USED
default  270 GiB  252 GiB   18 GiB    18 GiB       6.66
hdd      270 GiB  269 GiB  644 MiB   644 MiB       0.23
ssd      540 GiB  539 GiB  1.3 GiB   1.3 GiB       0.23
TOTAL    1.1 TiB  1.0 TiB   20 GiB    20 GiB       1.84

--- POOLS ---
POOL                                    ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                                     1    1  1.9 MiB        2  5.7 MiB      0     77 GiB
kube_zone_node5_ssd                      2   32      0 B        0      0 B      0    171 GiB
kube_zone_node3_hdd                      3   32      0 B        0      0 B      0     85 GiB
.rgw.root                                4   32  5.1 KiB       17  192 KiB      0     77 GiB
kube_zone_node5_ssd.rgw.log              5   32  258 KiB      306  2.7 MiB      0     77 GiB
kube_zone_node5_ssd.rgw.control          6   32      0 B        8      0 B      0     77 GiB
kube_zone_node5_ssd.rgw.meta             7   32  1.6 KiB       10   96 KiB      0     77 GiB
kube_zone_node5_ssd.rgw.buckets.index    8   32      0 B       11      0 B      0     77 GiB
kube_zone_node5_ssd.rgw.buckets.data     9   32  5.7 GiB    1.49k   17 GiB   6.89     77 GiB
kube_zone_node5_ssd.rgw.buckets.non-ec  10   32      0 B        0      0 B      0     77 GiB
```

```shell
rbd -p kube_zone_node5_ssd create scsi --size 10G --object-size 1M
rbd map kube_zone_node5_ssd/scsi
>>> /dev/rbd0

mkfs.ext4 /dev/rbd2
fdisk -l /dev/rbd2
mount /dev/rbd2 /mnt/
dd if=/dev/zero of=/mnt/test3.img bs=1M count=7000

```

```shell
rbd -p kube_zone_node3_hdd create scsi --size 10G --object-size 1M
rbd map kube_zone_node3_hdd/scsi
>>> /dev/rbd0

mkfs.ext4 /dev/rbd0
fdisk -l /dev/rbd0
mount /dev/rbd0 /mnt/
dd if=/dev/zero of=/mnt/test3.img bs=1M count=7000
```

```shell
rbd -p kube_zone_node5_ssd rm scsi

root@node140:~# rados -p kube_zone_node5_ssd ls
rbd_directory
rbd_info
rbd_trash
root@node140:~# rados -p kube_zone_node3_hdd ls
rbd_directory
rbd_info
rbd_trash


```

```shell

root@node140:~# ceph osd df tree hdd
ID   CLASS  WEIGHT   REWEIGHT  SIZE     RAW USE  DATA      OMAP  META     AVAIL    %USE  VAR   PGS  STATUS  TYPE NAME
-57         0.26367         -  270 GiB   11 GiB    11 GiB   0 B  759 MiB  259 GiB  4.22  1.00    -          root zone-node3
 -9         0.08789         -   90 GiB  3.8 GiB   3.6 GiB   0 B  253 MiB   86 GiB  4.22  1.00    -              host node170
  3    hdd  0.02930   1.00000   30 GiB  1.1 GiB   1.0 GiB   0 B   69 MiB   29 GiB  3.57  0.85    9      up          osd.3
 18    hdd  0.02930   1.00000   30 GiB  1.6 GiB   1.5 GiB   0 B  118 MiB   28 GiB  5.50  1.30   14      up          osd.18
 30    hdd  0.02930   1.00000   30 GiB  1.1 GiB   1.0 GiB   0 B   65 MiB   29 GiB  3.60  0.85    9      up          osd.30
-11         0.08789         -   90 GiB  3.8 GiB   3.6 GiB   0 B  249 MiB   86 GiB  4.22  1.00    -              host node171
  4    hdd  0.02930   1.00000   30 GiB  988 MiB   922 MiB   0 B   65 MiB   29 GiB  3.22  0.76    8      up          osd.4
 19    hdd  0.02930   1.00000   30 GiB  1.1 GiB  1021 MiB   0 B   65 MiB   29 GiB  3.54  0.84    9      up          osd.19
 31    hdd  0.02930   1.00000   30 GiB  1.8 GiB   1.7 GiB   0 B  118 MiB   28 GiB  5.90  1.40   15      up          osd.31
-13         0.08789         -   90 GiB  3.8 GiB   3.6 GiB   0 B  257 MiB   86 GiB  4.23  1.00    -              host node172
  5    hdd  0.02930   1.00000   30 GiB  1.3 GiB   1.2 GiB   0 B   69 MiB   29 GiB  4.33  1.02   11      up          osd.5
 20    hdd  0.02930   1.00000   30 GiB  1.4 GiB   1.3 GiB   0 B   69 MiB   29 GiB  4.65  1.10   12      up          osd.20
 32    hdd  0.02930   1.00000   30 GiB  1.1 GiB  1019 MiB   0 B  118 MiB   29 GiB  3.70  0.88    9      up          osd.32
-53         0.52734         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -          root zone-node5
 -3         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node140
 -5         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node141
 -7         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node142
-21         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node143
-23         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node144
-25         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node145
 -1         0.26367         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -          root default
-15         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node180
-17         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node181
-19         0.08789         -      0 B      0 B       0 B   0 B      0 B      0 B     0     0    -              host node182
                        TOTAL  270 GiB   11 GiB    11 GiB   0 B  759 MiB  259 GiB  4.22
MIN/MAX VAR: 0.76/1.40  STDDEV: 0.89

root@node140:~# rados df
POOL_NAME                                  USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS       RD  WR_OPS       WR  USED COMPR  UNDER COMPR
.mgr                                    1.7 MiB        2       0       6                   0        0         0     212  306 KiB     179  2.4 MiB         0 B          0 B
.rgw.root                               192 KiB       17       0      51                   0        0         0     236  259 KiB      48   31 KiB         0 B          0 B
kube_zone_node3_hdd                     3.7 GiB     1273       0    3819                   0        0         0    7880  9.5 MiB    4529  1.9 GiB         0 B          0 B
kube_zone_node5_ssd                     7.6 GiB     2629       0    7887                   0        0         0  175810  203 MiB   78828   13 GiB         0 B          0 B
kube_zone_node5_ssd.rgw.buckets.data     17 GiB     1487       0    4461                   0        0         0      80   90 KiB    3883  5.2 GiB         0 B          0 B
kube_zone_node5_ssd.rgw.buckets.index       0 B       11       0      33                   0        0         0    3900  3.0 MiB    1596  804 KiB         0 B          0 B
kube_zone_node5_ssd.rgw.buckets.non-ec      0 B        0       0       0                   0        0         0    2123  1.5 MiB     492  352 KiB         0 B          0 B
kube_zone_node5_ssd.rgw.control             0 B        8       0      24                   0        0         0       0      0 B       0      0 B         0 B          0 B
kube_zone_node5_ssd.rgw.log             2.7 MiB      306       0     918                   0        0         0   13849   14 MiB    7902  416 KiB         0 B          0 B
kube_zone_node5_ssd.rgw.meta             96 KiB       11       0      33                   0        0         0      70   57 KiB      29   13 KiB         0 B          0 B

total_objects    5744
total_used       33 GiB
total_avail      1.0 TiB
total_space      1.1 TiB

```


### Testing block 2


```shell
radosgw-admin --tenant testx --uid tester --display-name "Test User" --access_key TESTER --secret test123 user create
```

```
{
    "user_id": "testx$tester",
    "display_name": "Test User",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "testx$tester",
            "access_key": "TESTER",
            "secret_key": "test123"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
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
radosgw-admin subuser create --tenant testx --uid=tester --subuser=subtester --access=readwrite
```

```
{                                                                                                                                                                                    [2/1977]
    "user_id": "testx$tester",
    "display_name": "Test User",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [
        {
            "id": "testx$tester:subtester",
            "permissions": "read-write"
        }
    ],
    "keys": [
        {
            "user": "testx$tester",
            "access_key": "TESTER",
            "secret_key": "test123"
        }
    ],
    "swift_keys": [
        {
            "user": "testx$tester:subtester",
            "secret_key": "1RHje1k5Kpol0QNohENb2v6vEiIKhg8I8i8JcyE8"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
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
radosgw-admin user info --tenant testx  --uid=tester
```

```
{                                                                                                                                                                                    [2/1977]
    "user_id": "testx$tester",
    "display_name": "Test User",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [
        {
            "id": "testx$tester:subtester",
            "permissions": "read-write"
        }
    ],
    "keys": [
        {
            "user": "testx$tester",
            "access_key": "TESTER",
            "secret_key": "test123"
        }
    ],
    "swift_keys": [
        {
            "user": "testx$tester:subtester",
            "secret_key": "1RHje1k5Kpol0QNohENb2v6vEiIKhg8I8i8JcyE8"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
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
radosgw-admin user info --tenant testx --tenant testx --uid=tester  --gen-access-key --gen-secret
radosgw-admin user modify --tenant testx --tenant testx --uid=tester  --gen-access-key --gen-secret
radosgw-admin key rm --tenant testx --tenant testx --uid=tester --access-key=TESTER
```
```
..........
"keys": [
    {
        "user": "testx$tester",
        "access_key": "DISD7Z4EN0N16Y5XO8GB",
        "secret_key": "x7RVBtSD2l3QP0yEyYP3qlruXNR8AcwdUlGsxj63"
    }
],
..........
```

```shell
mc alias set minio http://192.168.200.140:9000 DISD7Z4EN0N16Y5XO8GB x7RVBtSD2l3QP0yEyYP3qlruXNR8AcwdUlGsxj63
```

```shell
mc ls minio -r
mc mb minio/test-data
mc tree minio
mc ls minio/test-data

mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test-data/test1
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test-data/test2
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/test-data/test3
```

```shell
radosgw-admin user stats --tenant testx --uid=tester --sync-stats
```
```
root@node140:~# radosgw-admin user stats --tenant testx --uid=tester --sync-stats
{
    "stats": {
        "size": 543283788,
        "size_actual": 543285248,
        "size_kb": 530551,
        "size_kb_actual": 530552,
        "num_objects": 9
    },
    "last_stats_sync": "2023-08-26T11:46:54.522897Z",
    "last_stats_update": "2023-08-26T11:46:54.498327Z"
}
```


```shell
radosgw-admin quota enable --quota-scope=user --tenant testx --uid=tester --max-objects=10 --max-size=5368709120
```
```shell
radosgw-admin user info --tenant testx  --uid=tester
```
```
..............
    "user_quota": {
        "enabled": true,
        "check_on_raw": false,
        "max_size": 5368709120,
        "max_size_kb": 5242880,
        "max_objects": 10
    },
..............
```

```shell
root@node140:~# radosgw-admin quota enable --quota-scope=user --tenant testx --uid=tester --max-objects=200 --max-size=9000000000
root@node140:~# radosgw-admin user stats --tenant testx --uid=tester --sync-stats
{
    "stats": {
        "size": 2045330300,
        "size_actual": 2045337600,
        "size_kb": 1997393,
        "size_kb_actual": 1997400,
        "num_objects": 5
    },
    "last_stats_sync": "2023-08-26T11:55:12.667137Z",
    "last_stats_update": "2023-08-26T11:55:12.662130Z"
}

```

