#!/bin/sh

set -x 

kubectl delete ns metallb-system


#curl https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-frr.yaml  -o ./METALLB/v0.13.12.metallb-frr.yaml
#curl https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml  -o ./METALLB/v0.13.12.metallb-native.yaml

kubectl apply -f ./v0.13.12.metallb-frr.yaml

kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

sleep 60

cat <<'EOF' > ./METALLB/metallb-cfg.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  # Production services will go here. Public IPs are expensive, so we leased
  # just 4 of them.
  addresses:
  - 11.0.0.0/22
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: internet
  namespace: metallb-system
spec:
  # Production services will go here. Public IPs are expensive, so we leased
  # just 4 of them.
  addresses:
  - 11.0.10.1/32
EOF
kubectl apply -f ./METALLB/metallb-cfg.yaml

cat <<'EOF' > ./METALLB/metallb-cfg2.yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: internet2
  namespace: metallb-system
spec:
  # Production services will go here. Public IPs are expensive, so we leased
  # just 4 of them.
  addresses:
  - 11.0.11.2/32
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: coredns-kube
  namespace: metallb-system
spec:
  # Production services will go here. Public IPs are expensive, so we leased
  # just 4 of them.
  addresses:
  - 11.0.11.22/32
EOF
kubectl apply -f ./METALLB/metallb-cfg2.yaml

