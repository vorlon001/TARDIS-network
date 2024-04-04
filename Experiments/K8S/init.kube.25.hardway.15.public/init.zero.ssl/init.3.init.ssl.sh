#!/usr/bin/bash

set -x



mkdir -p /etc/kubernetes/pki


# cp root.bundle.kubernetes.crt /etc/kubernetes/pki/ca.crt

cp kubernetes/kubernetes.pem /etc/kubernetes/pki/ca.crt
cp kubernetes/kubernetes-key.pem /etc/kubernetes/pki/ca.key

cp apiserver/apiserver.pem /etc/kubernetes/pki/apiserver.crt
cp apiserver/apiserver-key.pem /etc/kubernetes/pki/apiserver.key


cp apiserver-kubelet-client/apiserver-kubelet-client.pem /etc/kubernetes/pki/apiserver-kubelet-client.crt
cp apiserver-kubelet-client/apiserver-kubelet-client-key.pem /etc/kubernetes/pki/apiserver-kubelet-client.key


cp kubernetes/kubernetes.pem  /etc/kubernetes/pki/front-proxy-ca.crt
cp kubernetes/kubernetes-key.pem /etc/kubernetes/pki/front-proxy-ca.key

cp front-proxy-client/front-proxy-client.pem /etc/kubernetes/pki/front-proxy-client.crt
cp front-proxy-client/front-proxy-client-key.pem /etc/kubernetes/pki/front-proxy-client.key

cp scheduler/scheduler-key.pem /etc/kubernetes/pki/scheduler.key
cp scheduler/scheduler.pem /etc/kubernetes/pki/scheduler.crt

cp controller/controller-key.pem /etc/kubernetes/pki/controller.key
cp controller/controller.pem /etc/kubernetes/pki/controller.crt

cp kube-proxy-key.pem /etc/kubernetes/pki/kube-proxy.key
cp kube-proxy.pem /etc/kubernetes/pki/kube-proxy.crt

openssl genrsa -out  /etc/kubernetes/pki/sa.key 2048
openssl rsa -in /etc/kubernetes/pki/sa.key -out /etc/kubernetes/pki/sa.pub -pubout -outform PEM

