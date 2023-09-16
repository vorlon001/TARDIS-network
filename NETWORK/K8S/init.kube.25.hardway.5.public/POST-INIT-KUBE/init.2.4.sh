#!/bin/sh

set -x 

kubectl apply -f INIT.2.4/v0.6.4-high-availability.yaml

kubectl patch service/kube-dns -n kube-system  -p '{
		"annotations": {
					"metallb.universe.tf/address-pool": "main",
					"metallb.universe.tf/allow-shared-ip": "coredns-kube"
		}, "spec":{
					"type": "LoadBalancer",
					"loadBalancerIP": "11.0.11.22"
		}
}'

