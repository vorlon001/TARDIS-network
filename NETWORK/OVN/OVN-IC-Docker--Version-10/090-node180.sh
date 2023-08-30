#!/usr/bin/bash

docker exec -it ovn-northd ovn-nbctl set NB_Global . name=node173.cloud.local
docker exec -it ovn-northd ovn-nbctl set NB_Global . options:ic-route-adv=true \
                            options:ic-route-learn=true
