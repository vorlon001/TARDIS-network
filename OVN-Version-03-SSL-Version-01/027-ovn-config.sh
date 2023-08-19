#!/usr/bin/bash


docker exec -it ovn-northd-ssl ovn-nbctl --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6641,ssl:192.168.200.171:6641,ssl:192.168.200.172:6641 show
docker exec -it ovn-northd-ssl ovn-sbctl --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --db=ssl:192.168.200.170:6642,ssl:192.168.200.171:6642,ssl:192.168.200.172:6642 show

