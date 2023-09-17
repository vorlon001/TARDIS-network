
create 6 vm, Debian 12 ( https://github.com/vorlon001/libvirt-home-labs/tree/v33 )


| VM Name | IP Address, vlan 200 |
| ----------- | ----------- |
| node180    | 192.168.200.180   |
| node181    | 192.168.200.181   |
| node182    | 192.168.200.181   |
| node170    | 192.168.200.170   |
| node171    | 192.168.200.171   |
| node172    | 192.168.200.172   |


```shell


array=( 180 181 182 170 171 172 )
for i in "${array[@]}"
do
  scp -r * root@192.168.200.${i}:.
done

```


```yaml

# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        enp1s0:
            match:
                macaddress: fa:16:3e:02:c9:8c
            set-name: enp1s0
        enp2s0:
            match:
                macaddress: fa:16:3e:93:f7:ec
            set-name: enp2s0
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.180/24
            id: 200
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
            routes:
            -   to: 0.0.0.0/0
                via: 192.168.200.1
        enp1s0.400:
            addresses:
            - 192.168.201.180/24
            id: 400
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
        enp1s0.600:
            addresses:
            - 192.168.202.180/24
            id: 600
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10
        enp1s0.800:
            addresses:
            - 192.168.203.180/24
            id: 800
            link: enp1s0
            mtu: 1500
            nameservers:
                addresses:
                - 192.168.1.10

```

```shell

node180# sh ip bgp
BGP table version is 15, local router ID is 192.168.203.180, vrf id 0
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

   Network          Next Hop            Metric LocPrf Weight Path
*>i10.96.68.128/26  192.168.200.172               100      0 i
*>i10.96.70.0/26    192.168.200.171               100      0 i
*>i10.96.76.192/26  192.168.200.170               100      0 i
*=i10.96.128.0/17   192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i10.220.128.0/17  192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i11.0.0.0/22      192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i11.0.10.1/32     192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i11.0.10.10/32    192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i11.0.10.20/32    192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i11.0.10.22/32    192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*=i192.168.13.0/24  192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*> 192.168.200.0/24 0.0.0.0                  0         32768 ?
*> 192.168.201.0/24 0.0.0.0                  0         32768 ?
*> 192.168.202.0/24 0.0.0.0                  0         32768 ?
*> 192.168.203.0/24 0.0.0.0                  0         32768 ?

Displayed  15 routes and 31 total paths
node180#

node180# sh ip bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 192.168.203.180, local AS number 65000 vrf-id 0
BGP table version 15
RIB entries 29, using 5568 bytes of memory
Peers 3, using 2172 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.200.170 4      65000        27        33        0    0    0 00:17:21            9        4 N/A
192.168.200.171 4      65000        27        33        0    0    0 00:17:21            9        4 N/A
192.168.200.172 4      65000        27        33        0    0    0 00:17:21            9        4 N/A

Total number of neighbors 3
node180#


root@node180:~# pdsh -R ssh -w root@192.168.200.18[0-2] "ETCDCTL_API=3 etcdctl endpoint status --cluster --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.pem --cert=/etc/etcd/server.pem --key=/etc/etcd/server-key.pem  --write-out=table"
192.168.200.182: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
192.168.200.182: |           ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
192.168.200.182: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
192.168.200.182: | https://192.168.200.182:2379 | 8f96a718a46f8769 |   3.5.9 |  9.9 MB |      true |      false |         6 |     289883 |             289883 |        |
192.168.200.182: | https://192.168.200.181:2379 | a3825c01b40c365f |   3.5.9 |   10 MB |     false |      false |         6 |     289883 |             289883 |        |
192.168.200.182: | https://192.168.200.180:2379 | b9f73f8da6b4eff4 |   3.5.9 |  9.9 MB |     false |      false |         6 |     289883 |             289883 |        |
192.168.200.182: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
192.168.200.181: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
192.168.200.181: |           ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
192.168.200.181: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
192.168.200.181: | https://192.168.200.182:2379 | 8f96a718a46f8769 |   3.5.9 |  9.9 MB |      true |      false |         6 |     289883 |             289883 |        |
192.168.200.181: | https://192.168.200.181:2379 | a3825c01b40c365f |   3.5.9 |   10 MB |     false |      false |         6 |     289883 |             289883 |        |
192.168.200.181: | https://192.168.200.180:2379 | b9f73f8da6b4eff4 |   3.5.9 |  9.9 MB |     false |      false |         6 |     289883 |             289883 |        |
192.168.200.181: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
192.168.200.180: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
192.168.200.180: |           ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
192.168.200.180: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
192.168.200.180: | https://192.168.200.182:2379 | 8f96a718a46f8769 |   3.5.9 |  9.9 MB |      true |      false |         6 |     289883 |             289883 |        |
192.168.200.180: | https://192.168.200.181:2379 | a3825c01b40c365f |   3.5.9 |   10 MB |     false |      false |         6 |     289883 |             289883 |        |
192.168.200.180: | https://192.168.200.180:2379 | b9f73f8da6b4eff4 |   3.5.9 |  9.9 MB |     false |      false |         6 |     289883 |             289883 |        |
192.168.200.180: +------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
root@node180:~#



root@node180:~# systemctl status kube-apiserver.service
● kube-apiserver.service - Kubernetes API Server
     Loaded: loaded (/lib/systemd/system/kube-apiserver.service; enabled; preset: enabled)
     Active: active (running) since Sun 2023-09-17 11:44:59 +05; 14min ago
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 1032 (kube-apiserver)
      Tasks: 11 (limit: 9483)
     Memory: 370.0M
        CPU: 1min 3.054s
     CGroup: /system.slice/kube-apiserver.service
             └─1032 /usr/local/bin/kube-apiserver --advertise-address=192.168.200.180 --allow-privileged=true --audit-log-format=json --audit-log-maxage=7 --audit-log-maxbackup=10 --audit->

сен 17 11:55:15 node180 kube-apiserver[1032]: I0917 11:55:15.612373    1032 handler.go:232] Adding GroupVersion acme.cert-manager.io v1 to ResourceManager
сен 17 11:55:15 node180 kube-apiserver[1032]: I0917 11:55:15.612913    1032 handler.go:232] Adding GroupVersion metallb.io v1beta1 to ResourceManager
сен 17 11:55:15 node180 kube-apiserver[1032]: I0917 11:55:15.618663    1032 handler.go:232] Adding GroupVersion projectcalico.org v3 to ResourceManager
сен 17 11:55:15 node180 kube-apiserver[1032]: I0917 11:55:15.618985    1032 handler.go:232] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager
сен 17 11:56:15 node180 kube-apiserver[1032]: I0917 11:56:15.565170    1032 handler.go:232] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager
сен 17 11:56:15 node180 kube-apiserver[1032]: I0917 11:56:15.567200    1032 handler.go:232] Adding GroupVersion projectcalico.org v3 to ResourceManager
сен 17 11:57:15 node180 kube-apiserver[1032]: I0917 11:57:15.564705    1032 handler.go:232] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager
сен 17 11:57:15 node180 kube-apiserver[1032]: I0917 11:57:15.566161    1032 handler.go:232] Adding GroupVersion projectcalico.org v3 to ResourceManager
сен 17 11:58:15 node180 kube-apiserver[1032]: I0917 11:58:15.565588    1032 handler.go:232] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager
сен 17 11:58:15 node180 kube-apiserver[1032]: I0917 11:58:15.568980    1032 handler.go:232] Adding GroupVersion projectcalico.org v3 to ResourceManager


root@node180:~# systemctl status  kube-scheduler.service
● kube-scheduler.service - Kubernetes Scheduler
     Loaded: loaded (/lib/systemd/system/kube-scheduler.service; enabled; preset: enabled)
     Active: active (running) since Sun 2023-09-17 11:40:23 +05; 19min ago
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 566 (kube-scheduler)
      Tasks: 10 (limit: 9483)
     Memory: 70.8M
        CPU: 3.732s
     CGroup: /system.slice/kube-scheduler.service
             └─566 /usr/local/bin/kube-scheduler --authentication-kubeconfig=/etc/kubernetes/scheduler.kubeconfig --authorization-kubeconfig=/etc/kubernetes/scheduler.kubeconfig --bind-add>

сен 17 11:45:14 node180 kube-scheduler[566]: Trace[1528634888]: ---"Objects listed" error:Get "https://192.168.200.180:6443/apis/policy/v1/poddisruptionbudgets?limit=500&resourceVersion=0">
сен 17 11:45:14 node180 kube-scheduler[566]: Trace[1528634888]: [10.001593306s] [10.001593306s] END
сен 17 11:45:14 node180 kube-scheduler[566]: E0917 11:45:14.482377     566 reflector.go:147] vendor/k8s.io/client-go/informers/factory.go:150: Failed to watch *v1.PodDisruptionBudget: fail>
сен 17 11:45:15 node180 kube-scheduler[566]: W0917 11:45:15.575064     566 reflector.go:535] vendor/k8s.io/client-go/informers/factory.go:150: failed to list *v1.ReplicaSet: Get "https://1>
сен 17 11:45:15 node180 kube-scheduler[566]: I0917 11:45:15.575128     566 trace.go:236] Trace[525872492]: "Reflector ListAndWatch" name:vendor/k8s.io/client-go/informers/factory.go:150 (1>
сен 17 11:45:15 node180 kube-scheduler[566]: Trace[525872492]: ---"Objects listed" error:Get "https://192.168.200.180:6443/apis/apps/v1/replicasets?limit=500&resourceVersion=0": net/http: >
сен 17 11:45:15 node180 kube-scheduler[566]: Trace[525872492]: [10.000919234s] [10.000919234s] END
сен 17 11:45:15 node180 kube-scheduler[566]: E0917 11:45:15.575139     566 reflector.go:147] vendor/k8s.io/client-go/informers/factory.go:150: Failed to watch *v1.ReplicaSet: failed to lis>
сен 17 11:45:46 node180 kube-scheduler[566]: I0917 11:45:46.603662     566 shared_informer.go:318] Caches are synced for client-ca::kube-system::extension-apiserver-authentication::client->
сен 17 11:45:54 node180 kube-scheduler[566]: I0917 11:45:54.607024     566 leaderelection.go:250] attempting to acquire leader lease kube-system/kube-scheduler...

root@node180:~# systemctl restart kube-controller-manager.service
root@node180:~# systemctl status kube-controller-manager.service
● kube-controller-manager.service - Kubernetes Controller Manager
     Loaded: loaded (/lib/systemd/system/kube-controller-manager.service; enabled; preset: enabled)
     Active: active (running) since Sun 2023-09-17 12:00:16 +05; 1s ago
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 2759 (kube-controller)
      Tasks: 8 (limit: 9483)
     Memory: 24.5M
        CPU: 628ms
     CGroup: /system.slice/kube-controller-manager.service
             └─2759 /usr/local/bin/kube-controller-manager --allocate-node-cidrs=true --authentication-kubeconfig=/etc/kubernetes/controller-manager.kubeconfig --authorization-kubeconfig=/>

сен 17 12:00:16 node180 systemd[1]: Started kube-controller-manager.service - Kubernetes Controller Manager.
сен 17 12:00:16 node180 kube-controller-manager[2759]: I0917 12:00:16.754509    2759 serving.go:348] Generated self-signed cert in-memory
сен 17 12:00:17 node180 kube-controller-manager[2759]: I0917 12:00:17.105046    2759 controllermanager.go:189] "Starting" version="v1.28.1"
сен 17 12:00:17 node180 kube-controller-manager[2759]: I0917 12:00:17.105282    2759 controllermanager.go:191] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
сен 17 12:00:17 node180 kube-controller-manager[2759]: I0917 12:00:17.106179    2759 dynamic_cafile_content.go:157] "Starting controller" name="request-header::/etc/kubernetes/pki/controll>
сен 17 12:00:17 node180 kube-controller-manager[2759]: I0917 12:00:17.106212    2759 dynamic_cafile_content.go:157] "Starting controller" name="client-ca-bundle::/etc/kubernetes/pki/ca.crt"
сен 17 12:00:17 node180 kube-controller-manager[2759]: I0917 12:00:17.107142    2759 secure_serving.go:210] Serving securely on 0.0.0.0:10257
сен 17 12:00:17 node180 kube-controller-manager[2759]: I0917 12:00:17.107171    2759 tlsconfig.go:240] "Starting DynamicServingCertificateController"
сен 17 12:00:17 node180 kube-controller-manager[2759]: I0917 12:00:17.107613    2759 leaderelection.go:250] attempting to acquire leader lease kube-system/kube-controller-manager...

```


![alt text](http://www.wonderland-alice.ru/netcat_files/177_94.gif)
