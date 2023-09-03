# STEP ZERO
```
## docker run -it --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash

docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04 bash

docker run -it --rm --hostname ceph-install --name ceph-install -v /var/run/docker.sock:/var/run/docker.sock harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04 bash


```
# STEP 0
```
on all node ceph


apt -y install cgroup-tools cpuset cgroup-lite cgroup-tools cgroupfs-mount sysstat nmon || throw ${LINENO}
sed -i -e 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="cgroup_enable=cpuset cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1"|' /etc/default/grub || throw ${LINENO}
cat /etc/default/grub || throw ${LINENO}
update-grub || throw ${LINENO}
shutdown -r 1 "reboot" || throw ${LINENO}



```
```
export DEBIAN_FRONTEND=noninteractive && \
apt update -y && \
apt install openssh-server sshpass pdsh python3-pip python3 git -y && \
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
EOF

cat <<EOF>hosts
node140
node141
node142
EOF

declare -a arr=( 140 141 142 )
echo 'root' >pass_file
chmod 0400 pass_file
for i in "${arr[@]}"
do
sshpass -f pass_file ssh-copy-id root@node${i}
ssh root@node${i}  "df -h"
done

pdsh -w ^hosts -R ssh 'uptime' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.140 node140" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.141 node141" >> /etc/hosts' && \
pdsh -w ^hosts -R ssh 'echo "192.168.200.142 node142" >> /etc/hosts'

pdsh -w ^hosts -R ssh 'cat /etc/hosts'
pdsh -w ^hosts -R ssh "apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release && apt update" && \
pdsh -w ^hosts -R ssh "apt-get -y install docker.io containerd" && \
pdsh -w ^hosts -R ssh "apt install -y ntpdate && ntpdate -u pool.ntp.org" && \
pdsh -w ^hosts -R ssh "sed -i '/#NTP=/a NTP=time.google.com' /etc/systemd/timesyncd.conf" && \
pdsh -w ^hosts -R ssh "systemctl restart systemd-timesyncd  && timedatectl" && \
pdsh -w ^hosts -R ssh "apt list --installed |grep ^lvm"

# STEP 1

cat <<EOF>host-master
node140
EOF

# pip3 install ceph-deploy
pip3 install git+https://github.com/ceph/ceph-deploy.git

ceph-deploy new node140 node141 node142
ceph-deploy install node140 node141 node142


ceph-deploy install --repo-url https://download.ceph.com/debian-reef/ node140 node141 node142

>>>   --local-mirror [LOCAL_MIRROR]
>>>                        Fetch packages and push them to hosts for a local repo mirror
>>>  --repo-url [REPO_URL]
>>>                        specify a repo URL that mirrors/contains Ceph packages
>>>  --gpg-url [GPG_URL]   specify a GPG key URL to be used with custom repos (defaults to ceph.com)


ceph-deploy mon create-initial
ceph-deploy mon create node140 node141 node142
ceph-deploy mgr create node140 node141 node142
ceph-deploy mds create node140 node141 node142
ceph-deploy admin node140 node141 node142

```

```
root@node140:~# ceph -s
  cluster:
    id:     bf36ffe3-a9b1-4214-8dd7-4c63333bb911
    health: HEALTH_WARN
            mons are allowing insecure global_id reclaim
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 3 daemons, quorum node140,node141,node142 (age 117s)
    mgr: node140(active, since 100s), standbys: node141, node142
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:


```

```


pdsh -w ^host-master -R ssh "ceph config get mon"
pdsh -w ^host-master -R ssh "ceph config get mgr"


pdsh -w ^host-master -R ssh "ceph config set mon public_network 192.168.200.0/24"
pdsh -w ^host-master -R ssh "ceph config set global cluster_network 192.168.201.0/24"

pdsh -w ^host-master -R ssh "ceph config get mon"
pdsh -w ^host-master -R ssh "ceph config get mgr"

pdsh -w ^hosts -R ssh "apt install ceph-volume -y"
pdsh -w ^hosts -R ssh "apt install ceph-mgr-dashboard -y"

for j in node140 node141 node142; do
        ceph-deploy osd create --data /dev/sdb $j
        ceph-deploy osd create --data /dev/sdc $j
        ceph-deploy osd create --data /dev/sdb $j
done

```

