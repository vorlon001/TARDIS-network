#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive


vtysh -c "show ip bgp summary"
vtysh -c "show ip bgp ipv4"
vtysh -c "show ip bgp ipv6"
