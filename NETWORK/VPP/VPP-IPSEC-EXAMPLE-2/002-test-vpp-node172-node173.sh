#!/usr/bin/bash


export DEBIAN_FRONTEND=noninteractive

vppctl show int
vppctl show plug | grep cp
