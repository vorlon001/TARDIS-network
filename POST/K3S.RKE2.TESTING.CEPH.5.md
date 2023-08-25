

### RBD CSI TEST

```shell
ssh root@192.168.200.140 "ceph osd pool create kube 128"
```

```
pool 'kube' created
```

```shell
ssh root@192.168.200.140 "ceph osd pool application enable kube rbd"
```

```
enabled application 'rbd' on pool 'kube'
```

#### так мы узнаем clusterID
```shell
ssh root@192.168.200.140 "ceph fsid"
ssh root@192.168.200.140 "ceph mon dump"
```


```shell

root@ceph-install:/# ssh root@192.168.200.140 "ceph fsid"
025b1176-4379-11ee-8726-5da9d31147f4
root@ceph-install:/#

root@ceph-install:/# ssh root@192.168.200.140 "ceph mon dump"
epoch 3
fsid 025b1176-4379-11ee-8726-5da9d31147f4
last_changed 2023-08-25T19:07:08.101989+0000
created 2023-08-25T18:56:51.406478+0000
min_mon_release 18 (reef)
election_strategy: 1
0: [v2:192.168.200.140:3300/0,v1:192.168.200.140:6789/0] mon.node140
1: [v2:192.168.200.142:3300/0,v1:192.168.200.142:6789/0] mon.node142
2: [v2:192.168.200.141:3300/0,v1:192.168.200.141:6789/0] mon.node141
dumped monmap epoch 3
root@ceph-install:/#

```

```shell
ssh root@192.168.200.140 "ceph auth get-or-create client.rbdkube mon 'profile rbd' osd 'profile rbd pool=kube'"
```

```
[client.rbdkube]
        key = AQCtAelkvY3AJxAAP0SioSx9jPmm9j55mkB6XA==
```

```shell
ssh root@192.168.200.140 "ceph auth get-key client.rbdkube"
```

```
AQCtAelkvY3AJxAAP0SioSx9jPmm9j55mkB6XA==
```


#### on K8S Master node180
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

```shell
helm repo add ceph-csi https://ceph.github.io/csi-charts
helm repo update
helm inspect values ceph-csi/ceph-csi-rbd > cephrbd.yml
```

edit cephrbd.yml
```yaml
csiConfig:
  - clusterID: "025b1176-4379-11ee-8726-5da9d31147f4"
    monitors:
      - "v2:192.168.200.140:3300/0,v1:192.168.200.140:6789/0"
      - "v2:192.168.200.142:3300/0,v1:192.168.200.142:6789/0"
      - "v2:192.168.200.141:3300/0,v1:192.168.200.141:6789/0"


nodeplugin:
  registrar:
    image:
      repository: registry.k8s.io/sig-storage/csi-node-driver-registrar
      tag: v2.8.0

provisioner:
  provisioner:
    image:
      repository: gcr.io/k8s-staging-sig-storage/csi-provisioner
      tag: v3.5.0
 attacher:
    image:
      repository: registry.k8s.io/sig-storage/csi-attacher
      tag: v4.3.0
  resizer:
    name: resizer
    enabled: true
    image:
      repository: registry.k8s.io/sig-storage/csi-resizer
      tag: v1.8.0
  snapshotter:
    image:
      repository: registry.k8s.io/sig-storage/csi-snapshotter
      tag: v6.2.2

# csiConfig: []
```


```shell
helm upgrade -i ceph-csi-rbd ceph-csi/ceph-csi-rbd -f cephrbd.yml -n ceph-csi-rbd --create-namespace
```

```shell
cat <<EOF > /root/csi-fs-secret.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: csi-rbd-secret
  namespace: ceph-csi-rbd
stringData:
  userID: rbdkube
  userKey: AQCtAelkvY3AJxAAP0SioSx9jPmm9j55mkB6XA==
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: csi-rbd-sc
provisioner: rbd.csi.ceph.com
parameters:
   clusterID: "025b1176-4379-11ee-8726-5da9d31147f4"
   pool: kube
   fsName: kubernetes
   imageFeatures: layering
   csi.storage.k8s.io/provisioner-secret-name: csi-rbd-secret
   csi.storage.k8s.io/provisioner-secret-namespace: ceph-csi-rbd
   csi.storage.k8s.io/controller-expand-secret-name: csi-rbd-secret
   csi.storage.k8s.io/controller-expand-secret-namespace: ceph-csi-rbd
   csi.storage.k8s.io/node-stage-secret-name: csi-rbd-secret
   csi.storage.k8s.io/node-stage-secret-namespace: ceph-csi-rbd

   csi.storage.k8s.io/fstype: ext4

reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
  - discard
EOF

kubectl apply -f /root/csi-fs-secret.yaml
```


