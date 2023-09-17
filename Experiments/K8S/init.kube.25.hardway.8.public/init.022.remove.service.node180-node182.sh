#!/usr/bin/bash

systemctl stop containerd
systemctl disable containerd

systemctl stop kubelet
systemctl disable kubelet


systemctl restart kube-apiserver.service
systemctl status kube-apiserver.service
systemctl restart kube-controller-manager.service
systemctl status kube-controller-manager.service
systemctl restart kube-scheduler.service
systemctl status kube-scheduler.service
