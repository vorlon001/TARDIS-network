#!/usr/bin/bash

# kubectl apply -f https://github.com/envoyproxy/gateway/releases/download/v0.3.0/install.yaml

kubectl apply -f .

kubectl patch storageclass managed-nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
