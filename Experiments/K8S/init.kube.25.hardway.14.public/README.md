```shell

VM CORE:5, RAM:8Gb, DISK: 30Gb:
- node180
- node181
- node181
- node170
- node171
- node172


array=( 180 181 182 170 171 172 )
for i in "${array[@]}"
do
  scp -r * root@192.168.200.${i}:.
done

```



```

root@node1:/KVM/init.kube.24.hardway/UTILS# ./nerdctl namespace list
NAME            CONTAINERS    IMAGES    VOLUMES    LABELS
example         0             1         0
example-ns-1    1             1         0
k8s.io          0             14        0
moby            8             0         0


root@node1:/KVM/init.kube.24.hardway/UTILS# ./nerdctl -n moby ps -a
CONTAINER ID    IMAGE    COMMAND                   CREATED           STATUS    PORTS    NAMES
0c8862475f9d             "/entrypoint.sh /etc…"    12 days ago       Up
1b307dea66fd             "/docker-entrypoint.…"    35 minutes ago    Up
40022b910e2f             "/usr/sbin/named -g …"    56 minutes ago    Up
4ca590585179             "/container/tool/run…"    12 days ago       Up
8b67fd5270d7             "/usr/bin/dumb-init …"    12 days ago       Up
995cab92941c             "docker-entrypoint.s…"    46 minutes ago    Up
e1e49a963382             "/docker-entrypoint.…"    12 days ago       Up
e2eb315436f2             "/opt/sonatype/nexus…"    34 minutes ago    Up



```