```shell
cat <<EOF > /root/fs-demo.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rbd-pvc-test
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: csi-rbd-sc
EOF

kubectl apply -f /root/fs-demo.yaml
```


```shell
kubectl get pvc -A -o wide
```

```shell
root@node180:~# kubectl get pvc -A -o wide
NAMESPACE   NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
default     rbd-pvc-test   Bound    pvc-c7718d6a-9f39-417a-8851-8cd9116b8358   1Gi        RWO            csi-rbd-sc     35s   Filesystem
```


https://sabaini.at/pages/ceph-cheatsheet.html

```shell
root@node140:~# rados -p kube ls
rbd_header.5e96563acf63
csi.volume.285afd50-e6df-4f6e-ab27-fbfb24d30bb7
rbd_directory
rbd_id.csi-vol-285afd50-e6df-4f6e-ab27-fbfb24d30bb7
rbd_info
csi.volumes.default

```

```shell
cat <<EOF > /root/fs-demo-rbd-2.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rbd-pvc-test-2
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: csi-rbd-sc
EOF
```

```shell
kubectl apply -f /root/fs-demo-rbd-2.yaml
```

```shell
root@node180:~# kubectl get pvc -A -o wide
NAMESPACE   NAME              STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE   VOLUMEMODE
default     rbd-pvc-test      Bound     pvc-c7718d6a-9f39-417a-8851-8cd9116b8358   1Gi        RWO            csi-rbd-sc      15m   Filesystem
default     rbd-pvc-test-2    Bound     pvc-07f25877-dfef-4b57-840c-2d582714e7ff   5Gi        RWO            csi-rbd-sc      3s    Filesystem
```

```shell
root@ceph-install:/# ssh root@192.168.200.140 "rados -p kube ls"
rbd_header.5e96563acf63
csi.volume.285afd50-e6df-4f6e-ab27-fbfb24d30bb7
rbd_id.csi-vol-88cb0406-5257-4eca-bd05-6f5712d2bdf6
rbd_directory
rbd_header.5e96eda0a3ab
rbd_id.csi-vol-285afd50-e6df-4f6e-ab27-fbfb24d30bb7
rbd_info
csi.volumes.default
csi.volume.88cb0406-5257-4eca-bd05-6f5712d2bdf6

root@ceph-install:/# ssh root@192.168.200.140 "ceph -s"
  cluster:
    id:     025b1176-4379-11ee-8726-5da9d31147f4
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 58m)
    mgr: node140.jjnhmw(active, since 67m), standbys: node141.nqlfjz, node142.gzgmsg
    mds: 1/1 daemons up, 1 standby
    osd: 9 osds: 9 up (since 51m), 9 in (since 51m)

  data:
    volumes: 1/1 healthy
    pools:   4 pools, 81 pgs
    objects: 33 objects, 579 KiB
    usage:   649 MiB used, 269 GiB / 270 GiB avail
    pgs:     81 active+clean

root@ceph-install:/#

```



### CEPHFS CSI TEST


```shell
root@ceph-install:/# ssh root@192.168.200.140 "ceph osd pool ls"
.mgr
kube
cephfs.kubernetes.meta
cephfs.kubernetes.data

```

```shell
root@ceph-install:/# ssh root@192.168.200.140 "ceph fsid"
025b1176-4379-11ee-8726-5da9d31147f4
root@ceph-install:/#

root@ceph-install:/# ssh root@192.168.200.140 "ceph mon dump"
epoch 3
fsid 025b1176-4379-11ee-8726-5da9d31147f4
last_changed 2023-08-25T19:07:08.101989+0000
created 2023-08-25T18:56:51.406478+0000
min_mon_release 18 (reef)
election_strategy: 1
0: [v2:192.168.200.140:3300/0,v1:192.168.200.140:6789/0] mon.node140
1: [v2:192.168.200.142:3300/0,v1:192.168.200.142:6789/0] mon.node142
2: [v2:192.168.200.141:3300/0,v1:192.168.200.141:6789/0] mon.node141
dumped monmap epoch 3
root@ceph-install:/#

```

