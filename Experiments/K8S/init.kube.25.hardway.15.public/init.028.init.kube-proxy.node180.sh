#!/usr/bin/bash


apt install ipset ipvsadm -y

cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
nf_conntrack
EOF

modprobe nf_conntrack
modprobe br_netfilter
modprobe overlay


export INTERFACE_KEEPALIVED_VIP="enp1s0.200"
export INTERNAL_IP=$(ifconfig ${INTERFACE_KEEPALIVED_VIP} | grep inet\   | awk '{print $2}')


kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/pki/ca.crt     \
  --embed-certs=true     \
  --server=https://${INTERNAL_IP}:6443     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy  \
  --client-certificate=/etc/kubernetes/pki/kube-proxy.crt     \
  --client-key=/etc/kubernetes/pki/kube-proxy.key     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-context kube-proxy@kubernetes    \
  --cluster=kubernetes     \
  --user=kube-proxy     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config use-context kube-proxy@kubernetes  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig



cat >  /usr/lib/systemd/system/kube-proxy.service << EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/etc/kubernetes/kube-proxy.yaml \\
  --v=2
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF

apt install ipset ipvsadm -y

cat > /etc/kubernetes/kube-proxy.yaml << EOF
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: ${INTERNAL_IP}
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
  qps: 5
clusterCIDR: 10.96.0.0/17
configSyncPeriod: 15m0s
conntrack:
  max: null
  maxPerCore: 32768
  min: 131072
  tcpCloseWaitTimeout: 1h0m0s
  tcpEstablishedTimeout: 24h0m0s
enableProfiling: false
healthzBindAddress: 0.0.0.0:10256
hostnameOverride: ""
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
ipvs:
  masqueradeAll: true
  minSyncPeriod: 5s
  scheduler: "rr"
  syncPeriod: 30s
kind: KubeProxyConfiguration
metricsBindAddress: ${INTERNAL_IP}:10249
mode: "ipvs"
nodePortAddresses: null
oomScoreAdj: -999
portRange: ""
udpIdleTimeout: 250ms
EOF

systemctl daemon-reload
systemctl enable --now kube-proxy.service
systemctl restart kube-proxy.service
systemctl status kube-proxy.service



