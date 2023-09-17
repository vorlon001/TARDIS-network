#!/usr/bin/bash


kubectl delete node/node180

echo "sleep 10sec"

sleep 10

kubectl delete -n kube-system  pod/kube-apiserver-node180  pod/kube-controller-manager-node180 pod/kube-scheduler-node180 --force
