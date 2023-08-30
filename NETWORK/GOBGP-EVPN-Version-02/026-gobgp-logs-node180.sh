#!/usr/bin/bash

# https://github.com/osrg/gobgp/blob/master/tools/contrib/centos/README.md

journalctl -u gobgpd.service --since today
journalctl -u gobgpd.service -r
