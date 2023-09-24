#!/bin/sh

kubectl  get pod,pvc,svc,ing -A -o wide
