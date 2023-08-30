#!/usr/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive


vtysh -c "show ip bgp vrf dataplane summary"
vtysh -c "show ip bgp vrf dataplane"
