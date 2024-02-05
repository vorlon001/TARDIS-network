#!/bin/bash

set -x

kubectl apply -f nginx-ingress.demo.1/01-namespace.yaml
kubectl apply -f nginx-ingress.demo.1/02-nginx-deploy-blue.yaml
kubectl apply -f nginx-ingress.demo.1/02-nginx-deploy-green.yaml
kubectl apply -f nginx-ingress.demo.1/02-nginx-deploy-main.yaml
kubectl apply -f nginx-ingress.demo.1/03-ingress.yaml


kubectl apply -f nginx-ingress.demo.2/01-namespace.yaml
kubectl apply -f nginx-ingress.demo.2/02-nginx-deploy-blue.yaml
kubectl apply -f nginx-ingress.demo.2/02-nginx-deploy-green.yaml
kubectl apply -f nginx-ingress.demo.2/02-nginx-deploy-main.yaml
kubectl apply -f nginx-ingress.demo.2/03-ingress.yaml


kubectl get pod,svc,ingress -n test-ingress-1

kubectl get pod,svc,ingress -n test-ingress-2

kubectl get pod,ingress,svc -o wide -A


curl http://11.0.2.95   -v -H 'Host: hello-1.iblog.pro'
curl http://11.0.2.100  -v -H 'Host: hello-2.iblog.pro'
