#!/usr/bin/bash

docker exec -it  ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-add net_east sw0-vtep-port1
docker exec -it  ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-type sw0-vtep-port1 vtep
docker exec -it  ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-addresses sw0-vtep-port1 "00:00:00:44:44:44 12.0.0.66"
docker exec -it  ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-options sw0-vtep-port1 vtep-physical-switch=GW01 vtep-logical-switch=LS1

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 show
docker exec -it ovn-northd ovn-sbctl --db=tcp:192.168.200.170:6642,tcp:192.168.200.171:6642,tcp:192.168.200.172:6642 show
