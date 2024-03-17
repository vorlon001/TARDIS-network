#!/bin/sh

set -x
# ./kubeadm.amd64.v1.25.0 config images list
#https://storage.googleapis.com/kubernetes-release/release/v1.26.0-rc.0/bin/linux/amd64/kubelet

export kube_version="v1.29.3"
export kube_version2="1.29.3"
export crictl_version="v1.29.0"
export containerd_version="1.7.14"
export image_arch="amd64"
export runc_version="1.1.12"
export cni_version="1.4.1"
export k8s_regestry="harbor.iblog.pro/registry.k8s.io"
export etcd_version="3.5.12"

wget -q --show-progress --https-only --timestamping https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-amd64.tar.gz
wget -q --show-progress --https-only --timestamping https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.${image_arch}
wget -q --show-progress --https-only --timestamping https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
wget -q --show-progress --https-only --timestamping https://github.com/containernetworking/plugins/releases/download/v${cni_version}/cni-plugins-linux-${image_arch}-v${cni_version}.tgz

curl -o kubelet.${image_arch}.${kube_version} https://storage.googleapis.com/kubernetes-release/release/${kube_version}/bin/linux/${image_arch}/kubelet
curl -o kubectl.${image_arch}.${kube_version} https://storage.googleapis.com/kubernetes-release/release/${kube_version}/bin/linux/${image_arch}/kubectl
curl -o kubeadm.${image_arch}.${kube_version} https://storage.googleapis.com/kubernetes-release/release/${kube_version}/bin/linux/${image_arch}/kubeadm
wget -q --show-progress --https-only --timestamping https://github.com/kubernetes-sigs/cri-tools/releases/download/${crictl_version}/crictl-${crictl_version}-linux-amd64.tar.gz

wget -q --show-progress --https-only --timestamping https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_amd64 https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssljson_1.6.5_linux_amd64

wget -q --show-progress --https-only --timestamping https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/etcd-v${etcd_version}-linux-${image_arch}.tar.gz


wget -q --show-progress --https-only --timestamping -O kubernetes-server-linux-amd64.${kube_version2}.tar.gz https://storage.googleapis.com/kubernetes-release/release/v${kube_version2}/kubernetes-server-linux-amd64.tar.gz