#### create cephfs
```shell
ssh root@192.168.200.140 "ceph fs volume create kubernetes"
ssh root@192.168.200.140 "ceph fs ls"
```

```
name: kubernetes, metadata pool: cephfs.kubernetes.meta, data pools: [cephfs.kubernetes.data ]
```

```shell
ssh root@192.168.200.140 "ceph auth get-or-create client.cephfs mon 'allow r' osd 'allow rwx pool=kubernetes'"
ssh root@192.168.200.140 "ceph auth get client.cephfs"
```

```shell
root@ceph-install:/# ssh root@192.168.200.140 "ceph auth get client.cephfs"
[client.cephfs]
        key = AQCqBulk3P/PAxAAcQkRZDWbtH1kzrGbevZPBw==
        caps mon = "allow r"
        caps osd = "allow rwx pool=kubernetes"
```


#### on master node180
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

```shell
helm repo add ceph-csi https://ceph.github.io/csi-charts
helm repo update
helm inspect values ceph-csi/ceph-csi-cephfs > cephfs.yml
```

edit cephfs.yml
```yaml
csiConfig:
  - clusterID: "025b1176-4379-11ee-8726-5da9d31147f4"
    monitors:
      - "v2:192.168.200.140:3300/0,v1:192.168.200.140:6789/0"
      - "v2:192.168.200.142:3300/0,v1:192.168.200.142:6789/0"
      - "v2:192.168.200.141:3300/0,v1:192.168.200.141:6789/0"
# csiConfig: []
```

```shell
helm upgrade -i ceph-csi-cephfs ceph-csi/ceph-csi-cephfs -f cephfs.yml -n ceph-csi-cephfs --create-namespace
```

```shell
ssh root@192.168.200.140 "ceph auth get-or-create client.fs mon 'allow r' mgr 'allow rw' mds 'allow rws' osd 'allow rw pool=cephfs.kubernetes.meta, allow rw pool=cephfs.kubernetes.data'"
ssh root@192.168.200.140 "ceph auth get-key client.fs"
```

```
[client.fs]
        key = AQBADOlka0FmHBAAjEFAl222EaFf+NY8HpORXw==
```

```shell
cat <<EOF > /root/fs-secret-2.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: csi-cephfs-secret
  namespace: ceph-csi-cephfs 
stringData:
  adminID: fs
  adminKey: AQBADOlka0FmHBAAjEFAl222EaFf+NY8HpORXw==
EOF
cat <<EOF > /root/fs-StorageClass-2.yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-cephfs-sc
provisioner: cephfs.csi.ceph.com
parameters:
  clusterID: "025b1176-4379-11ee-8726-5da9d31147f4"
  # Имя файловой системы CephFS, в которой будет создан том
  fsName: kubernetes
  # (необязательно) Пул Ceph, в котором будут храниться данные тома
  # pool: cephfs_data
  # (необязательно) Разделенные запятыми опции монтирования для Ceph-fuse
  # например:
  # fuseMountOptions: debug

  # (необязательно) Разделенные запятыми опции монтирования CephFS для ядра
  # См. man mount.ceph чтобы узнать список этих опций. Например:
  # kernelMountOptions: readdir_max_bytes=1048576,norbytes

  # Секреты должны содержать доступы для админа и/или юзера Ceph.
  csi.storage.k8s.io/provisioner-secret-name: csi-cephfs-secret
  # Секреты должны содержать доступы для админа и/или юзера Ceph.
  csi.storage.k8s.io/provisioner-secret-name: csi-cephfs-secret
  csi.storage.k8s.io/provisioner-secret-namespace: ceph-csi-cephfs
  csi.storage.k8s.io/controller-expand-secret-name: csi-cephfs-secret
  csi.storage.k8s.io/controller-expand-secret-namespace: ceph-csi-cephfs
  csi.storage.k8s.io/node-stage-secret-name: csi-cephfs-secret
  csi.storage.k8s.io/node-stage-secret-namespace: ceph-csi-cephfs

  # (необязательно) Драйвер может использовать либо ceph-fuse (fuse),
  # либо ceph kernelclient (kernel).
  # Если не указано, будет использоваться монтирование томов по умолчанию,
  # это определяется поиском ceph-fuse и mount.ceph
  # mounter: kernel
reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
  - debug
EOF

kubectl apply -f  /root/fs-secret-2.yaml
kubectl apply -f /root/fs-StorageClass-2.yaml
```




