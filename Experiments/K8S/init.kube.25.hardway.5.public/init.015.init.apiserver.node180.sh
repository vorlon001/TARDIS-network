#!/usr/bin/bash



export INTERFACE_KEEPALIVED_VIP="enp1s0.200"
export INTERNAL_IP=$(ifconfig ${INTERFACE_KEEPALIVED_VIP} | grep inet\   | awk '{print $2}')



cat > /usr/lib/systemd/system/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
    --advertise-address=${INTERNAL_IP} \\
    --allow-privileged=true \\
    --audit-log-format=json \\
    --audit-log-maxage=7 \\
    --audit-log-maxbackup=10 \\
    --audit-log-maxsize=100 \\
    --audit-log-path=/var/log/kube-audit/audit.log \\
    --audit-policy-file=/etc/kubernetes/policies/audit-policy.yaml \\
    --authorization-mode=Node,RBAC \\
    --client-ca-file=/etc/kubernetes/pki/ca.crt \\
    --enable-admission-plugins=NodeRestriction \\
    --enable-bootstrap-token-auth=true \\
    --etcd-cafile=/etc/etcd/ca.pem \\
    --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd.pem \\
    --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-key.pem \\
    --etcd-servers=https://192.168.200.180:2379,https://192.168.200.181:2379,https://192.168.200.182:2379 \\
    --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt \\
    --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key \\
    --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname \\
    --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt \\
    --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key \\
    --requestheader-allowed-names=front-proxy-client \\
    --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt \\
    --requestheader-extra-headers-prefix=X-Remote-Extra- \\
    --requestheader-group-headers=X-Remote-Group \\
    --requestheader-username-headers=X-Remote-User \\
    --secure-port=6443 \\
    --service-account-issuer=https://kubernetes.default.svc.cluster.local \\
    --service-account-key-file=/etc/kubernetes/pki/sa.pub \\
    --service-account-signing-key-file=/etc/kubernetes/pki/sa.key \\
    --service-cluster-ip-range=10.96.128.0/17 \\
    --tls-cert-file=/etc/kubernetes/pki/apiserver.crt \\
    --tls-private-key-file=/etc/kubernetes/pki/apiserver.key

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

EOF


systemctl daemon-reload
systemctl enable --now kube-apiserver.service
systemctl restart kube-apiserver.service
systemctl status kube-apiserver.service


