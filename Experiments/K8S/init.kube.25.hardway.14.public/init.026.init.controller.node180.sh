#!/usr/bin/bash

export INTERFACE_KEEPALIVED_VIP="enp1s0.200"
export INTERNAL_IP=$(ifconfig ${INTERFACE_KEEPALIVED_VIP} | grep inet\   | awk '{print $2}')



cat > /usr/lib/systemd/system/kube-controller-manager.service << EOF

[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
    --allocate-node-cidrs=true \\
    --authentication-kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
    --authorization-kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
    --bind-address=0.0.0.0 \\
    --client-ca-file=/etc/kubernetes/pki/ca.crt \\
    --cluster-cidr=10.96.0.0/17 \\
    --cluster-name=cluster.local \\
    --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt \\
    --cluster-signing-key-file=/etc/kubernetes/pki/ca.key \\
    --controllers=*,bootstrapsigner,tokencleaner \\
    --kubeconfig=/etc/kubernetes/controller-manager.conf \\
    --leader-elect=true \\
    --node-cidr-mask-size-ipv4=24 \\
    --requestheader-client-ca-file=/etc/kubernetes/pki/controller.crt \\
    --root-ca-file=/etc/kubernetes/pki/ca.crt \\
    --service-account-private-key-file=/etc/kubernetes/pki/sa.key \\
    --service-cluster-ip-range=10.96.128.0/17 \\
    --use-service-account-credentials=true

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable --now kube-controller-manager.service
systemctl restart kube-controller-manager.service
systemctl status kube-controller-manager.service