```
root@ceph-deploy:/# pdsh -w ^host-master -R ssh "ceph -s"
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140:   cluster:
node140:     id:     bf36ffe3-a9b1-4214-8dd7-4c63333bb911
node140:     health: HEALTH_WARN
node140:             mons are allowing insecure global_id reclaim
node140:
node140:   services:
node140:     mon: 3 daemons, quorum node140,node141,node142 (age 17m)
node140:     mgr: node140(active, since 16m), standbys: node141, node142
node140:     osd: 7 osds: 7 up (since 108s), 7 in (since 118s)
node140:
node140:   data:
node140:     pools:   1 pools, 1 pgs
node140:     objects: 2 objects, 577 KiB
node140:     usage:   187 MiB used, 210 GiB / 210 GiB avail
node140:     pgs:     1 active+clean
node140:

```

```

pdsh -w ^host-master -R ssh "ceph config set mon auth_allow_insecure_global_id_reclaim false"

```

```
root@ceph-deploy:/# pdsh -w ^host-master -R ssh "ceph -s"
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140:   cluster:
node140:     id:     bf36ffe3-a9b1-4214-8dd7-4c63333bb911
node140:     health: HEALTH_OK
node140:
node140:   services:
node140:     mon: 3 daemons, quorum node140,node141,node142 (age 18m)
node140:     mgr: node140(active, since 18m), standbys: node141, node142
node140:     osd: 7 osds: 7 up (since 3m), 7 in (since 3m)
node140:
node140:   data:
node140:     pools:   1 pools, 1 pgs
node140:     objects: 2 objects, 577 KiB
node140:     usage:   187 MiB used, 210 GiB / 210 GiB avail
node140:     pgs:     1 active+clean
node140:
root@ceph-deploy:/# pdsh -w ^host-master -R ssh "ceph osd tree"
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140: ID  CLASS  WEIGHT   TYPE NAME         STATUS  REWEIGHT  PRI-AFF
node140: -1         0.20508  root default
node140: -3         0.08789      host node140
node140:  0    hdd  0.02930          osd.0         up   1.00000  1.00000
node140:  1    hdd  0.02930          osd.1         up   1.00000  1.00000
node140:  2    hdd  0.02930          osd.2         up   1.00000  1.00000
node140: -5         0.05859      host node141
node140:  3    hdd  0.02930          osd.3         up   1.00000  1.00000
node140:  4    hdd  0.02930          osd.4         up   1.00000  1.00000
node140: -7         0.05859      host node142
node140:  5    hdd  0.02930          osd.5         up   1.00000  1.00000
node140:  6    hdd  0.02930          osd.6         up   1.00000  1.00000
root@ceph-deploy:/#

root@node141:~# ceph-volume lvm list


====== osd.3 =======

  [block]       /dev/ceph-ab132bd0-2f4b-41be-b7d3-b44651be3704/osd-block-bbdd385b-5546-4e54-9c8f-7c1dfc766564

      block device              /dev/ceph-ab132bd0-2f4b-41be-b7d3-b44651be3704/osd-block-bbdd385b-5546-4e54-9c8f-7c1dfc766564
      block uuid                L7zemu-MQLr-mDcP-0uMa-7d33-XmED-drPNHi
      cephx lockbox secret
      cluster fsid              bf36ffe3-a9b1-4214-8dd7-4c63333bb911
      cluster name              ceph
      crush device class
      encrypted                 0
      osd fsid                  bbdd385b-5546-4e54-9c8f-7c1dfc766564
      osd id                    3
      osdspec affinity
      type                      block
      vdo                       0
      devices                   /dev/sdb

====== osd.4 =======

  [block]       /dev/ceph-4ee89d9b-ad5d-4e1e-81c3-899707d40dbf/osd-block-77dd7a4a-3fd1-4055-b455-9b57e271d859

      block device              /dev/ceph-4ee89d9b-ad5d-4e1e-81c3-899707d40dbf/osd-block-77dd7a4a-3fd1-4055-b455-9b57e271d859
      block uuid                R7wwCL-FJc4-zsST-rnzJ-8e5L-ZKY6-UrFBGq
      cephx lockbox secret
      cluster fsid              bf36ffe3-a9b1-4214-8dd7-4c63333bb911
      cluster name              ceph
      crush device class
      encrypted                 0
      osd fsid                  77dd7a4a-3fd1-4055-b455-9b57e271d859
      osd id                    4
      osdspec affinity
      type                      block
      vdo                       0
      devices                   /dev/sdc

```

