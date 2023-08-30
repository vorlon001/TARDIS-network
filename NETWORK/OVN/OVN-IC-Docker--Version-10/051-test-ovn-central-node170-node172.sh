
#!/usr/bin/bash
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.170:6645 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_IC_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.171:6645 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_IC_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.172:6645 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_IC_Northbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"


docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.170:6646 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_IC_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.171:6646 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_IC_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"
docker exec -it ovn-northd ovsdb-client query tcp:192.168.200.172:6646 "[\"_Server\",{\"table\":\"Database\",\"where\":[[\"name\",\"==\", \"OVN_IC_Southbound\"]],\"columns\": [\"leader\"],\"op\":\"select\"}]"

docker exec -it ovn-run_nb_ovsdb ovn-nbctl --inactivity-probe=60000 set-connection ptcp:6645:0.0.0.0
docker exec -it ovn-run_sb_ovsdb ovn-sbctl --inactivity-probe=60000 set-connection ptcp:6646:0.0.0.0

