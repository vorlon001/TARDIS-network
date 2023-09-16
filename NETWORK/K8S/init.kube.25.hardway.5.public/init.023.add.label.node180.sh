#!/usr/bin/bash
#ADD MASTER

kubectl label node node170 node-role.kubernetes.io/worker=worker
kubectl label node node171 node-role.kubernetes.io/worker=worker
kubectl label node node172 node-role.kubernetes.io/worker=worker

