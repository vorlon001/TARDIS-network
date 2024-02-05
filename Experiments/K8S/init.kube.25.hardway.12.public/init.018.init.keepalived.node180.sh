#!/usr/bin/bash

systemctl start keepalived
systemctl enable keepalived

echo "sleep 10sec"
sleep 10
kubectl get node,pod -A -o wide


