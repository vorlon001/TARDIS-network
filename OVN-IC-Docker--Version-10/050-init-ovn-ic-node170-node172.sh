#!/usr/bin/bash


NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
JOINTYPE=$(if [[ $NODEID -eq '170' ]];   then  echo "";   else     echo "-join";   fi)

cat <<EOF>/root/ovn/env.ovn-ic_nb_ovsdb.list.${NODEID}
OVNCMD=run_ic_nb_ovsdb-cluster${JOINTYPE}
OVNHOSTIP=192.168.200.${NODEID}
OVNICCLUSTERJOINIP=192.168.200.170
OVNCLUSTER6645=tcp:192.168.200.170:6645,tcp:192.168.200.171:6645,tcp:192.168.200.172:6645
OVNCLUSTER6646=tcp:192.168.200.170:6646,tcp:192.168.200.171:6646,tcp:192.168.200.172:6646
OVNCLUSTER6647=tcp:192.168.200.170:6647,tcp:192.168.200.171:6647,tcp:192.168.200.172:6647
OVNCLUSTER6648=tcp:192.168.200.170:6648,tcp:192.168.200.171:6648,tcp:192.168.200.172:6648
EOF



cat <<EOF>/root/ovn/env.ovn-ic_sb_ovsdb.list.${NODEID}
OVNCMD=run_ic_sb_ovsdb-cluster${JOINTYPE}
OVNHOSTIP=192.168.200.${NODEID}
OVNICCLUSTERJOINIP=192.168.200.170
OVNCLUSTER6645=tcp:192.168.200.170:6645,tcp:192.168.200.171:6645,tcp:192.168.200.172:6645
OVNCLUSTER6646=tcp:192.168.200.170:6646,tcp:192.168.200.171:6646,tcp:192.168.200.172:6646
OVNCLUSTER6647=tcp:192.168.200.170:6647,tcp:192.168.200.171:6647,tcp:192.168.200.172:6647
OVNCLUSTER6648=tcp:192.168.200.170:6648,tcp:192.168.200.171:6648,tcp:192.168.200.172:6648
EOF

cat /root/ovn/env.ovn-ic_nb_ovsdb.list.${NODEID}
cat /root/ovn/env.ovn-ic_sb_ovsdb.list.${NODEID}

docker run -it -d --restart=always  --network=host --privileged  --hostname=ovn-ic_nb_ovsdb --env-file=/root/ovn/env.ovn-ic_nb_ovsdb.list.${NODEID} --name ovn-ic_nb_ovsdb -v /root/ovn-ic/log:/var/log/ovn/ -v /root/ovn-ic/lib:/var/lib/ovn -v /root/ovn-ic/run:/var/run/ovn ovn:v10

docker run -it -d --restart=always  --network=host --privileged  --hostname=ovn-ic_sb_ovsdb --env-file=/root/ovn/env.ovn-ic_sb_ovsdb.list.${NODEID} --name ovn-ic_sb_ovsdb -v /root/ovn-ic/log:/var/log/ovn/ -v /root/ovn-ic/lib:/var/lib/ovn -v /root/ovn-ic/run:/var/run/ovn ovn:v10
docker ps -a

