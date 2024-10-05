#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

vtysh -c "show run" >051-configure-frr-node180.config
cp /etc/frr/frr.conf 052-configure-frr-node180.config
cp /etc/netplan/50-cloud-init.yaml 052-config-netplan-node180.config

