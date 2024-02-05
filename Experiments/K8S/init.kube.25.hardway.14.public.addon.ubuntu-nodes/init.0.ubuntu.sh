#!/usr/bin/bash

set -x

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


export DEBIAN_FRONTEND=noninteractive

export kube_version="v1.29.1"
export kube_version2="1.29.1"
export crictl_version="v1.29.0"
export containerd_version="1.7.12"
export image_arch="amd64"
export runc_version="1.1.11"
export cni_version="1.4.0"
export k8s_regestry="harbor.iblog.pro/registry.k8s.io"
export etcd_version="3.5.11"

export LANG=ru_RU.UTF-8
export VERSION=$(lsb_release -cs)
#jammy

function set_locale {
apt autoremove -y && \
apt-get install -y locales mc && \
    sed -i -e "s/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/" /etc/locale.gen && \
    sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG
}

function set_dns_resolv_conf {
echo "nameserver 192.168.1.10" >>/etc/resolv.conf
}

function apt_source_debian {

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF>/etc/apt/sources.list
deb https://nexus3.iblog.pro/repository/deb.debian.org/debian ${VERSION} main
deb https://nexus3.iblog.pro/repository/deb.debian.org/debian ${VERSION} non-free
deb https://nexus3.iblog.pro/repository/deb.debian.org/debian ${VERSION}-updates main
deb https://nexus3.iblog.pro/repository/deb.debian.org/debian ${VERSION}-updates non-free
deb https://nexus3.iblog.pro/repository/deb.debian.org/debian ${VERSION}-backports main
deb https://nexus3.iblog.pro/repository/deb.debian.org/debian ${VERSION}-backports non-free
deb https://nexus3.iblog.pro/repository/deb.debian.org/debian-security ${VERSION}-security main
deb https://nexus3.iblog.pro/repository/deb.debian.org/debian-security ${VERSION}-security non-free
EOF
}

function apt_source_ubuntu {
cat >/etc/apt/sources.list <<EOF
deb https://nexus3.iblog.pro/repository/archive.ubuntu.com/ ${VERSION} main restricted
deb https://nexus3.iblog.pro/repository/archive.ubuntu.com/ ${VERSION}-updates main restricted
deb https://nexus3.iblog.pro/repository/archive.ubuntu.com/ ${VERSION} universe
deb https://nexus3.iblog.pro/repository/archive.ubuntu.com/ ${VERSION}-updates universe
deb https://nexus3.iblog.pro/repository/archive.ubuntu.com/ ${VERSION} multiverse
deb https://nexus3.iblog.pro/repository/archive.ubuntu.com/ ${VERSION}-updates multiverse
deb https://nexus3.iblog.pro/repository/archive.ubuntu.com/ ${VERSION}-backports main restricted universe multiverse
deb https://nexus3.iblog.pro/repository/security.ubuntu.com/ ${VERSION}-security main restricted
deb https://nexus3.iblog.pro/repository/security.ubuntu.com/ ${VERSION}-security universe
deb https://nexus3.iblog.pro/repository/security.ubuntu.com/ ${VERSION}-security multiverse
#deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://nexus3.iblog.pro/repository/download.docker.com/  hirsute stable
#deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://nexus3.iblog.pro/repository/download-docker-com-linux-ubuntu-hirsute/  ${VERSION} stable
deb https://nexus3.iblog.pro/repository/apt.kubernetes.io/ kubernetes-xenial main
EOF
}

function apt_install_deb {
apt-get install locales-all -y
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release nfs-common
}

function set_modules_kernel {

cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

cat <<EOF>>/etc/security/limits.conf
*        soft    nproc            65535
*        soft    nproc            65535
*        soft    nofile            65535
*        hard    nofile            65535
EOF

sysctl --system

}


#wget https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-amd64.tar.gz
#wget https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64
#wget https://github.com/containernetworking/plugins/releases/download/v${cni_version}/cni-plugins-linux-amd64-v${cni_version}.tgz

