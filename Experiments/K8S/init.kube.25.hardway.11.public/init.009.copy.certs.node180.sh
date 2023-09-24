#!/usr/bin/bash


ssh 192.168.200.181 mkdir -p /etc/kubernetes/pki/
ssh 192.168.200.182 mkdir -p /etc/kubernetes/pki/

scp /etc/kubernetes/controller-manager.conf 192.168.200.181://etc/kubernetes/controller-manager.conf
scp /etc/kubernetes/controller-manager.conf 192.168.200.182://etc/kubernetes/controller-manager.conf

scp /etc/kubernetes/scheduler.conf 192.168.200.181://etc/kubernetes/scheduler.conf
scp /etc/kubernetes/scheduler.conf 192.168.200.182://etc/kubernetes/scheduler.conf

scp /etc/kubernetes/pki/apiserver.crt 192.168.200.181://etc/kubernetes/pki/apiserver.crt
scp /etc/kubernetes/pki/apiserver.crt 192.168.200.182://etc/kubernetes/pki/apiserver.crt

scp /etc/kubernetes/pki/apiserver.key 192.168.200.181://etc/kubernetes/pki/apiserver.key
scp /etc/kubernetes/pki/apiserver.key 192.168.200.182://etc/kubernetes/pki/apiserver.key

scp /etc/kubernetes/pki/apiserver-kubelet-client* 192.168.200.181://etc/kubernetes/pki/
scp /etc/kubernetes/pki/apiserver-kubelet-client* 192.168.200.182://etc/kubernetes/pki/

scp /etc/kubernetes/pki/front-proxy-clie* 192.168.200.181://etc/kubernetes/pki/
scp /etc/kubernetes/pki/front-proxy-clie* 192.168.200.182://etc/kubernetes/pki/

scp /etc/kubernetes/pki/front-proxy-ca* 192.168.200.181://etc/kubernetes/pki/
scp /etc/kubernetes/pki/front-proxy-ca* 192.168.200.182://etc/kubernetes/pki/

scp /etc/kubernetes/pki/sa* 192.168.200.181://etc/kubernetes/pki/
scp /etc/kubernetes/pki/sa* 192.168.200.182://etc/kubernetes/pki/

scp /etc/kubernetes/pki/ca* 192.168.200.181://etc/kubernetes/pki/
scp /etc/kubernetes/pki/ca* 192.168.200.182://etc/kubernetes/pki/

ssh 192.168.200.181 mkdir -p /etc/kubernetes/policies/
scp /etc/kubernetes/policies/audit-policy.yaml 192.168.200.181://etc/kubernetes/policies/

ssh 192.168.200.182 mkdir -p /etc/kubernetes/policies/
scp /etc/kubernetes/policies/audit-policy.yaml 192.168.200.182://etc/kubernetes/policies/

scp /etc/kubernetes/pki/apiserver-etcd* 192.168.200.181://etc/kubernetes/pki/
scp /etc/kubernetes/pki/apiserver-etcd* 192.168.200.182://etc/kubernetes/pki/

scp /etc/kubernetes/admin.conf 192.168.200.181://etc/kubernetes/admin.conf
scp /etc/kubernetes/admin.conf 192.168.200.182://etc/kubernetes/admin.conf


scp /etc/kubernetes/pki/scheduler* 192.168.200.181://etc/kubernetes/pki/
scp /etc/kubernetes/pki/controller* 192.168.200.181://etc/kubernetes/pki/

scp /etc/kubernetes/pki/scheduler* 192.168.200.182://etc/kubernetes/pki/
scp /etc/kubernetes/pki/controller* 192.168.200.182://etc/kubernetes/pki/

scp /etc/kubernetes/pki/kube-proxy.* 192.168.200.181:/etc/kubernetes/pki
scp /etc/kubernetes/pki/kube-proxy.* 192.168.200.182:/etc/kubernetes/pki


ssh 192.168.200.170 mkdir /root/.kube
scp /etc/kubernetes/admin.conf 192.168.200.170://root/.kube/config
