#!/bin/sh

kubectl get node -o custom-columns-file=node-colnum.txt 
