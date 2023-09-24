```shell


array=( 180 181 182 170 171 172 )
for i in "${array[@]}"
do
  scp -r * root@192.168.200.${i}:.
done

```



```



root@node180:~# kubectl get node,pod -A -o wide
NAME           STATUS   ROLES    AGE   VERSION   INTERNAL-IP       EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
node/node170   Ready    worker   35m   v1.28.2   192.168.200.170   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-12-amd64   containerd://1.7.6
node/node171   Ready    worker   35m   v1.28.2   192.168.200.171   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-12-amd64   containerd://1.7.6
node/node172   Ready    worker   35m   v1.28.2   192.168.200.172   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-12-amd64   containerd://1.7.6

NAMESPACE        NAME                                           READY   STATUS    RESTARTS   AGE   IP                NODE      NOMINATED NODE   READINESS GATES
cert-manager     pod/cert-manager-5c8fdfffdc-dhkxv              1/1     Running   0          17m   10.96.3.91        node172   <none>           <none>
cert-manager     pod/cert-manager-cainjector-866db6c666-lrmqv   1/1     Running   0          17m   10.96.2.139       node171   <none>           <none>
cert-manager     pod/cert-manager-webhook-67bd47cd6c-62knr      1/1     Running   0          17m   10.96.3.69        node172   <none>           <none>
kube-system      pod/cilium-h5xxk                               1/1     Running   0          26m   192.168.200.172   node172   <none>           <none>
kube-system      pod/cilium-operator-775b8489d9-cq462           1/1     Running   0          31m   192.168.200.172   node172   <none>           <none>
kube-system      pod/cilium-operator-775b8489d9-kv2vn           1/1     Running   0          31m   192.168.200.170   node170   <none>           <none>
kube-system      pod/cilium-tc6cb                               1/1     Running   0          27m   192.168.200.170   node170   <none>           <none>
kube-system      pod/cilium-vdscm                               1/1     Running   0          26m   192.168.200.171   node171   <none>           <none>
kube-system      pod/coredns-556475dbbd-qs667                   1/1     Running   0          18m   10.96.2.39        node171   <none>           <none>
kube-system      pod/coredns-556475dbbd-rntl8                   1/1     Running   0          18m   10.96.1.82        node170   <none>           <none>
kube-system      pod/kube-proxy-6m82p                           1/1     Running   0          35m   192.168.200.171   node171   <none>           <none>
kube-system      pod/kube-proxy-hbpvf                           1/1     Running   0          35m   192.168.200.172   node172   <none>           <none>
kube-system      pod/kube-proxy-ps74d                           1/1     Running   0          35m   192.168.200.170   node170   <none>           <none>
kube-system      pod/metrics-server-669c5c9b99-hbnlv            1/1     Running   0          17m   10.96.2.213       node171   <none>           <none>
kube-system      pod/metrics-server-669c5c9b99-xd9ch            1/1     Running   0          17m   10.96.1.56        node170   <none>           <none>
metallb-system   pod/controller-58ccd79f69-r9q8x                1/1     Running   0          17m   10.96.2.221       node171   <none>           <none>
metallb-system   pod/speaker-6n72k                              4/4     Running   0          17m   192.168.200.172   node172   <none>           <none>
metallb-system   pod/speaker-8n6nm                              4/4     Running   0          17m   192.168.200.171   node171   <none>           <none>
metallb-system   pod/speaker-q9psd                              4/4     Running   0          17m   192.168.200.170   node170   <none>           <none>
nfs-client       pod/nfs-client-provisioner-66b75768dd-nrrnv    1/1     Running   0          17m   10.96.1.154       node170   <none>           <none>
octant           pod/octant-dashboard-5c7bcc5b64-5whf7          1/1     Running   0          14m   10.96.3.81        node172   <none>           <none>
test-kube-0      pod/mysql80-866454fd49-scrkl                   1/1     Running   0          17m   10.96.1.5         node170   <none>           <none>
test-kube-0      pod/postgres13-0                               1/1     Running   0          17m   10.96.3.14        node172   <none>           <none>
test-kube-0      pod/postgres13-1                               1/1     Running   0          17m   10.96.1.219       node170   <none>           <none>
test-kube-0      pod/postgres13-2                               1/1     Running   0          16m   10.96.3.241       node172   <none>           <none>
test-kube-0      pod/postgres13-3                               1/1     Running   0          16m   10.96.1.34        node170   <none>           <none>
test-kube-0      pod/postgres13-4                               1/1     Running   0          16m   10.96.2.144       node171   <none>           <none>
test-kube-0      pod/postgres13-6fcd465b7f-w47nf                1/1     Running   0          17m   10.96.2.45        node171   <none>           <none>
test-kube-0      pod/web-0                                      1/1     Running   0          17m   10.96.2.136       node171   <none>           <none>
test-kube-0      pod/web-1                                      1/1     Running   0          17m   10.96.3.243       node172   <none>           <none>
test-kube-0      pod/web-2                                      1/1     Running   0          17m   10.96.2.196       node171   <none>           <none>
test-kube-0      pod/web-3                                      1/1     Running   0          17m   10.96.1.193       node170   <none>           <none>
test-kube-0      pod/web-4                                      1/1     Running   0          17m   10.96.3.124       node172   <none>           <none>
test-kube-0      pod/web-5                                      1/1     Running   0          16m   10.96.2.230       node171   <none>           <none>
test-kube-0      pod/web10-0                                    1/1     Running   0          17m   10.96.3.206       node172   <none>           <none>
test-kube-0      pod/web10-1                                    1/1     Running   0          17m   10.96.1.232       node170   <none>           <none>


root@node180:~# kubectl get node,svc,pvc -A -o wide
NAME           STATUS   ROLES    AGE   VERSION   INTERNAL-IP       EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
node/node170   Ready    worker   36m   v1.28.2   192.168.200.170   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-12-amd64   containerd://1.7.6
node/node171   Ready    worker   35m   v1.28.2   192.168.200.171   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-12-amd64   containerd://1.7.6
node/node172   Ready    worker   35m   v1.28.2   192.168.200.172   <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-12-amd64   containerd://1.7.6

NAMESPACE        NAME                           TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                    AGE   SELECTOR
cert-manager     service/cert-manager           ClusterIP      10.96.145.197   <none>        9402/TCP                                   18m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=cert-manager
cert-manager     service/cert-manager-webhook   ClusterIP      10.96.255.238   <none>        443/TCP                                    18m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=webhook
default          service/kubernetes             ClusterIP      10.96.128.1     <none>        443/TCP                                    37m   <none>
kube-system      service/hubble-peer            ClusterIP      10.96.227.156   <none>        443/TCP                                    31m   k8s-app=cilium
kube-system      service/kube-dns               LoadBalancer   10.96.128.10    11.0.11.22    53:30226/UDP,53:31577/TCP,9153:32567/TCP   36m   k8s-app=kube-dns
kube-system      service/metrics-server         ClusterIP      10.96.142.77    <none>        443/TCP                                    18m   k8s-app=metrics-server
metallb-system   service/webhook-service        ClusterIP      10.96.150.58    <none>        443/TCP                                    17m   component=controller
octant           service/octant-dashboard       ClusterIP      10.96.155.175   <none>        8000/TCP                                   15m   app.kubernetes.io/instance=octant-dashboard,app.kubernetes.io/name=octant
test-kube-0      service/mysql80nodeport        NodePort       10.96.200.140   <none>        3306:31347/TCP                             17m   app=mysql80
test-kube-0      service/mysql80oadbalancer     LoadBalancer   10.96.177.219   11.0.0.0      3306:32675/TCP                             17m   app=mysql80

NAMESPACE     NAME                                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE   VOLUMEMODE
test-kube-0   persistentvolumeclaim/kyverno-test-07-claim3       Bound    pvc-e20b16d0-2f12-495f-aa7b-0b9e2713ccaa   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/mysql80-pv-volume2           Bound    pvc-d076135b-0e31-46ca-84ab-4d39fdd7355f   2Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-0   Bound    pvc-f5585774-af0c-4b99-8e7b-817098e3e39a   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-1   Bound    pvc-415b472c-cd16-4b4c-a353-9612bfea6d24   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-2   Bound    pvc-dabd13ca-6edb-42e6-baad-8adebfc9cc8b   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-3   Bound    pvc-281973b9-846d-4413-a686-eeb03a5b1b3b   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/postgredb13v2-postgres13-4   Bound    pvc-9c32352a-89ab-4301-ac7f-e02d7270b045   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/postgres-pv-claim13          Bound    pvc-31bfed9a-e79d-4ab6-a833-8041a9e46b55   5Gi        RWX            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/www-web-0                    Bound    pvc-645947ba-9e10-407b-9f9d-fae57b37cd1c   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/www-web-1                    Bound    pvc-cfc861a2-40e8-4360-9f26-39d3a331a54f   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/www-web-2                    Bound    pvc-36db3882-15a4-419e-9bae-6e047436eb5c   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/www-web-3                    Bound    pvc-6efb6472-5236-4c71-a0f5-198e8769b59a   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/www-web-4                    Bound    pvc-bceca7b6-85f6-45ac-a603-6be222b43106   1Gi        RWO            managed-nfs-storage   17m   Filesystem
test-kube-0   persistentvolumeclaim/www-web-5                    Bound    pvc-9e603764-efaf-484f-b2aa-8b98973391a9   1Gi        RWO            managed-nfs-storage   17m   Filesystem
root@node180:~#

root@node180:~# systemctl status kube-apiserver.service
● kube-apiserver.service - Kubernetes API Server
     Loaded: loaded (/lib/systemd/system/kube-apiserver.service; enabled; preset: enabled)
     Active: active (running) since Sun 2023-09-24 11:08:22 +05; 20min ago
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 1676 (kube-apiserver)
      Tasks: 12 (limit: 9483)
     Memory: 438.1M
        CPU: 1min 39.092s
     CGroup: /system.slice/kube-apiserver.service
             └─1676 /usr/local/bin/kube-apiserver --advertise-address=192.168.200.180 --allow-privileged=true --audit-log-format=json --audit-log-maxage=7 --audit-log-maxbackup=10 --audit->

сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.456168    1676 handler.go:232] Adding GroupVersion metallb.io v1beta2 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.456537    1676 handler.go:232] Adding GroupVersion cilium.io v2alpha1 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.456817    1676 handler.go:232] Adding GroupVersion cilium.io v2 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.457017    1676 handler.go:232] Adding GroupVersion cilium.io v2alpha1 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.457050    1676 handler.go:232] Adding GroupVersion cert-manager.io v1 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.457249    1676 handler.go:232] Adding GroupVersion cert-manager.io v1 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.457633    1676 handler.go:232] Adding GroupVersion metallb.io v1beta1 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.457827    1676 handler.go:232] Adding GroupVersion metallb.io v1beta1 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.458023    1676 handler.go:232] Adding GroupVersion cilium.io v2alpha1 to ResourceManager
сен 24 11:28:24 node180 kube-apiserver[1676]: I0924 11:28:24.475200    1676 handler.go:232] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager


root@node180:~# systemctl status kube-controller-manager.service
● kube-controller-manager.service - Kubernetes Controller Manager
     Loaded: loaded (/lib/systemd/system/kube-controller-manager.service; enabled; preset: enabled)
     Active: active (running) since Sun 2023-09-24 11:08:24 +05; 21min ago
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 1737 (kube-controller)
      Tasks: 8 (limit: 9483)
     Memory: 90.8M
        CPU: 1.838s
     CGroup: /system.slice/kube-controller-manager.service
             └─1737 /usr/local/bin/kube-controller-manager --allocate-node-cidrs=true --authentication-kubeconfig=/etc/kubernetes/controller-manager.kubeconfig --authorization-kubeconfig=/>

сен 24 11:08:24 node180 systemd[1]: Started kube-controller-manager.service - Kubernetes Controller Manager.
сен 24 11:08:25 node180 kube-controller-manager[1737]: I0924 11:08:25.025751    1737 serving.go:348] Generated self-signed cert in-memory
сен 24 11:08:25 node180 kube-controller-manager[1737]: I0924 11:08:25.309782    1737 controllermanager.go:189] "Starting" version="v1.28.2"
сен 24 11:08:25 node180 kube-controller-manager[1737]: I0924 11:08:25.309803    1737 controllermanager.go:191] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
сен 24 11:08:25 node180 kube-controller-manager[1737]: I0924 11:08:25.310876    1737 dynamic_cafile_content.go:157] "Starting controller" name="request-header::/etc/kubernetes/pki/controll>
сен 24 11:08:25 node180 kube-controller-manager[1737]: I0924 11:08:25.310905    1737 dynamic_cafile_content.go:157] "Starting controller" name="client-ca-bundle::/etc/kubernetes/pki/ca.crt"
сен 24 11:08:25 node180 kube-controller-manager[1737]: I0924 11:08:25.311629    1737 secure_serving.go:210] Serving securely on 0.0.0.0:10257
сен 24 11:08:25 node180 kube-controller-manager[1737]: I0924 11:08:25.311675    1737 tlsconfig.go:240] "Starting DynamicServingCertificateController"
сен 24 11:08:25 node180 kube-controller-manager[1737]: I0924 11:08:25.311903    1737 leaderelection.go:250] attempting to acquire leader lease kube-system/kube-controller-manager...

root@node180:~# systemctl status kube-scheduler.service
● kube-scheduler.service - Kubernetes Scheduler
     Loaded: loaded (/lib/systemd/system/kube-scheduler.service; enabled; preset: enabled)
     Active: active (running) since Sun 2023-09-24 11:08:26 +05; 21min ago
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 1791 (kube-scheduler)
      Tasks: 12 (limit: 9483)
     Memory: 67.7M
        CPU: 10.059s
     CGroup: /system.slice/kube-scheduler.service
             └─1791 /usr/local/bin/kube-scheduler --authentication-kubeconfig=/etc/kubernetes/scheduler.kubeconfig --authorization-kubeconfig=/etc/kubernetes/scheduler.kubeconfig --bind-ad>

сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.856161    1791 configmap_cafile_content.go:202] "Starting controller" name="client-ca::kube-system::extension-apiserver-authent>
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.856580    1791 shared_informer.go:311] Waiting for caches to sync for client-ca::kube-system::extension-apiserver-authenticatio>
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.856576    1791 shared_informer.go:311] Waiting for caches to sync for client-ca::kube-system::extension-apiserver-authenticatio>
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.856947    1791 shared_informer.go:311] Waiting for caches to sync for RequestHeaderAuthRequestController
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.856957    1791 secure_serving.go:210] Serving securely on 0.0.0.0:10259
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.857010    1791 tlsconfig.go:240] "Starting DynamicServingCertificateController"
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.957634    1791 shared_informer.go:318] Caches are synced for RequestHeaderAuthRequestController
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.957673    1791 shared_informer.go:318] Caches are synced for client-ca::kube-system::extension-apiserver-authentication::reques>
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.957635    1791 shared_informer.go:318] Caches are synced for client-ca::kube-system::extension-apiserver-authentication::client>
сен 24 11:08:26 node180 kube-scheduler[1791]: I0924 11:08:26.958393    1791 leaderelection.go:250] attempting to acquire leader lease kube-system/kube-scheduler...

root@node180:~# systemctl status kube-proxy.service
● kube-proxy.service - Kubernetes Kube Proxy
     Loaded: loaded (/lib/systemd/system/kube-proxy.service; enabled; preset: enabled)
     Active: active (running) since Sun 2023-09-24 11:08:29 +05; 21min ago
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 1943 (kube-proxy)
      Tasks: 8 (limit: 9483)
     Memory: 67.9M
        CPU: 30.704s
     CGroup: /system.slice/kube-proxy.service
             └─1943 /usr/local/bin/kube-proxy --config=/etc/kubernetes/kube-proxy.yaml --v=2

сен 24 11:28:15 node180 kube-proxy[1943]: I0924 11:28:15.247349    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:28:25 node180 kube-proxy[1943]: I0924 11:28:25.235194    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:28:35 node180 kube-proxy[1943]: I0924 11:28:35.243215    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:28:45 node180 kube-proxy[1943]: I0924 11:28:45.239403    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:28:55 node180 kube-proxy[1943]: I0924 11:28:55.243107    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:29:05 node180 kube-proxy[1943]: I0924 11:29:05.227127    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:29:15 node180 kube-proxy[1943]: I0924 11:29:15.247439    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:29:25 node180 kube-proxy[1943]: I0924 11:29:25.243000    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:29:35 node180 kube-proxy[1943]: I0924 11:29:35.239395    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}
сен 24 11:29:45 node180 kube-proxy[1943]: I0924 11:29:45.234960    1943 proxier.go:1463] "Removing addresses" interface="kube-ipvs0" addresses={"11.0.11.22":{}}


root@node180:~# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.200.180:31347 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  192.168.200.180:31577 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
TCP  192.168.200.180:32567 rr
  -> 10.96.1.82:9153              Masq    1      0          0
  -> 10.96.2.39:9153              Masq    1      0          0
TCP  192.168.200.180:32675 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  192.168.201.180:31347 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  192.168.201.180:31577 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
TCP  192.168.201.180:32567 rr
  -> 10.96.1.82:9153              Masq    1      0          0
  -> 10.96.2.39:9153              Masq    1      0          0
TCP  192.168.201.180:32675 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  192.168.202.180:31347 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  192.168.202.180:31577 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
TCP  192.168.202.180:32567 rr
  -> 10.96.1.82:9153              Masq    1      0          0
  -> 10.96.2.39:9153              Masq    1      0          0
TCP  192.168.202.180:32675 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  192.168.203.180:31347 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  192.168.203.180:31577 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
TCP  192.168.203.180:32567 rr
  -> 10.96.1.82:9153              Masq    1      0          0
  -> 10.96.2.39:9153              Masq    1      0          0
TCP  192.168.203.180:32675 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  10.96.128.1:443 rr
  -> 192.168.200.180:6443         Masq    1      0          0
.........
TCP  10.96.128.10:53 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
TCP  10.96.128.10:9153 rr
  -> 10.96.1.82:9153              Masq    1      0          0
  -> 10.96.2.39:9153              Masq    1      0          0
TCP  10.96.142.77:443 rr
  -> 10.96.1.56:4443              Masq    1      0          0
  -> 10.96.2.213:4443             Masq    1      2          0
TCP  10.96.145.197:9402 rr
  -> 10.96.3.91:9402              Masq    1      0          0
TCP  10.96.150.58:443 rr
  -> 10.96.2.221:9443             Masq    1      0          0
TCP  10.96.155.175:8000 rr
  -> 10.96.3.81:8000              Masq    1      0          0
TCP  10.96.177.219:3306 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  10.96.200.140:3306 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  10.96.227.156:443 rr
TCP  10.96.255.238:443 rr
  -> 10.96.3.69:10250             Masq    1      0          0
TCP  11.0.0.0:3306 rr
  -> 10.96.1.5:3306               Masq    1      0          0
TCP  11.0.11.22:53 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
TCP  11.0.11.22:9153 rr
  -> 10.96.1.82:9153              Masq    1      0          0
  -> 10.96.2.39:9153              Masq    1      0          0
UDP  192.168.200.180:30226 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
UDP  192.168.201.180:30226 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
UDP  192.168.202.180:30226 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
UDP  192.168.203.180:30226 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
UDP  10.96.128.10:53 rr
  -> 10.96.1.82:53                Masq    1      0          0
  -> 10.96.2.39:53                Masq    1      0          0
.........


node180# sh ip bgp
BGP table version is 5615, local router ID is 192.168.203.180, vrf id 0
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
*=i11.0.0.0/32      192.168.200.172               100      0 i
*=i                 192.168.200.171               100      0 i
*>i                 192.168.200.170               100      0 i
*>i11.0.11.22/32    192.168.200.170               100      0 i
*=i                 192.168.200.171               100      0 i
*=i                 192.168.200.172               100      0 i
*> 192.168.200.0/24 0.0.0.0                  0         32768 ?
*> 192.168.201.0/24 0.0.0.0                  0         32768 ?
*> 192.168.202.0/24 0.0.0.0                  0         32768 ?
*> 192.168.203.0/24 0.0.0.0                  0         32768 ?

Displayed  9 routes and 13 total paths
node180# sh ip bgp summary

IPv4 Unicast Summary (VRF default):
BGP router identifier 192.168.203.180, local AS number 65000 vrf-id 0
BGP table version 5626
RIB entries 17, using 3264 bytes of memory
Peers 3, using 2172 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.200.170 4      65000     11782        72        0    0    0 00:24:52            3        5 N/A
192.168.200.171 4      65000     11790        72        0    0    0 00:24:45            3        5 N/A
192.168.200.172 4      65000     11787        69        0    0    0 00:23:15            3        5 N/A

Total number of neighbors 3
node180#

```
