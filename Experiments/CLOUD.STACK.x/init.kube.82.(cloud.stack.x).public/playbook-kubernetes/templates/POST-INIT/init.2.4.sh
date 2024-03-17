#!/bin/sh

#kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

set -x 
# DEPRICATED
# echo "INIT default nginx ingress"
# wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/baremetal/deploy.yaml
# kubectl create namespace ingress-nginx
# kubectl apply -f deploy.yaml


# wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
# mv components.yaml INIT.2.4/v0.5.0-components.yaml

# wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.1/components.yaml
# mv components.yaml INIT.2.4/v0.5.1-components.yaml

# wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml
# mv components.yaml INIT.2.4/v0.6.1-components.yaml

#wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/high-availability.yaml
#mv high-availability.yaml INIT.2.4/v0.6.1-high-availability.yaml

#kubectl apply -f INIT.2.4/v0.6.1-components.yaml
kubectl apply -f INIT.2.4/v0.6.4-high-availability.yaml

#kubectl patch service/kube-dns -n kube-system  -p '{"spec":{"type": "LoadBalancer"}}'
kubectl patch service/kube-dns -n kube-system  -p '{
		"annotations": {
					"metallb.universe.tf/address-pool": "main",
					"metallb.universe.tf/allow-shared-ip": "coredns-kube"
		}, "spec":{
					"type": "LoadBalancer",
					"loadBalancerIP": "11.0.11.22"
		}
}'

#DEPRICATED
#kubectl patch service/ingress-nginx-controller -n ingress-nginx  -p '{"spec":{"type": "LoadBalancer"}}'
