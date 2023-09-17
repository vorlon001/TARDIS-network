#!/usr/bin/bash

cat > /usr/lib/systemd/system/kube-scheduler.service << EOF

[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
    --authentication-kubeconfig=/etc/kubernetes/scheduler.kubeconfig \\
    --authorization-kubeconfig=/etc/kubernetes/scheduler.kubeconfig \\
    --bind-address=0.0.0.0 \\
    --kubeconfig=/etc/kubernetes/scheduler.kubeconfig \\
    --leader-elect=true

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF


systemctl daemon-reload
systemctl enable --now kube-scheduler.service
systemctl restart kube-scheduler.service
systemctl status kube-scheduler.service



