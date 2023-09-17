


### init S3
```shell
ssh root@192.168.200.140 "ceph orch apply rgw cloud"
ssh root@192.168.200.140 "ceph orch apply rgw cloud --port=8060"
ssh root@192.168.200.140 "ceph orch apply rgw cloud '--placement=label:rgw count-per-host:1' --port=8060"

```


```
root@ceph-install:/# ssh root@192.168.200.140 "ceph orch ps"
............
rgw.cloud.node140.qltrvq          node140  *:8060            running (35s)     17s ago   35s    82.0M        -  18.2.0   e0db6e7ec3f1  a79634ebdcf3
rgw.cloud.node141.hpoktj          node141  *:8060            running (36s)     17s ago   36s    82.0M        -  18.2.0   e0db6e7ec3f1  d5eef34e3d25
rgw.cloud.node142.gmitis          node142  *:8060            running (37s)     17s ago   37s    82.1M        -  18.2.0   e0db6e7ec3f1  ad0fcd5c918b
```


####


```shell
ssh root@192.168.200.140 'radosgw-admin user create --uid=vorlon --display-name="vorlon" --email=vorlon@iblog.pro'
ssh root@192.168.200.140 'radosgw-admin caps add --uid=vorlon --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"'
```

```
    "keys": [
        {
            "user": "vorlon",
            "access_key": "FZ432GUW1DAW68ELZ6IX",
            "secret_key": "bRx9kXARJnU8DKVsXoh9R3mdBlXKZbtxU2xGz5Be"
        }
    ],
    "swift_keys": [],

```

```shell
cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: Secret
metadata:
  name: csi-s3-secret
  namespace: kube-system
stringData:
  accessKeyID: FZ432GUW1DAW68ELZ6IX
  secretAccessKey: bRx9kXARJnU8DKVsXoh9R3mdBlXKZbtxU2xGz5Be
  endpoint: http://192.168.200.142:8060
EOF
```

https://github.com/yandex-cloud/k8s-csi-s3/tree/master

```shell
kubectl apply --filename https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/master/deploy/kubernetes/provisioner.yaml
kubectl apply --filename https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/master/deploy/kubernetes/driver.yaml
kubectl apply --filename https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/master/deploy/kubernetes/csi-s3.yaml
kubectl apply --filename https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/master/deploy/kubernetes/examples/storageclass.yaml
```


```shell

root@node180:~# kubectl get StorageClass
NAME            PROVISIONER           RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
csi-cephfs-sc   cephfs.csi.ceph.com   Delete          Immediate           true                   53m
csi-rbd-sc      rbd.csi.ceph.com      Delete          Immediate           true                   69m
csi-s3          ru.yandex.s3.csi      Delete          Immediate           false                  7s



cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-s3-pvc
  namespace: default
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: csi-s3
EOF

```

```shell

root@node180:~# kubectl get pvc
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
cephfs-pvc-test     Bound    pvc-4841844a-98ae-4602-955c-dc2f4616bea5   3Gi        RWO            csi-cephfs-sc   39m
cephfs-pvc-test-2   Bound    pvc-0f313ba4-1dfc-4507-8e59-ec71592132f3   3Gi        RWX            csi-cephfs-sc   29m
csi-s3-pvc          Bound    pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a   5Gi        RWX            csi-s3          11s
rbd-pvc-test        Bound    pvc-c7718d6a-9f39-417a-8851-8cd9116b8358   1Gi        RWO            csi-rbd-sc      68m
rbd-pvc-test-2      Bound    pvc-07f25877-dfef-4b57-840c-2d582714e7ff   5Gi        RWO            csi-rbd-sc      52m

```