```

pdsh -w ^hosts -R ssh "ceph mgr module enable dashboard"
pdsh -w ^hosts -R ssh "ceph dashboard create-self-signed-cert"
pdsh -w ^hosts -R ssh "echo 'admin' > /root/pass.txt"
pdsh -w ^hosts -R ssh "ceph dashboard ac-user-create admin administrator -i /root/pass.txt"


```


```

root@node140:~# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME         STATUS  REWEIGHT  PRI-AFF
-1         0.26367  root default
-3         0.08789      host node140
 0    hdd  0.02930          osd.0         up   1.00000  1.00000
 1    hdd  0.02930          osd.1         up   1.00000  1.00000
 2    hdd  0.02930          osd.2         up   1.00000  1.00000
-5         0.08789      host node141
 3    hdd  0.02930          osd.3         up   1.00000  1.00000
 4    hdd  0.02930          osd.4         up   1.00000  1.00000
 7    hdd  0.02930          osd.7         up   1.00000  1.00000
-7         0.08789      host node142
 5    hdd  0.02930          osd.5         up   1.00000  1.00000
 6    hdd  0.02930          osd.6         up   1.00000  1.00000
 8    hdd  0.02930          osd.8         up   1.00000  1.00000
root@node140:~# ceph -s
  cluster:
    id:     bf36ffe3-a9b1-4214-8dd7-4c63333bb911
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node141,node142 (age 26m)
    mgr: node140(active, since 104s), standbys: node141, node142
    osd: 9 osds: 9 up (since 3m), 9 in (since 3m)

  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 577 KiB
    usage:   243 MiB used, 270 GiB / 270 GiB avail
    pgs:     1 active+clean

root@node140:~#
```

```
Если, что-то пошло не так в процессе установки, то вы всегда можете удалить все и начать заново:

ceph-deploy purge node140 node141 node142
ceph-deploy purgedata node140 node141 node142
ceph-deploy forgetkeysrm ceph.*
```

```


pdsh -w ^host-master -R ssh "ceph config get mon"
pdsh -w ^host-master -R ssh "ceph config get mgr"

```

```
root@ceph-deploy:/# pdsh -w ^host-master -R ssh "ceph config get mon"
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140: WHO     MASK  LEVEL     OPTION                                 VALUE             RO
node140: mon           advanced  auth_allow_insecure_global_id_reclaim  false
node140: global        advanced  cluster_network                        192.168.201.0/24  *
node140: mon           advanced  public_network                         192.168.200.0/24  *
root@ceph-deploy:/# pdsh -w ^host-master -R ssh "ceph config get mgr"
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140: WHO     MASK  LEVEL     OPTION           VALUE             RO
node140: global        advanced  cluster_network  192.168.201.0/24  *
root@ceph-deploy:/#
```

```

pdsh -w ^host-master -R ssh "ceph mgr module enable prometheus"
pdsh -w ^host-master -R ssh "ceph mgr module enable dashboard"
pdsh -w ^host-master -R ssh "ceph mgr module enable balancer"
pdsh -w ^host-master -R ssh "ceph balancer mode upmap"
pdsh -w ^host-master -R ssh "ceph balancer on"


```

```
pdsh@ceph-deploy: node140: ssh exited with exit code 127
root@ceph-deploy:/# pdsh -w ^host-master -R ssh "ceph -s"
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140:   cluster:
node140:     id:     bf36ffe3-a9b1-4214-8dd7-4c63333bb911
node140:     health: HEALTH_OK
node140:
node140:   services:
node140:     mon: 3 daemons, quorum node140,node141,node142 (age 32m)
node140:     mgr: node140(active, since 38s), standbys: node141, node142
node140:     osd: 9 osds: 9 up (since 8m), 9 in (since 9m)
node140:
node140:   data:
node140:     pools:   1 pools, 1 pgs
node140:     objects: 2 objects, 577 KiB
node140:     usage:   243 MiB used, 270 GiB / 270 GiB avail
node140:     pgs:     1 active+clean
node140:
```

```


pdsh -w ^hosts -R ssh "cephadm ceph-volume lvm list"
sleep 5
pdsh -w ^hosts -R ssh "cephadm ceph-volume lvm list --format json"

```

```shell
pdsh -w ^hosts -R ssh "ceph dashboard ac-user-show"
["admin"]
```


### TESTING

```
ssh node140 "ceph osd pool create kube 128"
ssh node140 "ceph osd pool application enable kube rbd"
ssh node140 "ceph fsid"
ssh node140 "ceph mon dump"

```


