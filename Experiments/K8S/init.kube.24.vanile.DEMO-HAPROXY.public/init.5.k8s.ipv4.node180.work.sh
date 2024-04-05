#!/usr/bin/bash

function throw()
{
   errorCode=$?
   echo "Error: ($?) LINENO:$1"
   exit $errorCode
}

function check_error {
  if [ $? -ne 0 ]; then
    echo "Error: ($?) LINENO:$1"
    exit 1
  fi
}

export kube_version="v1.29.3"
export kube_version2="1.29.3"
export crictl_version="v1.29.0"
export containerd_version="1.7.14"
export image_arch="amd64"
export runc_version="1.1.12"
export cni_version="1.4.1"
export k8s_regestry="harbor.iblog.pro/registry.k8s.io"
export etcd_version="3.5.12"

export IPREFIX="192.168.200"
export CLUSTERIP="186"
export NODE="180"
#export IPSENABLE=1
#export CGROUPDRIVER=1
export clusterName="cluster.local"
export podSubnet="10.96.0.0/17"
export serviceSubnet="10.96.128.0/17"


# kubectl approval
# CSRs can be approved outside of the approval flows built into the controller manager.
#
# The signing controller does not immediately sign all certificate requests. Instead, it waits until they have been flagged with an "Approved" status by an appropriately-privileged user. This flow is intended to allow for automated approval handled by an external approval controller or the approval controller implemented in the core controller-manager. However cluster administrators can also manually approve certificate requests using kubectl. An administrator can list CSRs with kubectl get csr and describe one in detail with kubectl describe csr <name>. An administrator can approve or deny a CSR with kubectl certificate approve <name> and kubectl certificate deny <name>.
# kubectl approval 
# деплой сервиса kubelet-csr-approver https://github.com/postfinance/kubelet-csr-approver/tree/main/deploy/k8s
#
# ---
# apiVersion: kubelet.config.k8s.io/v1beta1
# kind: KubeletConfiguration
# serverTLSBootstrap: true


# "iblog.pro"

mkdir -p /etc/kubernetes/policies/ || throw ${LINENO}
mkdir -p /var/log/kube-audit || throw ${LINENO}
cp audit-policy.yaml /etc/kubernetes/policies/ || throw ${LINENO}

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
  timeoutForControlPlane: 4m0s
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
    node-cidr-mask-size-ipv4: "24"
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
dns: {}
networking:
  dnsDomain: ${clusterName}
  podSubnet: ${podSubnet}
  serviceSubnet: ${serviceSubnet}
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF

# ipvsadm -ln
sudo cat  kubeadm.yml || throw ${LINENO}


if [ ! -d "/sys/fs/cgroup/kubepod.cluster.slice/" ]
then
    echo "Directory /sys/fs/cgroup/kubepod.cluster.slice/ DOES NOT exists."
    mkdir /sys/fs/cgroup/kubepod.cluster.slice/ || throw ${LINENO}
fi

#mkdir /sys/fs/cgroup/k8s.system.slice

kubeadm config migrate --old-config kubeadm.yml  --new-config kubeadm.v3.yml || throw ${LINENO}
kubeadm init --config=./kubeadm.yml || throw ${LINENO}


[ -d " $HOME/.kube" ] && [ ! -L " $HOME/.kube" ] && rm -R  $HOME/.kube

mkdir -p $HOME/.kube || throw ${LINENO}
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config || throw ${LINENO}
sudo chown $(id -u):$(id -g) $HOME/.kube/config || throw ${LINENO}


kubectl get nodes,pod -A -o wide || throw ${LINENO}
kubectl taint nodes --all node-role.kubernetes.io/master- || throw ${LINENO}

