#!/usr/bin/bash

docker exec -it ovn-northd ovn-nbctl show
docker exec -it ovn-northd ovn-sbctl show
docker exec -it ovn-northd ovn-nbctl lrp-add router_west lrp-router_west-ts1 aa:aa:aa:aa:aa:02 169.254.100.2/24
docker exec -it ovn-northd ovn-nbctl lsp-add ts1 lsp-ts1-router_west -- lsp-set-addresses lsp-ts1-router_west -- lsp-set-type lsp-ts1-router_west router -- lsp-set-options lsp-ts1-router_west router-port=lrp-router_west-ts1
docker exec -it ovn-northd ovn-nbctl lrp-set-gateway-chassis lrp-router_west-ts1 node173.cloud.local 10
docker exec -it ovn-northd ovn-nbctl lrp-set-gateway-chassis lrp-router_west-ts1 node174.cloud.local 6
docker exec -it ovn-northd ovn-nbctl lrp-set-gateway-chassis lrp-router_west-ts1 node175.cloud.local 4
docker exec -it ovn-northd ovn-nbctl lr-route-add router_west 192.168.1.0/24 169.254.100.1