```shell
cat <<EOF > /root/fs-demo-cephfs.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cephfs-pvc-test
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
  storageClassName: csi-cephfs-sc
EOF

kubectl apply -f /root/fs-demo-cephfs.yaml
```


```shell
kubectl get pvc -A -o wide
```

```shell
root@node180:~# kubectl get pvc -o wide
NAME              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE   VOLUMEMODE
cephfs-pvc-test   Bound    pvc-4841844a-98ae-4602-955c-dc2f4616bea5   3Gi        RWO            csi-cephfs-sc   14s   Filesystem
```


```shell
cat <<EOF > /root/fs-demo-cephfs-2.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cephfs-pvc-test-2
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 3Gi
  storageClassName: csi-cephfs-sc
EOF

kubectl apply -f /root/fs-demo-cephfs-2.yaml
kubectl get pvc -A -o wide
```



#### CEPH CSI Teasting Deploy


```shell
mkdir /root/cephfs

cat <<EOF > /root/cephfs/01-namespace.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: test-kube-0
EOF


cat <<EOF > /root/cephfs/02.mysql.1.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql80
  namespace: test-kube-0
spec:
  selector:
    matchLabels:
      app: mysql80
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql80
    spec:
      containers:
      - image: nexus3-docker-io.iblog.pro/library/mysql:8.0.24
        name: mysql80
        env:
          # Use secret in real usage
        - name: MYSQL_ROOT_PASSWORD
          value: password
        ports:
        - containerPort: 3306
          name: mysql80
        volumeMounts:
        - name: mysql80-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql80-persistent-storage
        persistentVolumeClaim:
          claimName: mysql80-pv-volume2
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql80-pv-volume2
  namespace: test-kube-0
spec:
  storageClassName: csi-rbd-sc
  accessModes: [ "ReadWriteOnce" ]
  resources:
    requests:
      storage: 4Gi
---
apiVersion: v1
kind: Service
metadata:
  name: mysql80oadbalancer
  namespace: test-kube-0
spec:
  selector:
    app: mysql80
  ports:
  - protocol: "TCP"
    port: 3306
    targetPort: 3306
  type: LoadBalancer
---
apiVersion: v1
kind: Service
metadata:
  name: mysql80nodeport
  namespace: test-kube-0
spec:
  selector:
    app: mysql80
  ports:
  - protocol: "TCP"
    port: 3306
    targetPort: 3306
  type: NodePort
EOF

cat <<EOF > /root/cephfs/04.test-part10.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kyverno-test-07-claim3
  namespace: test-kube-0
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: csi-rbd-sc
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web10
  namespace: test-kube-0
  labels:
    opa: antiaffinity-all-nodes
spec:
  selector:
    matchLabels:
      app: nginx # has to match .spec.template.metadata.labels
  serviceName: "nginx"
  replicas: 1
  template:
    metadata:
      labels:
        opa: antiaffinity-all-nodes
        app: nginx # has to match .spec.selector.matchLabels
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: nexus3-docker-io.iblog.pro/library/nginx:1.23
        ports:
        - containerPort: 80
          name: web10
        resources:
          limits:
            cpu: "0.2"
            memory: "300Mi"
          requests:
            cpu: "0.1"
            memory: "100Mi"
        ports:
          - containerPort: 80
            name: http
            protocol: TCP
        volumeMounts:
          - name: pvc-sample
            mountPath: /var/log/nfs
      volumes:
        - name: pvc-sample
          persistentVolumeClaim:
            claimName: kyverno-test-07-claim3
EOF

kubectl apply -f /root/cephfs/01-namespace.yaml
kubectl apply -f /root/cephfs/02.mysql.1.yaml
kubectl apply -f /root/cephfs/04.test-part10.yaml
```


