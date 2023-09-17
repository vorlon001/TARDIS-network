#!/bin/sh

set -x

kubectl apply -f INIT.2.3/PriorityClass.yaml

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
