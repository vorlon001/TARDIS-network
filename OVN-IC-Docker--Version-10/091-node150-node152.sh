#!/usr/bin/bash

docker exec -it ovs-vswitchd ovs-vsctl set open_vswitch . external_ids:ovn-is-interconn=true
