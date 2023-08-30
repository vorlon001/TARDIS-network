#!/usr/bin/bash

docker exec -it ovn-northd ovn-nbctl show
docker exec -it ovn-northd ovn-sbctl show
docker exec -it ovn-northd ovn-nbctl lrp-add router_east lrp-router_east-ts1 aa:aa:aa:aa:aa:01 169.254.100.1/24
docker exec -it ovn-northd ovn-nbctl lsp-add ts1 lsp-ts1-router_east -- lsp-set-addresses lsp-ts1-router_east -- lsp-set-type lsp-ts1-router_east router -- lsp-set-options lsp-ts1-router_east router-port=lrp-router_east-ts1
docker exec -it ovn-northd ovn-nbctl lrp-set-gateway-chassis lrp-router_east-ts1 node170.cloud.local 10
docker exec -it ovn-northd ovn-nbctl lrp-set-gateway-chassis lrp-router_east-ts1 node171.cloud.local 6
docker exec -it ovn-northd ovn-nbctl lrp-set-gateway-chassis lrp-router_east-ts1 node172.cloud.local 4
docker exec -it ovn-northd ovn-nbctl lr-route-add router_east 192.168.2.0/24 169.254.100.2

docker exec -it ovn-northd ovn-nbctl show
docker exec -it ovn-northd ovn-sbctl show