```
root@node180:~# kubectl get node,pod -A -o wide
NAME           STATUS   ROLES    AGE   VERSION   INTERNAL-IP       EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
node/node170   Ready    worker   14m   v1.29.1   192.168.200.170   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-17-amd64   containerd://1.7.12
node/node171   Ready    worker   14m   v1.29.1   192.168.200.171   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-17-amd64   containerd://1.7.12
node/node172   Ready    worker   14m   v1.29.1   192.168.200.172   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-17-amd64   containerd://1.7.12

NAMESPACE     NAME                                           READY   STATUS    RESTARTS   AGE   IP                NODE      NOMINATED NODE   READINESS GATES
kube-system   pod/cilium-68kqj                               1/1     Running   0          10m   192.168.200.170   node170   <none>           <none>
kube-system   pod/cilium-gm5j9                               1/1     Running   0          10m   192.168.200.171   node171   <none>           <none>
kube-system   pod/cilium-jthtr                               1/1     Running   0          10m   192.168.200.172   node172   <none>           <none>
kube-system   pod/cilium-operator-645496d879-gzcn2           1/1     Running   0          13m   192.168.200.172   node172   <none>           <none>
kube-system   pod/cilium-operator-645496d879-jqdhw           1/1     Running   0          13m   192.168.200.170   node170   <none>           <none>
kube-system   pod/coredns-6d95d659f4-bx44l                   1/1     Running   0          15m   10.96.1.63        node170   <none>           <none>
kube-system   pod/coredns-6d95d659f4-xzrd4                   1/1     Running   0          15m   10.96.1.55        node170   <none>           <none>
kube-system   pod/kube-proxy-9bhr7                           1/1     Running   0          14m   192.168.200.170   node170   <none>           <none>
kube-system   pod/kube-proxy-p59pm                           1/1     Running   0          14m   192.168.200.171   node171   <none>           <none>
kube-system   pod/kube-proxy-t9hn5                           1/1     Running   0          14m   192.168.200.172   node172   <none>           <none>
nfs-client    pod/nfs-client-provisioner-ccbcf7ccc-54rhk     1/1     Running   0          80s   10.96.2.12        node171   <none>           <none>
test-0        pod/ekvm-busybox-deployment-795fc98dcb-5dqsj   1/1     Running   0          58s   10.96.1.208       node170   <none>           <none>
test-0        pod/ekvm-busybox-deployment-795fc98dcb-j9v99   1/1     Running   0          58s   10.96.3.175       node172   <none>           <none>
test-0        pod/ekvm-busybox-deployment-795fc98dcb-rcstl   1/1     Running   0          58s   10.96.2.94        node171   <none>           <none>
test-0        pod/ekvm-busybox-deployment-795fc98dcb-zpjdg   1/1     Running   0          58s   10.96.1.183       node170   <none>           <none>
test-0        pod/nginx-deployment-v1-76476c4f95-8rt9h       1/1     Running   0          58s   10.96.3.212       node172   <none>           <none>
test-0        pod/nginx-deployment-v2-6649779747-2sskt       1/1     Running   0          58s   10.96.2.244       node171   <none>           <none>
test-0        pod/postgres13-7598d7dd66-lrb8n                1/1     Running   0          58s   10.96.3.13        node172   <none>           <none>
test-kube-0   pod/mysql80-866454fd49-nbhdp                   1/1     Running   0          65s   10.96.3.217       node172   <none>           <none>
test-kube-0   pod/postgres13-0                               1/1     Running   0          64s   10.96.1.172       node170   <none>           <none>
test-kube-0   pod/postgres13-1                               1/1     Running   0          30s   10.96.3.93        node172   <none>           <none>
test-kube-0   pod/postgres13-2                               1/1     Running   0          22s   10.96.2.126       node171   <none>           <none>
test-kube-0   pod/postgres13-3                               1/1     Running   0          18s   10.96.1.64        node170   <none>           <none>
test-kube-0   pod/postgres13-4                               1/1     Running   0          16s   10.96.3.173       node172   <none>           <none>
test-kube-0   pod/postgres13-6fcd465b7f-tqf9j                1/1     Running   0          65s   10.96.2.161       node171   <none>           <none>
test-kube-0   pod/web-0                                      1/1     Running   0          64s   10.96.2.211       node171   <none>           <none>
test-kube-0   pod/web-1                                      1/1     Running   0          54s   10.96.2.112       node171   <none>           <none>
test-kube-0   pod/web-2                                      1/1     Running   0          51s   10.96.3.208       node172   <none>           <none>
test-kube-0   pod/web-3                                      1/1     Running   0          46s   10.96.1.7         node170   <none>           <none>
test-kube-0   pod/web-4                                      1/1     Running   0          42s   10.96.2.93        node171   <none>           <none>
test-kube-0   pod/web-5                                      1/1     Running   0          38s   10.96.3.156       node172   <none>           <none>
test-kube-0   pod/web10-0                                    1/1     Running   0          64s   10.96.3.63        node172   <none>           <none>
test-kube-0   pod/web10-1                                    1/1     Running   0          54s   10.96.1.6         node170   <none>           <none>

root@node180:~# kubectl get pvc,svc -A -o wide
NAMESPACE     NAME                                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          VOLUMEATTRIBUTESCLASS   AGE   VOLUMEMODE
test-kube-0   persistentvolumeclaim/kyverno-test-07-claim3       Bound    pvc-fe685988-d0a8-4cc6-922c-19be43aa981b   1Gi        RWO            managed-nfs-storage   <unset>                 88s   Filesystem
test-kube-0   persistentvolumeclaim/mysql80-pv-volume2           Bound    pvc-bfc3f404-a330-4d1b-8063-3dfb13a2939e   2Gi        RWO            managed-nfs-storage   <unset>                 89s   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-0   Bound    pvc-5bf08ae5-0840-43c9-b11b-f15ea115ca90   1Gi        RWO            managed-nfs-storage   <unset>                 88s   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-1   Bound    pvc-3227fce9-bcf6-47d2-99fc-db012d954fe7   1Gi        RWO            managed-nfs-storage   <unset>                 54s   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-2   Bound    pvc-fb85c101-f045-45aa-a58c-32a235368aa8   1Gi        RWO            managed-nfs-storage   <unset>                 46s   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-3   Bound    pvc-9e8e3f11-702c-473e-a7da-5f9f04419244   1Gi        RWO            managed-nfs-storage   <unset>                 42s   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-4   Bound    pvc-aaf74172-0cef-4197-88cf-f5885c5a5e7f   1Gi        RWO            managed-nfs-storage   <unset>                 40s   Filesystem
test-kube-0   persistentvolumeclaim/postgres-pv-claim13          Bound    pvc-a36bc235-5c5d-4f82-964d-29e42d50e3ae   5Gi        RWX            managed-nfs-storage   <unset>                 89s   Filesystem
test-kube-0   persistentvolumeclaim/www-web-0                    Bound    pvc-8b64a404-d450-4d4b-a5f1-7940985977df   1Gi        RWO            managed-nfs-storage   <unset>                 88s   Filesystem
test-kube-0   persistentvolumeclaim/www-web-1                    Bound    pvc-53a5f286-2fa9-4a36-a0b5-9df6bd1c59d6   1Gi        RWO            managed-nfs-storage   <unset>                 78s   Filesystem
test-kube-0   persistentvolumeclaim/www-web-2                    Bound    pvc-9e40e824-5332-47e7-9f7c-13c31e7ebd78   1Gi        RWO            managed-nfs-storage   <unset>                 75s   Filesystem
test-kube-0   persistentvolumeclaim/www-web-3                    Bound    pvc-d69a839d-9097-47ac-8f94-000be8616059   1Gi        RWO            managed-nfs-storage   <unset>                 70s   Filesystem
test-kube-0   persistentvolumeclaim/www-web-4                    Bound    pvc-f8f72ee6-f284-4ec4-922f-2fa2702dc9ad   1Gi        RWO            managed-nfs-storage   <unset>                 66s   Filesystem
test-kube-0   persistentvolumeclaim/www-web-5                    Bound    pvc-e869a6d3-fc19-4e4d-b42f-169716a60bc4   1Gi        RWO            managed-nfs-storage   <unset>                 62s   Filesystem

NAMESPACE     NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE   SELECTOR
default       service/kubernetes           ClusterIP      10.96.128.1     <none>        443/TCP                  15m   <none>
kube-system   service/hubble-peer          ClusterIP      10.96.170.114   <none>        443/TCP                  14m   k8s-app=cilium
kube-system   service/kube-dns             ClusterIP      10.96.128.10    <none>        53/UDP,53/TCP,9153/TCP   15m   k8s-app=kube-dns
test-0        service/ekvm-busybox         LoadBalancer   10.96.193.190   <pending>     1022:30453/TCP           82s   app=ekvm
test-0        service/nginx-v1             LoadBalancer   10.96.144.242   12.0.10.1     8080:30942/TCP           82s   app=nginx-v1
test-0        service/nginx-v2             LoadBalancer   10.96.236.198   11.0.0.0      8080:31155/TCP           82s   app=nginx-v2
test-0        service/postgres13           LoadBalancer   10.96.190.132   11.0.0.1      5432:32492/TCP           82s   app=postgres13
test-kube-0   service/mysql80nodeport      NodePort       10.96.176.43    <none>        3306:30424/TCP           89s   app=mysql80
test-kube-0   service/mysql80oadbalancer   LoadBalancer   10.96.252.49    12.0.11.2     3306:31537/TCP           89s   app=mysql80

root@node180:~# ip r s
default via 192.168.200.1 dev enp1s0.200 proto static
10.96.1.0/24 via 192.168.200.170 dev enp1s0.200 proto bgp metric 20
10.96.2.0/24 via 192.168.200.171 dev enp1s0.200 proto bgp metric 20
10.96.3.0/24 via 192.168.200.172 dev enp1s0.200 proto bgp metric 20
11.0.0.0 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
11.0.0.1 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
12.0.10.1 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
12.0.11.2 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
192.168.200.0/24 dev enp1s0.200 proto kernel scope link src 192.168.200.180
192.168.201.0/24 dev enp1s0.400 proto kernel scope link src 192.168.201.180
192.168.202.0/24 dev enp1s0.600 proto kernel scope link src 192.168.202.180
192.168.203.0/24 dev enp1s0.800 proto kernel scope link src 192.168.203.180


node180# show ip bgp
BGP table version is 11, local router ID is 192.168.203.180, vrf id 0
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

   Network          Next Hop            Metric LocPrf Weight Path
*>i10.96.1.0/24     192.168.200.170               100      0 i
*>i10.96.2.0/24     192.168.200.171               100      0 i
*>i10.96.3.0/24     192.168.200.172               100      0 i
*=i11.0.0.0/32      192.168.200.171               100      0 i
*=i                 192.168.200.172               100      0 i
*>i                 192.168.200.170               100      0 i
*=i11.0.0.1/32      192.168.200.171               100      0 i
*=i                 192.168.200.172               100      0 i
*>i                 192.168.200.170               100      0 i
*=i12.0.10.1/32     192.168.200.172               100      0 i
*>i                 192.168.200.170               100      0 i
*=i                 192.168.200.171               100      0 i
*>i12.0.11.2/32     192.168.200.170               100      0 i
*=i                 192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*> 192.168.200.0/24 0.0.0.0                  0         32768 ?
*> 192.168.201.0/24 0.0.0.0                  0         32768 ?
*> 192.168.202.0/24 0.0.0.0                  0         32768 ?
*> 192.168.203.0/24 0.0.0.0                  0         32768 ?

Displayed  11 routes and 19 total paths
node180# show ip bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 192.168.203.180, local AS number 65000 vrf-id 0
BGP table version 11
RIB entries 21, using 4032 bytes of memory
Peers 3, using 2172 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.200.170 4      65000        16        18        0    0    0 00:04:39            5        7 N/A
192.168.200.171 4      65000        15        17        0    0    0 00:04:22            5        7 N/A
192.168.200.172 4      65000        14        16        0    0    0 00:03:42            5        7 N/A

Total number of neighbors 3
node180#

root@node181:~# ip r s
default via 192.168.200.1 dev enp1s0.200 proto static
10.96.1.0/24 via 192.168.200.170 dev enp1s0.200 proto bgp metric 20
10.96.2.0/24 via 192.168.200.171 dev enp1s0.200 proto bgp metric 20
10.96.3.0/24 via 192.168.200.172 dev enp1s0.200 proto bgp metric 20
11.0.0.0 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
11.0.0.1 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
12.0.10.1 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
12.0.11.2 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
192.168.200.0/24 dev enp1s0.200 proto kernel scope link src 192.168.200.181
192.168.201.0/24 dev enp1s0.400 proto kernel scope link src 192.168.201.181
192.168.202.0/24 dev enp1s0.600 proto kernel scope link src 192.168.202.181
192.168.203.0/24 dev enp1s0.800 proto kernel scope link src 192.168.203.181

node181# sh ip bgp
BGP table version is 11, local router ID is 192.168.203.181, vrf id 0
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

   Network          Next Hop            Metric LocPrf Weight Path
*>i10.96.1.0/24     192.168.200.170               100      0 i
*>i10.96.2.0/24     192.168.200.171               100      0 i
*>i10.96.3.0/24     192.168.200.172               100      0 i
*=i11.0.0.0/32      192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i                 192.168.200.172               100      0 i
*=i11.0.0.1/32      192.168.200.171               100      0 i
*=i                 192.168.200.172               100      0 i
*>i                 192.168.200.170               100      0 i
*=i12.0.10.1/32     192.168.200.172               100      0 i
*>i                 192.168.200.170               100      0 i
*=i                 192.168.200.171               100      0 i
*>i12.0.11.2/32     192.168.200.170               100      0 i
*=i                 192.168.200.171               100      0 i
*=i                 192.168.200.172               100      0 i
*> 192.168.200.0/24 0.0.0.0                  0         32768 ?
*> 192.168.201.0/24 0.0.0.0                  0         32768 ?
*> 192.168.202.0/24 0.0.0.0                  0         32768 ?
*> 192.168.203.0/24 0.0.0.0                  0         32768 ?

Displayed  11 routes and 19 total paths
node181# sh ip bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 192.168.203.181, local AS number 65000 vrf-id 0
BGP table version 11
RIB entries 21, using 4032 bytes of memory
Peers 3, using 2172 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.200.170 4      65000        28        30        0    0    0 00:10:35            5        7 N/A
192.168.200.171 4      65000        27        29        0    0    0 00:10:16            5        7 N/A
192.168.200.172 4      65000        27        29        0    0    0 00:10:18            5        7 N/A

Total number of neighbors 3
node181#


root@node182:~# ip r s
default via 192.168.200.1 dev enp1s0.200 proto static
10.96.1.0/24 via 192.168.200.170 dev enp1s0.200 proto bgp metric 20
10.96.2.0/24 via 192.168.200.171 dev enp1s0.200 proto bgp metric 20
10.96.3.0/24 via 192.168.200.172 dev enp1s0.200 proto bgp metric 20
11.0.0.0 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
11.0.0.1 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
12.0.10.1 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
12.0.11.2 proto bgp metric 20
        nexthop via 192.168.200.170 dev enp1s0.200 weight 1
        nexthop via 192.168.200.171 dev enp1s0.200 weight 1
        nexthop via 192.168.200.172 dev enp1s0.200 weight 1
192.168.200.0/24 dev enp1s0.200 proto kernel scope link src 192.168.200.182
192.168.201.0/24 dev enp1s0.400 proto kernel scope link src 192.168.201.182
192.168.202.0/24 dev enp1s0.600 proto kernel scope link src 192.168.202.182
192.168.203.0/24 dev enp1s0.800 proto kernel scope link src 192.168.203.182

node182# sh ip bgp
BGP table version is 11, local router ID is 192.168.203.182, vrf id 0
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

   Network          Next Hop            Metric LocPrf Weight Path
*>i10.96.1.0/24     192.168.200.170               100      0 i
*>i10.96.2.0/24     192.168.200.171               100      0 i
*>i10.96.3.0/24     192.168.200.172               100      0 i
*=i11.0.0.0/32      192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i                 192.168.200.172               100      0 i
*=i11.0.0.1/32      192.168.200.171               100      0 i
*=i                 192.168.200.172               100      0 i
*>i                 192.168.200.170               100      0 i
*=i12.0.10.1/32     192.168.200.172               100      0 i
*>i                 192.168.200.170               100      0 i
*=i                 192.168.200.171               100      0 i
*>i12.0.11.2/32     192.168.200.170               100      0 i
*=i                 192.168.200.171               100      0 i
*=i                 192.168.200.172               100      0 i
*> 192.168.200.0/24 0.0.0.0                  0         32768 ?
*> 192.168.201.0/24 0.0.0.0                  0         32768 ?
*> 192.168.202.0/24 0.0.0.0                  0         32768 ?
*> 192.168.203.0/24 0.0.0.0                  0         32768 ?

Displayed  11 routes and 19 total paths

node182# sh ip bgp  summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 192.168.203.182, local AS number 65000 vrf-id 0
BGP table version 11
RIB entries 21, using 4032 bytes of memory
Peers 3, using 2172 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.200.170 4      65000        27        29        0    0    0 00:10:04            5        7 N/A
192.168.200.171 4      65000        26        28        0    0    0 00:09:38            5        7 N/A
192.168.200.172 4      65000        29        31        0    0    0 00:11:20            5        7 N/A

Total number of neighbors 3
node182#


```
