#!/usr/bin/bash

cp /root/init.etcd/apiserver.pem /etc/kubernetes/pki/apiserver-etcd.pem
cp /root/init.etcd/apiserver-key.pem /etc/kubernetes/pki/apiserver-etcd-key.pem

export kube_version="v1.29.1"
export kube_version2="1.29.1"
export crictl_version="v1.29.0"
export containerd_version="1.7.12"
export image_arch="amd64"
export runc_version="1.1.11"
export cni_version="1.4.0"
export k8s_regestry="harbor.iblog.pro/registry.k8s.io"
export etcd_version="3.5.11"

export IPREFIX="192.168.200"
export CLUSTERIP="189"
export NODE="180"
#export IPSENABLE=1
#export CGROUPDRIVER=1
export clusterName="cluster.local"
export podSubnet="10.96.0.0/17"
export serviceSubnet="10.96.128.0/17"

# "iblog.pro"

mkdir -p /etc/kubernetes/policies/
mkdir -p /var/log/kube-audit
cp audit-policy.yaml /etc/kubernetes/policies/

cat <<EOF > kubeadm.yml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: bu5tiw.iq1i8h3t740fgy0l
  ttl: 120h0m0s
  usages:
  - signing
  - authentication
localAPIEndpoint:
  advertiseAddress: ${IPREFIX}.${NODE}
  bindPort: 6443
nodeRegistration:
#  criSocket: /run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: node${NODE}
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
certificatesDir: /etc/kubernetes/pki
imageRepository: ${k8s_regestry}
clusterName: ${clusterName}
kubernetesVersion: "${kube_version}"
controlPlaneEndpoint: ${IPREFIX}.${CLUSTERIP}:6443
apiServer:
  extraArgs:
    audit-log-format: json
    audit-log-maxage: "7"
    audit-log-maxbackup: "10"
    audit-log-maxsize: "100"
    audit-log-path: /var/log/kube-audit/audit.log
    audit-policy-file: /etc/kubernetes/policies/audit-policy.yaml
#    oidc-issuer-url: "https://keycloak.iblog.pro/auth/realms/test2"
#    oidc-client-id: "kubernetes"
#    oidc-ca-file: "/etc/kubernetes/pki/kc-ca.pem"
#    oidc-username-claim: "username"
#    oidc-groups-claim: "groups"
#    oidc-username-prefix: "oidc:"
  extraVolumes:
  - hostPath: /etc/kubernetes/policies
    mountPath: /etc/kubernetes/policies
    name: policies
    pathType: DirectoryOrCreate
    readOnly: true
  - hostPath: /var/log/kube-audit
    mountPath: /var/log/kube-audit
    name: logs
    pathType: DirectoryOrCreate
  timeoutForControlPlane: 4m0s
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
    node-cidr-mask-size-ipv4: "24"
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
dns: {}
etcd:
    external:
        endpoints:
        - https://192.168.200.180:2379
        - https://192.168.200.181:2379
        - https://192.168.200.182:2379
        caFile: /etc/etcd/ca.pem
        certFile: /etc/kubernetes/pki/apiserver-etcd.pem
        keyFile: /etc/kubernetes/pki/apiserver-etcd-key.pem
networking:
  dnsDomain: ${clusterName}
  podSubnet: ${podSubnet}
  serviceSubnet: ${serviceSubnet}
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
systemReserved:
  cpu: 500m
  memory: 1000Mi
kubeReserved:
  cpu: 500m
  memory: 500Mi
evictionHard:
  memory.available: "300Mi"
  nodefs.available: "15%"
  nodefs.inodesFree: "5%"
  imagefs.available: "15%"
evictionMinimumReclaim:
  memory.available: "500Mi"
  nodefs.available: "2Gi"
  imagefs.available: "2Gi"
#cgroupRoot: /kubepod.cluster        ##need #
kubeletCgroups: /kubelet.slice
#systemCgroups: /k8s.system.slice
#kubeReservedCgroup: /kube.slice     ##need #
#systemReservedCgroup: /system.slice ##need #
maxPods: 40
containerLogMaxSize: "10Mi"
containerLogMaxFiles: 5
maxParallelImagePulls: 5
podPidsLimit: 1000000
maxOpenFiles: 1000000
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF

# ipvsadm -ln
sudo cat  kubeadm.yml


mkdir /sys/fs/cgroup/kubepod.cluster.slice/

kubeadm config migrate --old-config kubeadm.yml  --new-config kubeadm.v3.yml
kubeadm init --config=./kubeadm.yml  --skip-phases  certs

rm -R  $HOME/.kube
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


kubectl get nodes,pod -A -o wide
kubectl taint nodes --all node-role.kubernetes.io/master-