```shell
root@node180:~/cephfs# kubectl get all,pvc -o wide -n test-kube-0
NAME                           READY   STATUS    RESTARTS   AGE     IP           NODE      NOMINATED NODE   READINESS GATES
pod/mysql80-785c45d59f-nvnxg   1/1     Running   0          5m50s   10.42.2.80   node170   <none>           <none>
pod/web10-0                    1/1     Running   0          2m14s   10.42.2.10   node170   <none>           <none>

NAME                         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE   SELECTOR
service/mysql80nodeport      NodePort       10.43.37.150   <none>        3306:32378/TCP   7m    app=mysql80
service/mysql80oadbalancer   LoadBalancer   10.43.37.173   <pending>     3306:31331/TCP   7m    app=mysql80

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                                            SELECTOR
deployment.apps/mysql80   1/1     1            1           7m    mysql80      nexus3-docker-io.iblog.pro/library/mysql:8.0.24   app=mysql80

NAME                                 DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES                                            SELECTOR
replicaset.apps/mysql80-6cb8bdc7bc   0         0         0       7m      mysql80      nexus3-docker-io.iblog.pro/mysql:8.0.24           app=mysql80,pod-template-hash=6cb8bdc7bc
replicaset.apps/mysql80-785c45d59f   1         1         1       5m50s   mysql80      nexus3-docker-io.iblog.pro/library/mysql:8.0.24   app=mysql80,pod-template-hash=785c45d59f

NAME                     READY   AGE     CONTAINERS   IMAGES
statefulset.apps/web10   1/1     2m14s   nginx        nexus3-docker-io.iblog.pro/library/nginx:1.23

NAME                                           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE     VOLUMEMODE
persistentvolumeclaim/kyverno-test-07-claim3   Bound    pvc-4b2c37a4-7aeb-4b33-982e-7df77b83a467   1Gi        RWO            csi-rbd-sc     6m59s   Filesystem
persistentvolumeclaim/mysql80-pv-volume2       Bound    pvc-046c5e38-9caf-412e-b4c3-4ab9430466a9   4Gi        RWO            csi-rbd-sc     7m      Filesystem

```



#### Done!

```shell

root@node180:~# kubectl get pvc -A -o wide
NAMESPACE     NAME                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE     VOLUMEMODE
default       cephfs-pvc-test          Bound    pvc-4841844a-98ae-4602-955c-dc2f4616bea5   3Gi        RWO            csi-cephfs-sc   18m     Filesystem
default       cephfs-pvc-test-2        Bound    pvc-0f313ba4-1dfc-4507-8e59-ec71592132f3   3Gi        RWX            csi-cephfs-sc   8m31s   Filesystem
default       rbd-pvc-test             Bound    pvc-c7718d6a-9f39-417a-8851-8cd9116b8358   1Gi        RWO            csi-rbd-sc      47m     Filesystem
default       rbd-pvc-test-2           Bound    pvc-07f25877-dfef-4b57-840c-2d582714e7ff   5Gi        RWO            csi-rbd-sc      31m     Filesystem
test-kube-0   kyverno-test-07-claim3   Bound    pvc-4b2c37a4-7aeb-4b33-982e-7df77b83a467   1Gi        RWO            csi-rbd-sc      16m     Filesystem
test-kube-0   mysql80-pv-volume2       Bound    pvc-046c5e38-9caf-412e-b4c3-4ab9430466a9   4Gi        RWO            csi-rbd-sc      16m     Filesystem


root@ceph-install:/# ssh root@192.168.200.140 "ceph -s"
  cluster:
    id:     025b1176-4379-11ee-8726-5da9d31147f4
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node140,node142,node141 (age 90m)
    mgr: node140.jjnhmw(active, since 98m), standbys: node141.nqlfjz, node142.gzgmsg
    mds: 1/1 daemons up, 1 standby
    osd: 9 osds: 9 up (since 82m), 9 in (since 82m)

  data:
    volumes: 1/1 healthy
    pools:   4 pools, 81 pgs
    objects: 106 objects, 175 MiB
    usage:   1.7 GiB used, 268 GiB / 270 GiB avail
    pgs:     81 active+clean


```
