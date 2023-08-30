#!/usr/bin/bash

set -x

ip netns exec dataplane ping 12.0.0.66 -c 6
ip netns exec dataplane ping 12.0.0.11 -c 6
ip netns exec dataplane ping 12.0.0.12 -c 6
ip netns exec dataplane ping 12.0.0.13 -c 6

