## RKE2 Example 3

### init first Master

```
curl -sfL https://get.rke2.io | sh -

systemctl enable rke2-server.service

mkdir -p /etc/rancher/rke2
cat <<EOF>/etc/rancher/rke2/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://nexus3-docker-io.iblog.pro"
configs:
  "nexus3-docker-io.iblog.pro":
    tls:
      insecure_skip_verify: true
EOF

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
private-registry: /etc/rancher/rke2/registries.yaml
disable: rke2-ingress-nginx
system-default-registry: nexus3-docker-io.iblog.pro
EOF

systemctl start rke2-server.service

journalctl -u rke2-server -f
```


### Init Master 2, 3

```shell

# Master 2,3

## on master one
## cat /var/lib/rancher/rke2/server/node-token
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

systemctl enable rke2-agent.service

mkdir -p /etc/rancher/rke2
cat <<EOF>/etc/rancher/rke2/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://nexus3-docker-io.iblog.pro"
configs:
  "nexus3-docker-io.iblog.pro":
    tls:
      insecure_skip_verify: true
EOF

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
private-registry: /etc/rancher/rke2/registries.yaml
disable: rke2-ingress-nginx
system-default-registry: nexus3-docker-io.iblog.pro
server: https://<VIP IP>:9345
token: <TOKEN>
tls-san:
  - <IP MASRER 2,3>
EOF

systemctl start rke2-server.service


```


### Init and Join Worker

```shell
# Join Worker
cat /var/lib/rancher/rke2/server/agent-token
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

systemctl enable rke2-agent.service

mkdir -p /etc/rancher/rke2
cat <<EOF>/etc/rancher/rke2/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://nexus3-docker-io.iblog.pro"
configs:
  "nexus3-docker-io.iblog.pro":
    tls:
      insecure_skip_verify: true
EOF

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
private-registry: /etc/rancher/rke2/registries.yaml
server: https://<BIP IP>:9345
token: <TOKEN>
EOF

systemctl start rke2-agent.service

```



### RKE2 Upgrade Manual

### v1.25.12+rke2r1 -> v1.27.4+rke2r1

```shell

curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=v1.27.4+rke2r1 sh -

# Remember to restart the rke2 process after installing:

# Server nodes:
systemctl restart rke2-server

# Agent nodes:
systemctl restart rke2-agent

```

### RKE2 Upgrade auto



Install the system-upgrade-controller
The system-upgrade-controller can be installed as a deployment into your cluster. The deployment requires a service-account, clusterRoleBinding, and a configmap. To install these components, run the following command:

```shell
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.9.1/system-upgrade-controller.yaml
```

The controller can be configured and customized via the previously mentioned configmap, but the controller must be redeployed for the changes to be applied.

Configure plans
It is recommended that you minimally create two plans: a plan for upgrading server (master / control-plane) nodes and a plan for upgrading agent (worker) nodes. As needed, you can create additional plans to control the rollout of the upgrade across nodes. The following two example plans will upgrade your cluster to rke2 v1.23.1+rke2r2. Once the plans are created, the controller will pick them up and begin to upgrade your cluster.

```yaml
# Server plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: server-plan
  namespace: system-upgrade
  labels:
    rke2-upgrade: server
spec:
  concurrency: 1
  nodeSelector:
    matchExpressions:
       - {key: rke2-upgrade, operator: Exists}
       - {key: rke2-upgrade, operator: NotIn, values: ["disabled", "false"]}
       # When using k8s version 1.19 or older, swap control-plane with master
       - {key: node-role.kubernetes.io/control-plane, operator: In, values: ["true"]}
  serviceAccountName: system-upgrade
  cordon: true
#  drain:
#    force: true
  upgrade:
    image: rancher/rke2-upgrade
  version: v1.27.4+rke2r1
---
# Agent plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: agent-plan
  namespace: system-upgrade
  labels:
    rke2-upgrade: agent
spec:
  concurrency: 2
  nodeSelector:
    matchExpressions:
      - {key: rke2-upgrade, operator: Exists}
      - {key: rke2-upgrade, operator: NotIn, values: ["disabled", "false"]}
      # When using k8s version 1.19 or older, swap control-plane with master
      - {key: node-role.kubernetes.io/control-plane, operator: NotIn, values: ["true"]}
  prepare:
    args:
    - prepare
    - server-plan
    image: rancher/rke2-upgrade
  serviceAccountName: system-upgrade
  cordon: true
  drain:
    force: true
  upgrade:
    image: rancher/rke2-upgrade
  version: v1.23.1-rke2r2
```
