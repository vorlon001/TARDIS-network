#!/usr/bin/bash

docker exec -it ovn-run_nb_ovsdb ovs-appctl -t /var/run/ovn/ovnnb_db.ctl cluster/status OVN_Northbound
docker exec -it ovn-run_sb_ovsdb ovs-appctl -t /var/run/ovn/ovnsb_db.ctl cluster/status OVN_Southbound
