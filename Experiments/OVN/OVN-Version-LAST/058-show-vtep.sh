#!/usr/bin/bash

docker exec -it ovn-controller-vtep vtep-ctl --db=unix:/var/run/openvswitch/db.sock --columns=MAC list Ucast_Macs_Remote
docker exec -it ovn-controller-vtep vtep-ctl --db=unix:/var/run/openvswitch/db.sock show