```shell

cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: Pod
metadata:
  name: csi-s3-test-nginx
  namespace: default
spec:
  containers:
   - name: csi-s3-test-nginx
     image: nexus3-docker-io.iblog.pro/library/nginx:1.23
     volumeMounts:
       - mountPath: /usr/share/nginx/html/s3
         name: webroot
  volumes:
   - name: webroot
     persistentVolumeClaim:
       claimName: csi-s3-pvc
       readOnly: false
EOF


root@node180:~# kubectl get pvc,pod
NAME                                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
persistentvolumeclaim/cephfs-pvc-test     Bound    pvc-4841844a-98ae-4602-955c-dc2f4616bea5   3Gi        RWO            csi-cephfs-sc   40m
persistentvolumeclaim/cephfs-pvc-test-2   Bound    pvc-0f313ba4-1dfc-4507-8e59-ec71592132f3   3Gi        RWX            csi-cephfs-sc   30m
persistentvolumeclaim/csi-s3-pvc          Bound    pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a   5Gi        RWX            csi-s3          79s
persistentvolumeclaim/rbd-pvc-test        Bound    pvc-c7718d6a-9f39-417a-8851-8cd9116b8358   1Gi        RWO            csi-rbd-sc      69m
persistentvolumeclaim/rbd-pvc-test-2      Bound    pvc-07f25877-dfef-4b57-840c-2d582714e7ff   5Gi        RWO            csi-rbd-sc      53m

NAME                    READY   STATUS    RESTARTS   AGE
pod/csi-s3-test-nginx   1/1     Running   0          7s


root@node180:~# kubectl exec -it csi-s3-test-nginx bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@csi-s3-test-nginx:/# df -h
Filesystem                                Size  Used Avail Use% Mounted on
overlay                                    29G  8.3G   21G  29% /
tmpfs                                      64M     0   64M   0% /dev
tmpfs                                     3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/sda1                                  29G  8.3G   21G  29% /etc/hosts
shm                                        64M     0   64M   0% /dev/shm
pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a  1.0P     0  1.0P   0% /usr/share/nginx/html/s3
tmpfs                                     7.8G   12K  7.8G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                                     3.9G     0  3.9G   0% /proc/acpi
tmpfs                                     3.9G     0  3.9G   0% /proc/scsi
tmpfs                                     3.9G     0  3.9G   0% /sys/firmware
root@csi-s3-test-nginx:/#


root@csi-s3-test-nginx:/usr/share/nginx/html/s3# head -c 1000000000 /dev/random | base64 > rand3.txt
root@csi-s3-test-nginx:/usr/share/nginx/html/s3# df -h
Filesystem                                Size  Used Avail Use% Mounted on
overlay                                    29G  8.3G   21G  29% /
tmpfs                                      64M     0   64M   0% /dev
tmpfs                                     3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/sda1                                  29G  8.3G   21G  29% /etc/hosts
shm                                        64M     0   64M   0% /dev/shm
pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a  1.0P     0  1.0P   0% /usr/share/nginx/html/s3
tmpfs                                     7.8G   12K  7.8G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                                     3.9G     0  3.9G   0% /proc/acpi
tmpfs                                     3.9G     0  3.9G   0% /proc/scsi
tmpfs                                     3.9G     0  3.9G   0% /sys/firmware
root@csi-s3-test-nginx:/usr/share/nginx/html/s3# ls -la
total 1319225
drwxrwxrwx 2 root root       4096 Aug 25 21:00 .
drwxr-xr-x 1 root root       4096 Aug 25 20:58 ..
-rw-rw-rw- 1 root root 1350877196 Aug 25 21:02 rand3.txt


```


#### test in minio

