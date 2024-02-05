#!/usr/bin/bash

CONTROL_PLANE_IP=192.168.200.189
KUBERNETES_VERSION=1.29.1
TOKEN=bu5tiw.iq1i8h3t740fgy0l

SHA256_TOKEN=$(openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)

export INTERFACE_KEEPALIVED_VIP="enp1s0.200"


NODEID=$(hostname | awk '{print $1}' | sed 's|node||')


echo 'export INTERFACE_KEEPALIVED_VIP="enp1s0.200"'
echo "export INTERNAL_IP=\$(ifconfig \${INTERFACE_KEEPALIVED_VIP} | grep inet\\   | awk '{print \$2}')"

export K8SINITCMD=$(kubeadm token create --print-join-command 2>&1 | grep -o -E '^kubeadm join .*')
export UPLOADTLSKEY=$(kubeadm init phase upload-certs --upload-certs 2>&1 | grep -o -E '^[[:alnum:]]{64}')


cat <<EOF > join-worker.yaml
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
controlPlaneEndpoint: ${CONTROL_PLANE_IP}:6443
kubernetesVersion: ${KUBERNETES_VERSION}
apiServer:
  timeoutForControlPlane: 4m0s
certificatesDir: /etc/kubernetes/pki
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
certificateKey: ${UPLOADTLSKEY}
discovery:
  bootstrapToken:
    apiServerEndpoint: ${CONTROL_PLANE_IP}:6443
    token: ${TOKEN}
    caCertHashes: ["sha256:${SHA256_TOKEN}"]
nodeRegistration:
  taints: null
EOF

echo "mkdir /sys/fs/cgroup/kubepod.cluster.slice/"
echo "cat <<EOF > join-worker.yaml"
cat join-worker.yaml
echo "EOF"
echo "kubeadm join --config=./join-worker.yaml"

echo "OR"
echo "${K8SINITCMD} --certificate-key ${UPLOADTLSKEY}  --control-plane"
