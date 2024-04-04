#!/bin/sh

set -x 
mkdir INGRESS

echo "sleep 10sec"
sleep 10

./INIT.2.5/init.0.xx.ingress.sh

echo "sleep 10sec"
sleep 10

./INIT.2.5/init.10.xx.ingress.sh   ingress-nginx-1 controller 11.0.2.95 default

echo "sleep 10sec"
sleep 10

./INIT.2.5/init.10.xx.ingress.sh   ingress-nginx-2 controller 11.0.2.100 default


echo "sleep 10sec"
sleep 10

./INIT.2.5/init.10.xx.ingress.sh   system-ingress controller 11.0.2.90 default
