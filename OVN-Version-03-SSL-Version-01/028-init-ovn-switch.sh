#!/usr/bin/bash

docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 ls-add net_east
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-add net_east vm1
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-addresses vm1 "40:44:00:00:00:01 12.0.0.11"

docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-add net_east vm2
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-addresses vm2 "40:44:00:00:00:02 12.0.0.12"

docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-add net_east vm3
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-addresses vm3 "40:44:00:00:00:03 12.0.0.13"

docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 ls-add public
# Create a localnet port
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-add public ln-public
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-type ln-public localnet
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-addresses ln-public unknown
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-options ln-public network_name=provider

docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lr-add router_east
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lrp-add router_east router_east-net_east 40:44:00:00:00:04 12.0.0.1/24
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-add net_east net_east-router_east
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-type net_east-router_east router
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-addresses net_east-router_east router
docker exec -it ovn-northd-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 lsp-set-options net_east-router_east router-port=router_east-net_east
