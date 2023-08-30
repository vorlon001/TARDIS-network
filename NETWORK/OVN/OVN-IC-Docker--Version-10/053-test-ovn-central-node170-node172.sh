#!/usr/bin/bash

docker exec -it ovn-ic_nb_ovsdb ovs-appctl -t /var/run/ovn/ovn_ic_nb_db.ctl cluster/status OVN_IC_Northbound
docker exec -it ovn-ic_sb_ovsdb ovs-appctl -t /var/run/ovn/ovn_ic_sb_db.ctl cluster/status OVN_IC_Southbound
