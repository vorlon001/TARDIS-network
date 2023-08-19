
#!/usr/bin/bash

docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.180:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.181:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.182:6641 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"


docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.180:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.181:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.182:6642 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"

docker exec -it ovn-run_nb_ovsdb ovn-nbctl --inactivity-probe=60000 set-connection ptcp:6641:0.0.0.0
docker exec -it ovn-run_sb_ovsdb ovn-sbctl --inactivity-probe=60000 set-connection ptcp:6642:0.0.0.0

