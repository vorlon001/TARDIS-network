#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive


vtysh -c "show ip bgp summary"
vtysh -c "show ip bgp"