```
root@ceph-deploy:/# ssh node140 "ceph osd pool create kube 128"
Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
pool 'kube' created
root@ceph-deploy:/# ssh node140 "ceph osd pool application enable kube rbd"
Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
enabled application 'rbd' on pool 'kube'
root@ceph-deploy:/# ssh node140 "ceph fsid"
Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
bf36ffe3-a9b1-4214-8dd7-4c63333bb911
root@ceph-deploy:/# ssh node140 "ceph mon dump"
Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
epoch 1
fsid bf36ffe3-a9b1-4214-8dd7-4c63333bb911
last_changed 2023-08-31T11:38:51.845653+0500
created 2023-08-31T11:38:51.845653+0500
min_mon_release 18 (reef)
election_strategy: 1
0: [v2:192.168.200.140:3300/0,v1:192.168.200.140:6789/0] mon.node140
1: [v2:192.168.200.141:3300/0,v1:192.168.200.141:6789/0] mon.node141
2: [v2:192.168.200.142:3300/0,v1:192.168.200.142:6789/0] mon.node142
dumped monmap epoch 1
root@ceph-deploy:/# ssh node140 "ceph -s"
Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
  cluster:
    id:     bf36ffe3-a9b1-4214-8dd7-4c63333bb911
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node141,node142 (age 40m)
    mgr: node140(active, since 8m), standbys: node141, node142
    osd: 9 osds: 9 up (since 16m), 9 in (since 16m)

  data:
    pools:   2 pools, 127 pgs
    objects: 2 objects, 577 KiB
    usage:   263 MiB used, 270 GiB / 270 GiB avail
    pgs:     1.575% pgs not active
             125 active+clean
             2   activating

  progress:

root@ceph-deploy:/#


ssh node140 "ceph osd pool ls" && \
ssh node140 "ceph fs volume create kubernetes" && \
ssh node140 "ceph fs ls" && \
ssh node140 "ceph auth get-or-create client.cephfs mon 'allow r' osd 'allow rwx pool=kubernetes'" && \
ssh node140 "ceph auth get client.cephfs"


root@ceph-deploy:/# ssh node140 "ceph auth get client.cephfs"
Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
[client.cephfs]
        key = AQCoP/Bkqnp3HhAAapvQ5knQTHM2dDbQuSATdw==
        caps mon = "allow r"
        caps osd = "allow rwx pool=kubernetes"
root@ceph-deploy:/#


```


```

ceph-deploy rgw create node140 node141 node142
ceph-deploy mds create node140 node141 node142

```

```
.........
[node140][INFO  ] Running command: ceph --cluster ceph --name client.bootstrap-rgw --keyring /var/lib/ceph/bootstrap-rgw/ceph.keyring auth get-or-create client.rgw.node140 osd allow rwx mon allow rw -o /var/lib/ceph/radosgw/ceph-rgw.node140/keyring
[node140][INFO  ] Running command: systemctl enable ceph-radosgw@rgw.node140
[node140][WARNIN] Created symlink /etc/systemd/system/ceph-radosgw.target.wants/ceph-radosgw@rgw.node140.service → /lib/systemd/system/ceph-radosgw@.service.
[node140][INFO  ] Running command: systemctl start ceph-radosgw@rgw.node140
[node140][INFO  ] Running command: systemctl enable ceph.target
[ceph_deploy.rgw][INFO  ] The Ceph Object Gateway (RGW) is now running on host node140 and default port 7480
Warning: Permanently added 'node141,192.168.200.141' (ECDSA) to the list of known hosts.
Warning: Permanently added 'node141,192.168.200.141' (ECDSA) to the list of known hosts.
[node141][DEBUG ] connected to host: node141
[ceph_deploy.rgw][INFO  ] Distro info: ubuntu 22.04 jammy
[ceph_deploy.rgw][DEBUG ] remote host will use systemd
[ceph_deploy.rgw][DEBUG ] deploying rgw bootstrap to node141
[node141][WARNIN] rgw keyring does not exist yet, creating one
[node141][INFO  ] Running command: ceph --cluster ceph --name client.bootstrap-rgw --keyring /var/lib/ceph/bootstrap-rgw/ceph.keyring auth get-or-create client.rgw.node141 osd allow rwx mon allow rw -o /var/lib/ceph/radosgw/ceph-rgw.node141/keyring
[node141][INFO  ] Running command: systemctl enable ceph-radosgw@rgw.node141
[node141][WARNIN] Created symlink /etc/systemd/system/ceph-radosgw.target.wants/ceph-radosgw@rgw.node141.service → /lib/systemd/system/ceph-radosgw@.service.
[node141][INFO  ] Running command: systemctl start ceph-radosgw@rgw.node141
[node141][INFO  ] Running command: systemctl enable ceph.target
[ceph_deploy.rgw][INFO  ] The Ceph Object Gateway (RGW) is now running on host node141 and default port 7480
Warning: Permanently added 'node142,192.168.200.142' (ECDSA) to the list of known hosts.
Warning: Permanently added 'node142,192.168.200.142' (ECDSA) to the list of known hosts.
[node142][DEBUG ] connected to host: node142
[ceph_deploy.rgw][INFO  ] Distro info: ubuntu 22.04 jammy
[ceph_deploy.rgw][DEBUG ] remote host will use systemd
[ceph_deploy.rgw][DEBUG ] deploying rgw bootstrap to node142
[node142][WARNIN] rgw keyring does not exist yet, creating one
[node142][INFO  ] Running command: ceph --cluster ceph --name client.bootstrap-rgw --keyring /var/lib/ceph/bootstrap-rgw/ceph.keyring auth get-or-create client.rgw.node142 osd allow rwx mon allow rw -o /var/lib/ceph/radosgw/ceph-rgw.node142/keyring
[node142][INFO  ] Running command: systemctl enable ceph-radosgw@rgw.node142
[node142][WARNIN] Created symlink /etc/systemd/system/ceph-radosgw.target.wants/ceph-radosgw@rgw.node142.service → /lib/systemd/system/ceph-radosgw@.service.
[node142][INFO  ] Running command: systemctl start ceph-radosgw@rgw.node142
[node142][INFO  ] Running command: systemctl enable ceph.target

```