function init_containerd {
tar Cxzvf /usr/local ./IMAGES/containerd-${containerd_version}-linux-amd64.tar.gz
#wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
cp ./containerd.service /etc/systemd/system/containerd.service
install -m 755 ./IMAGES/runc.${image_arch} /usr/local/sbin/runc
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin ./IMAGES/cni-plugins-linux-${image_arch}-v${cni_version}.tgz

mkdir -p /etc/containerd && \
containerd config default | sudo tee /etc/containerd/config.toml
sed -i -e "s|            SystemdCgroup = false|            SystemdCgroup = true|" /etc/containerd/config.toml
sed -i -e 's|    sandbox_image = "registry.k8s.io/pause:3.8"|    sandbox_image = "harbor.iblog.pro/registry.k8s.io/pause:3.9"|' /etc/containerd/config.toml
sed -i -e 's|      config_path = ""|      config_path = "/etc/containerd/certs.d"|' /etc/containerd/config.toml
cp -R ./CONTAINERED.CONF/certs.d /etc/containerd
systemctl daemon-reload
systemctl enable --now containerd
systemctl status containerd
cat /etc/containerd/config.toml | grep SystemdCgroup

ctr images pull docker.io/library/redis:alpine
ctr images ls
}

function set_crictl_config {
cat <<EOF | sudo tee  /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 30
debug: false
EOF
}


function install_k8s_utils {

kube_bin_dir="/usr/bin"
kube_config_dir="/etc/kubernetes"
#curl -o kubelet https://storage.googleapis.com/kubernetes-release/release/${kube_version}/bin/linux/${image_arch}/kubelet
#curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/${kube_version}/bin/linux/${image_arch}/kubectl
#curl -o kubeadm https://storage.googleapis.com/kubernetes-release/release/${kube_version}/bin/linux/${image_arch}/kubeadm
#wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${crictl_version}/crictl-${crictl_version}-linux-amd64.tar.gz
tar Cxzvf /usr/local/bin ./IMAGES/crictl-${crictl_version}-linux-amd64.tar.gz
chmod +x /usr/local/bin/crictl


chmod +x ./IMAGES/kubeadm.amd64.${kube_version}
chmod +x ./IMAGES/kubectl.amd64.${kube_version}
chmod +x ./IMAGES/kubelet.amd64.${kube_version}

mv ./IMAGES/kubeadm.amd64.${kube_version} ${kube_bin_dir}/kubeadm
mv ./IMAGES/kubectl.amd64.${kube_version} ${kube_bin_dir}/kubectl
mv ./IMAGES/kubelet.amd64.${kube_version} ${kube_bin_dir}/kubelet

mkdir -p ${kube_config_dir}
apt -y install iptables iproute2 socat util-linux mount ebtables ethtool conntrack
mkdir -p /etc/systemd/system/kubelet.service.d/

}

function install_kubelet {

cat <<EOF>/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_CONFIG_ARGS \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS
EOF


cat <<EOF>/lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF


systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet

}



function kubeadm_image_pull {

kubeadm config images pull --image-repository ${k8s_regestry} --kubernetes-version ${kube_version}

}


set_locale || throw ${LINENO}
set_dns_resolv_conf || throw ${LINENO}
#apt_source_debian || throw ${LINENO}
apt_source_ubuntu || throw ${LINENO}
apt_install_deb || throw ${LINENO}
set_modules_kernel || throw ${LINENO}

init_containerd || throw ${LINENO}
set_crictl_config || throw ${LINENO}
install_k8s_utils || throw ${LINENO}
install_kubelet || throw ${LINENO}
kubeadm_image_pull || throw ${LINENO}

# fix - file_linux.go:61] "Unable to read config path" err="path does not exist, ignoring" path="/etc/kubernetes/manifests"
mkdir -p /etc/kubernetes/manifests || throw ${LINENO}
