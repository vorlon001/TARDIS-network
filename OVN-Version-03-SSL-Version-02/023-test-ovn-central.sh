
#!/usr/bin/bash

docker exec -it ovn-northd-ssl ovsdb-client query --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem ssl:192.168.200.170:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd-ssl ovsdb-client query --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem ssl:192.168.200.171:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd-ssl ovsdb-client query --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem ssl:192.168.200.172:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"


docker exec -it ovn-northd-ssl ovsdb-client query --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem ssl:192.168.200.170:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd-ssl ovsdb-client query --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem ssl:192.168.200.171:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd-ssl ovsdb-client query --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem ssl:192.168.200.172:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"

docker exec -it ovn-run_nb_ovsdb-ssl ovn-nbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --inactivity-probe=60000 set-connection pssl:6641:0.0.0.0
docker exec -it ovn-run_sb_ovsdb-ssl ovn-sbctl  --private-key=/etc/ovn/ovn-privkey.pem --certificate=/etc/ovn/ovn-cert.pem --ca-cert=/etc/ovn/cacert.pem --inactivity-probe=60000 set-connection pssl:6642:0.0.0.0