```
root@node1:/KVM/init.kube.24.hardway# docker run -it  --rm harbor.iblog.pro/test/minio:main.mc bash
0594846d4cf6:/#


wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-root.tar.xz
mc alias set minio http://192.168.200.142:8060 FZ432GUW1DAW68ELZ6IX bRx9kXARJnU8DKVsXoh9R3mdBlXKZbtxU2xGz5Be
mc alias rm gcs; mc alias rm local; mc alias rm local; mc alias rm play; mc alias rm s3

			
mc ls minio
mc ls minio/pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a/

mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a/jammy-server-cloudimg-amd64-root.tar.xz
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a/jammy-server-cloudimg-amd64-root-2.tar.xz
mc cp jammy-server-cloudimg-amd64-root.tar.xz minio/pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a/test/jammy-server-cloudimg-amd64-root.tar.xz

0594846d4cf6:/# mc ls minio/pvc-1aef54e0-c4be-44c0-8e60-52580d913b4a/
[2023-08-25 21:06:28 UTC] 390MiB STANDARD jammy-server-cloudimg-amd64-root-2.tar.xz
[2023-08-25 21:06:23 UTC] 390MiB STANDARD jammy-server-cloudimg-amd64-root.tar.xz
[2023-08-25 21:02:14 UTC] 1.3GiB STANDARD rand3.txt
[2023-08-25 21:06:39 UTC]     0B test/



ssh root@192.168.200.140 'ceph pg dump osds'
OSD_STAT  USED      AVAIL    USED_RAW  TOTAL    HB_PEERS           PG_SUM  PRIMARY_PG_SUM
8         1014 MiB   29 GiB  1014 MiB   30 GiB  [0,1,2,3,4,5,6,7]      94              28
7          1.1 GiB   29 GiB   1.1 GiB   30 GiB  [0,1,2,3,4,5,6,8]     112              45
6          867 MiB   29 GiB   867 MiB   30 GiB  [0,1,2,3,4,5,7,8]      90              32
1          1.3 GiB   29 GiB   1.3 GiB   30 GiB  [0,2,3,4,5,6,7,8]      96              34
0          1.4 GiB   29 GiB   1.4 GiB   30 GiB  [1,2,3,4,5,6,7,8]     101              33
2          1.0 GiB   29 GiB   1.0 GiB   30 GiB  [0,1,3,4,5,6,7,8]     103              26
3          1.0 GiB   29 GiB   1.0 GiB   30 GiB  [0,1,2,4,5,6,7,8]     114              40
4          865 MiB   29 GiB   865 MiB   30 GiB  [0,1,2,3,5,6,7,8]      97              27
5          1.3 GiB   29 GiB   1.3 GiB   30 GiB  [0,1,2,3,4,6,7,8]     108              40
sum        9.9 GiB  260 GiB   9.9 GiB  270 GiB
dumped osds


root@ceph-install:/# ssh root@192.168.200.140 'ceph osd tree'
ID  CLASS  WEIGHT   TYPE NAME         STATUS  REWEIGHT  PRI-AFF
-1         0.26367  root default
-3         0.08789      host node140
 0    hdd  0.02930          osd.0         up   1.00000  1.00000
 3    hdd  0.02930          osd.3         up   1.00000  1.00000
 6    hdd  0.02930          osd.6         up   1.00000  1.00000
-5         0.08789      host node141
 1    hdd  0.02930          osd.1         up   1.00000  1.00000
 4    hdd  0.02930          osd.4         up   1.00000  1.00000
 7    hdd  0.02930          osd.7         up   1.00000  1.00000
-7         0.08789      host node142
 2    hdd  0.02930          osd.2         up   1.00000  1.00000
 5    hdd  0.02930          osd.5         up   1.00000  1.00000
 8    hdd  0.02930          osd.8         up   1.00000  1.00000



root@ceph-install:/# ssh root@192.168.200.140 'ceph df'
--- RAW STORAGE ---
CLASS     SIZE    AVAIL     USED  RAW USED  %RAW USED
hdd    270 GiB  260 GiB  9.9 GiB   9.9 GiB       3.65
TOTAL  270 GiB  260 GiB  9.9 GiB   9.9 GiB       3.65

--- POOLS ---
POOL                        ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                         1    1  1.1 MiB        2  3.4 MiB      0     81 GiB
kube                         2   32  156 MiB       76  468 MiB   0.19     81 GiB
cephfs.kubernetes.meta       3   16  221 KiB       26  756 KiB      0     81 GiB
cephfs.kubernetes.data       4   32    670 B        2   24 KiB      0     81 GiB
.rgw.root                    5   32  2.6 KiB        6   72 KiB      0     81 GiB
default.rgw.log              6   32   38 KiB      177  540 KiB      0     81 GiB
default.rgw.control          7   32      0 B        8      0 B      0     81 GiB
default.rgw.meta             8   32  1.4 KiB        9   84 KiB      0     81 GiB
default.rgw.buckets.index    9   32      0 B       11      0 B      0     81 GiB
default.rgw.buckets.data    10   32  2.7 GiB      944  8.2 GiB   3.24     81 GiB
default.rgw.buckets.non-ec  11   32      0 B        0      0 B      0     81 GiB
root@ceph-install:/#

root@ceph-install:/# ssh root@192.168.200.140 'ceph -s'
  cluster:
    id:     025b1176-4379-11ee-8726-5da9d31147f4
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 2h)
    mgr: node140.jjnhmw(active, since 2h), standbys: node141.nqlfjz, node142.gzgmsg
    mds: 1/1 daemons up, 1 standby
    osd: 9 osds: 9 up (since 112m), 9 in (since 112m)
    rgw: 6 daemons active (3 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   11 pools, 305 pgs
    objects: 1.26k objects, 2.9 GiB
    usage:   9.9 GiB used, 260 GiB / 270 GiB avail
    pgs:     305 active+clean

root@ceph-install:/#
```

```shell
root@node180:~# kubectl exec -it csi-s3-test-nginx bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@csi-s3-test-nginx:/# cd /usr/share/nginx/html/s3
root@csi-s3-test-nginx:/usr/share/nginx/html/s3# ls -la
total 2118187
drwxrwxrwx 2 root root       4096 Aug 25 21:02 .
drwxr-xr-x 1 root root       4096 Aug 25 20:58 ..
-rw-rw-rw- 1 root root  409066060 Aug 25 21:06 jammy-server-cloudimg-amd64-root-2.tar.xz
-rw-rw-rw- 1 root root  409066060 Aug 25 21:06 jammy-server-cloudimg-amd64-root.tar.xz
-rw-rw-rw- 1 root root 1350877196 Aug 25 21:02 rand3.txt
drwxrwxrwx 2 root root       4096 Aug 25 21:06 test
root@csi-s3-test-nginx:/usr/share/nginx/html/s3#
```
