#!/usr/bin/bash


export INTERFACE_KEEPALIVED_VIP="enp1s0.200"
export INTERNAL_IP=$(ifconfig ${INTERFACE_KEEPALIVED_VIP} | grep inet\   | awk '{print $2}')


echo "INIT /etc/kubernetes/controller-manager.kubeconfig"

kubectl config set-cluster cluster.local \
     --certificate-authority=/etc/kubernetes/pki/ca.crt \
     --embed-certs=true \
     --server=https://${INTERNAL_IP}:6443 \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig


kubectl config set-context system:kube-controller-manager@cluster.local \
    --cluster=cluster.local \
    --user=system:kube-controller-manager \
    --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
     --client-certificate=/etc/kubernetes/pki/controller.crt \
     --client-key=/etc/kubernetes/pki/controller.key \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

kubectl config use-context system:kube-controller-manager@cluster.local \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

echo "INIT /etc/kubernetes/scheduler.kubeconfig"

kubectl config set-cluster cluster.local \
     --certificate-authority=/etc/kubernetes/pki/ca.crt \
     --embed-certs=true \
     --server=https://${INTERNAL_IP}:6443 \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
     --client-certificate=/etc/kubernetes/pki/scheduler.crt \
     --client-key=/etc/kubernetes/pki/scheduler.key \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-context system:kube-scheduler@cluster.local \
     --cluster=cluster.local \
     --user=system:kube-scheduler \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config use-context system:kube-scheduler@cluster.local \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
