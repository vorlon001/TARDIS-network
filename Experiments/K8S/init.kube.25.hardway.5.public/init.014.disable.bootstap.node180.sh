#!/usr/bin/bash

systemctl stop keepalived

echo "sleep 10sec"
sleep 10
kubectl get node,pod -A -o wide


systemctl disable keepalived

systemctl stop containerd
systemctl disable containerd

systemctl stop kubelet
systemctl disable kubelet

shutdown -r 1 "reboot"
