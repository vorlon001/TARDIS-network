#!/usr/bin/bash

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 ls-add net180
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-add net180 vm1
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-addresses vm1 "40:44:80:00:00:01 192.168.80.11"

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-add net180 vm2
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-addresses vm2 "40:44:80:00:00:02 192.168.80.21"

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-add net180 vm3
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-addresses vm3 "40:44:80:00:00:03 192.168.80.31"

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 ls-add public
# Create a localnet port
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-add public ln-public
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-type ln-public localnet
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-addresses ln-public unknown
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-options ln-public network_name=provider

docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lr-add router180
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lrp-add router180 router180-net180 40:44:80:00:00:04 192.168.80.1/24
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-add net180 net180-router180
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-type net180-router180 router
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-addresses net180-router180 router
docker exec -it ovn-northd ovn-nbctl --db=tcp:192.168.200.180:6641,tcp:192.168.200.181:6641,tcp:192.168.200.182:6641 lsp-set-options net180-router180 router-port=router180-net180