```

pdsh -w ^host-master -R ssh "ceph osd pool create my-userfiles 64"
pdsh -w ^host-master -R ssh "ceph osd pool set my-userfiles size 2"
pdsh -w ^host-master -R ssh "ceph osd pool set my-userfiles min_size 1"

pdsh -w ^host-master -R ssh 'sudo radosgw-admin user create --uid="my-api" --display-name="My API"'
```

```
root@ceph-deploy:/# pdsh -w ^host-master -R ssh 'sudo radosgw-admin user create --uid="my-api" --display-name="My API"'
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140: {
node140:     "user_id": "my-api",
node140:     "display_name": "My API",
node140:     "email": "",
node140:     "suspended": 0,
node140:     "max_buckets": 1000,
node140:     "subusers": [],
node140:     "keys": [
node140:         {
node140:             "user": "my-api",
node140:             "access_key": "5LF9GNZM5YKQY1W8ANTQ",
node140:             "secret_key": "CyshGGBCA8oW1sSJqaitu1yNoGJFgGEyXaWFyHkb"
node140:         }
node140:     ],
node140:     "swift_keys": [],
node140:     "caps": [],
node140:     "op_mask": "read, write, delete",
node140:     "default_placement": "",
node140:     "default_storage_class": "",
node140:     "placement_tags": [],
node140:     "bucket_quota": {
node140:         "enabled": false,
node140:         "check_on_raw": false,
node140:         "max_size": -1,
node140:         "max_size_kb": 0,
node140:         "max_objects": -1
node140:     },
node140:     "user_quota": {
node140:         "enabled": false,
node140:         "check_on_raw": false,
node140:         "max_size": -1,
node140:         "max_size_kb": 0,
node140:         "max_objects": -1
node140:     },
node140:     "temp_url_keys": [],
node140:     "type": "rgw",
node140:     "mfa_ids": []
node140: }
node140:
root@ceph-deploy:/#
```

```
pdsh -w ^host-master -R ssh 'sudo radosgw-admin caps add --uid="my-api" --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"'
pdsh -w ^host-master -R ssh 'sudo radosgw-admin quota set --uid="my-api" --quota-scope=bucket --max-size=30G'
pdsh -w ^host-master -R ssh 'sudo radosgw-admin quota enable --quota-scope=bucket --uid="my-api"'
```


