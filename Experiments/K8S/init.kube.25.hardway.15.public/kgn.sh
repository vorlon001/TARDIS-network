#!/usr/bin/bash

kubectl get nodes -o custom-columns="NAME:.metadata.name,ROLE:.metadata.labels.node-role\.kubernetes\.io/worker,LABELS:.metadata.labels.project,IP:.status.addresses[0].address,KERNEL:.status.nodeInfo.kernelVersion"

