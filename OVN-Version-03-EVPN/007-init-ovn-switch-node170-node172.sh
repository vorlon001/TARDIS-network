#!/usr/bin/bash

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 ls-add net170
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-add net170 vm1
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-addresses vm1 "40:44:70:00:00:01 192.168.70.11"

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-add net170 vm2
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-addresses vm2 "40:44:70:00:00:02 192.168.70.21"

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-add net170 vm3
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-addresses vm3 "40:44:70:00:00:03 192.168.70.31"

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 ls-add public
# Create a localnet port
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-add public ln-public
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-type ln-public localnet
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-addresses ln-public unknown
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-options ln-public network_name=provider

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lr-add router170
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lrp-add router170 router170-net170 40:44:70:00:00:04 192.168.70.1/24
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-add net170 net170-router170
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-type net170-router170 router
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-addresses net170-router170 router
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.170:6641,tcp:192.168.200.171:6641,tcp:192.168.200.172:6641 lsp-set-options net170-router170 router-port=router170-net170