```
root@ceph-deploy:/# pdsh -w ^host-master -R ssh 'sudo radosgw-admin caps add --uid="my-api" --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"'                                   [19/1834]
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140: {
node140:     "user_id": "my-api",
node140:     "display_name": "My API",
node140:     "email": "",
node140:     "suspended": 0,
node140:     "max_buckets": 1000,
node140:     "subusers": [],
node140:     "keys": [
node140:         {
node140:             "user": "my-api",
node140:             "access_key": "5LF9GNZM5YKQY1W8ANTQ",
node140:             "secret_key": "CyshGGBCA8oW1sSJqaitu1yNoGJFgGEyXaWFyHkb"
node140:         }
node140:     ],
node140:     "swift_keys": [],
node140:     "caps": [
node140:         {
node140:             "type": "buckets",
node140:             "perm": "*"
node140:         },
node140:         {
node140:             "type": "metadata",
node140:             "perm": "*"
node140:         },
node140:         {
node140:             "type": "usage",
node140:             "perm": "*"
node140:         },
node140:         {
node140:             "type": "users",
node140:             "perm": "*"
node140:         },
node140:         {
node140:             "type": "zone",
node140:             "perm": "*"
node140:         }
node140:     ],
node140:     "op_mask": "read, write, delete",
node140:     "default_placement": "",
node140:     "default_storage_class": "",
node140:     "placement_tags": [],
node140:     "bucket_quota": {
node140:         "enabled": false,
node140:         "check_on_raw": false,
node140:         "max_size": -1,
node140:         "max_size_kb": 0,
node140:         "max_objects": -1
node140:     },
node140:     "user_quota": {
node140:         "enabled": false,
node140:         "check_on_raw": false,
node140:         "max_size": -1,
node140:         "max_size_kb": 0,
node140:         "max_objects": -1
node140:     },
node140:     "temp_url_keys": [],
node140:     "type": "rgw",
node140:     "mfa_ids": []
node140: }
node140:

root@node140:~# netstat -napt | grep 7480
tcp        0      0 0.0.0.0:7480            0.0.0.0:*               LISTEN      21802/radosgw
tcp6       0      0 :::7480                 :::*                    LISTEN      21802/radosgw


```

```

docker run -it  --rm harbor.iblog.pro/test/minio:main.mc bash

wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-root.tar.xz
wget https://cloud.debian.org/images/cloud/bookworm/20230802-1460/debian-12-generic-amd64-20230802-1460.qcow2
mc alias set minio http://192.168.200.141:7480 5LF9GNZM5YKQY1W8ANTQ CyshGGBCA8oW1sSJqaitu1yNoGJFgGEyXaWFyHkb
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


```

root@ceph-deploy:/# pdsh -w ^host-master -R ssh 'ceph -s'
node140: Warning: Permanently added 'node140,192.168.200.140' (ECDSA) to the list of known hosts.
node140:   cluster:
node140:     id:     bf36ffe3-a9b1-4214-8dd7-4c63333bb911
node140:     health: HEALTH_OK
node140:
node140:   services:
node140:     mon: 3 daemons, quorum node140,node141,node142 (age 62m)
node140:     mgr: node140(active, since 30m), standbys: node141, node142
node140:     mds: 1/1 daemons up, 2 standby
node140:     osd: 9 osds: 9 up (since 38m), 9 in (since 39m)
node140:     rgw: 3 daemons active (3 hosts, 1 zones)
node140:
node140:   data:
node140:     volumes: 1/1 healthy
node140:     pools:   11 pools, 305 pgs
node140:     objects: 1.10k objects, 3.3 GiB
node140:     usage:   11 GiB used, 259 GiB / 270 GiB avail
node140:     pgs:     305 active+clean
node140:


root@node140:~# ceph df
--- RAW STORAGE ---
CLASS     SIZE    AVAIL    USED  RAW USED  %RAW USED
hdd    270 GiB  258 GiB  12 GiB    12 GiB       4.43
TOTAL  270 GiB  258 GiB  12 GiB    12 GiB       4.43

--- POOLS ---
POOL                        ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                         1    1  577 KiB        2  1.7 MiB      0     81 GiB
kube                         2   32      0 B        0      0 B      0     81 GiB
cephfs.kubernetes.meta       3   16  2.3 KiB       22   96 KiB      0     81 GiB
cephfs.kubernetes.data       4   32      0 B        0      0 B      0     81 GiB
.rgw.root                    5   32  2.6 KiB        6   72 KiB      0     81 GiB
default.rgw.log              6   32   32 KiB      177  504 KiB      0     81 GiB
default.rgw.control          7   32      0 B        8      0 B      0     81 GiB
default.rgw.meta             8   32    958 B        5   48 KiB      0     81 GiB
default.rgw.buckets.index    9   32      0 B       11      0 B      0     81 GiB
default.rgw.buckets.data    10   32  3.7 GiB      961   11 GiB   4.38     81 GiB
default.rgw.buckets.non-ec  11   32      0 B        0      0 B      0     81 GiB

```
