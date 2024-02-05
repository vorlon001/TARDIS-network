#!/bin/sh

set -x

kubectl apply -f INIT.2.3/PriorityClass.yaml

#kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

kubectl apply -f cert-manager.yaml

