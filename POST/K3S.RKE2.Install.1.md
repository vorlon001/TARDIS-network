## K3S
### First Master
```shell
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
     --cluster-init \
     --tls-san=192.168.200.186 --disable=traefik
```
### Join Master 2,3
```shell
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
    --server https://192.168.200.186:6443 \
    --tls-san=192.168.200.181 --disable=traefik 

curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
    --server https://192.168.200.186:6443 \
    --tls-san=192.168.200.182 --disable=traefik 
```
### Join worker
```shell
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.200.186:6443 K3S_TOKEN=SECRET sh -
```


## RKE2 Example 1
### Init first Cluster
```shell

curl -sfL https://get.rke2.io | sh -

systemctl enable rke2-server.service
systemctl start rke2-server.service

journalctl -u rke2-server -f

```

A token that can be used to register other server or agent nodes will be created at /var/lib/rancher/rke2/server/node-token

### ACCESS to Cluster
```shell
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
kubectl get pods --all-namespaces -o wide
helm ls --all-namespaces
```
Or specify the location of the kubeconfig file in the command:
```shell
kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods --all-namespaces
helm --kubeconfig /etc/rancher/rke2/rke2.yaml ls --all-namespaces
```
### RKE2 Join WORKER
```shell

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

systemctl enable rke2-agent.service

mkdir -p /etc/rancher/rke2/
cat <<EOF>/etc/rancher/rke2/config.yaml
server: https://<VIP-IP>:9345
token: <TOKEN>
EOF

systemctl start rke2-agent.service

journalctl -u rke2-agent -f
```

### RKE2 Join Master 2,3

```shell
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
systemctl enable rke2-agent.service

mkdir -p  /etc/rancher/rke2
cat <<EOF>/etc/rancher/rke2/config.yaml
server: https://<VIP-IP>:9345
token: <TOKEN>
tls-san:
  - <IP MASTER 2 or 3>
EOF

systemctl start rke2-server.service

journalctl -u rke2-server -f
```

## Docs

#### To do so, pass cilium as the value of the --cni
#### To do so, pass `calico` as the value of the `--cni` flag.
#### /var/lib/rancher/rke2/server/manifests/rke2-canal-config.yaml
```yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-canal
  namespace: kube-system
spec:
  valuesContent: |-
    flannel:
      iface: "eth1"
```


#### /var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml
```yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    eni:
      enabled: true
```

#### /var/lib/rancher/rke2/server/manifests/rke2-calico-config.yaml
```yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-calico
  namespace: kube-system
spec:
  valuesContent: |-
    installation:
      calicoNetwork:
        mtu: 9000
```

#### Dual-stack configuration

IPv4/IPv6 dual-stack networking enables the allocation of both IPv4 and IPv6 addresses to Pods and Services. It is supported in RKE2 since v1.21, stable since v1.23 but not activated by default. To activate it correctly, both RKE2 and the chosen CNI plugin must be configured accordingly. To configure RKE2 in dual-stack mode, in the control-plane nodes, you must set a valid IPv4/IPv6 dual-stack cidr for pods and services. To do so, use the flags --cluster-cidr and --service-cidr for example:
```yaml
#/etc/rancher/rke2/config.yaml
cluster-cidr: "10.42.0.0/16,2001:cafe:42:0::/56"
service-cidr: "10.43.0.0/16,2001:cafe:42:1::/112"
```

#### With TLS
#### Below are examples showing how you may configure /etc/rancher/rke2/registries.yaml on each node when using TLS.
#### With Authentication:
```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://registry.example.com:5000"
configs:
  "registry.example.com:5000":
    auth:
      username: xxxxxx # this is the registry username
      password: xxxxxx # this is the registry password
    tls:
      cert_file:            # path to the cert file used to authenticate to the registry
      key_file:             # path to the key file for the certificate used to authenticate to the registry
      ca_file:              # path to the ca file used to verify the registry's certificate
      insecure_skip_verify: # may be set to true to skip verifying the registry's certificate
```
#### Without Authentication:
```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://registry.example.com:5000"
configs:
  "registry.example.com:5000":
    tls:
      cert_file:            # path to the cert file used to authenticate to the registry
      key_file:             # path to the key file for the certificate used to authenticate to the registry
      ca_file:              # path to the ca file used to verify the registry's certificate
      insecure_skip_verify: # may be set to true to skip verifying the registry's certificate
```

## RKE2 Example 2, CNI: Cilium, w/o nginx-ingress
### First Master
```shell
curl -sfL https://get.rke2.io | sh -

systemctl enable rke2-server.service

mkdir -p /var/lib/rancher/rke2/server/manifests/
cat <<EOF>/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    eni:
      enabled: true
EOF

mkdir -p /etc/rancher/rke2
cat <<EOF>/etc/rancher/rke2/config.yaml
cni:
- cilium
disable: rke2-ingress-nginx
EOF

systemctl start rke2-server.service

journalctl -u rke2-server -f
```

A token that can be used to register other server or agent nodes will be created at /var/lib/rancher/rke2/server/node-token

### ACCESS to Cluster
```shell
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
kubectl get pods,node  --all-namespaces -o wide
helm ls --all-namespaces
```
Or specify the location of the kubeconfig file in the command:
```shell
kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods --all-namespaces
helm --kubeconfig /etc/rancher/rke2/rke2.yaml ls --all-namespaces
```
### RKE2 Join WORKER
```shell
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

systemctl enable rke2-agent.service

mkdir -p /var/lib/rancher/rke2/server/manifests/
cat <<EOF>/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    eni:
      enabled: true
EOF

mkdir -p /etc/rancher/rke2
cat <<EOF>/etc/rancher/rke2/config.yaml
cni:
- cilium
disable: rke2-ingress-nginx
server: https://<VIP-IP>:9345
token: <TOKEN>
EOF

systemctl start rke2-agent.service

journalctl -u rke2-agent -f
```

### RKE2 Join Master 2,3
 
```shell

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
systemctl enable rke2-agent.service

mkdir -p /var/lib/rancher/rke2/server/manifests/
cat <<EOF>/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    eni:
      enabled: true
EOF

mkdir -p /etc/rancher/rke2
cat <<EOF>/etc/rancher/rke2/config.yaml
cni:
- cilium
disable: rke2-ingress-nginx
server: https://<VIP-IP>:9345
token: <TOKEN>
tls-san:
  - <IP MASTER 2,3>
EOF

systemctl start rke2-server.service

journalctl -u rke2-server -f
```





## ADDON
```shell

https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.28.0/crictl-v1.28.0-linux-amd64.tar.gz

cat <<EOF>/etc/crictl.yaml
runtime-endpoint: unix:///run/k3s/containerd/containerd.sock
image-endpoint: unix:///run/k3s/containerd/containerd.sock
timeout: 10
debug: true
EOF

```
