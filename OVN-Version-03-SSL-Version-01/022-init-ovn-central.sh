#!/usr/bin/bash

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
JOINTYPE=$(if [[ $NODEID -eq '170' ]];   then  echo "";   else     echo "-join";   fi)
INITSSL=$(if [[ $NODEID -eq '170' ]];   then  echo "yes";   else     echo "no";   fi)

export TAGNODE=7
export NODE1=192.168.200.1${TAGNODE}0
export NODE2=192.168.200.1${TAGNODE}1
export NODE3=192.168.200.1${TAGNODE}2
export PORT6641="ssl:${NODE1}:6641,ssl:${NODE2}:6641,ssl:${NODE3}:6641"
export PORT6642="ssl:${NODE1}:6642,ssl:${NODE2}:6642,ssl:${NODE3}:6642"

cat <<EOF>/root/ovn/env.ovn-run_nb_ovsdb.list.${NODEID}
OVNCMD=ovn-run_nb_ovsdb-cluster${JOINTYPE}-ssl
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTERJOINIP=${NODE1}
OVNCLUSTER6641=${PORT6641}
OVNCLUSTER6642=${PORT6642}
EOF

cat <<EOF>/root/ovn/env.ovn-run_sb_ovsdb.list.${NODEID}
OVNCMD=ovn-run_sb_ovsdb-cluster${JOINTYPE}-ssl
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTERJOINIP=${NODE1}
OVNCLUSTER6641=${PORT6641}
OVNCLUSTER6642=${PORT6642}
EOF

cat <<EOF>/root/ovn/env.ovn-northd.list.${NODEID}
OVNCMD=ovn-northd-cluster-ssl
OVNHOSTIP=192.168.200.${NODEID}
OVNCLUSTER6641=${PORT6641}
OVNCLUSTER6642=${PORT6642}
EOF

NODEID=$(echo $(ifconfig enp1s0.200 | grep 192.168.200. | awk '{print $2}') | sed 's|192.168.200.||')
cat /root/ovn/env.ovn-run_nb_ovsdb.list.${NODEID}
cat /root/ovn/env.ovn-run_sb_ovsdb.list.${NODEID}
cat /root/ovn/env.ovn-northd.list.${NODEID}


if [[ $INITSSL == "yes" ]];
then

docker run -it -d -it   --hostname=ovn-northd-ssl  --name ovn-northd-ssl ovn:v11 bash
docker ps -a

docker exec -i ovn-northd-ssl bash <<'EOF'
set -x
apt update
apt install -y sshpass
mkdir -p /etc/ovn/
ovs-pki init -l /dev/stdout --force
cp /var/lib/openvswitch/pki/switchca/cacert.pem /etc/ovn/
cd /etc/ovn
ovs-pki req ovn -l /dev/stdout --force
ovs-pki -b sign ovn -l /dev/stdout --force
EOF


docker exec -i ovn-northd-ssl bash <<'EOF'
set -x
echo "root" > pass_file
chmod 0400 pass_file
sshpass -f pass_file scp -o StrictHostKeyChecking=no /etc/ovn/* root@192.168.200.170://root/ovn/etc
sshpass -f pass_file scp -o StrictHostKeyChecking=no /etc/ovn/* root@192.168.200.171://root/ovn/etc
sshpass -f pass_file scp -o StrictHostKeyChecking=no /etc/ovn/* root@192.168.200.172://root/ovn/etc
exit
EOF

docker stop ovn-northd-ssl
docker rm ovn-northd-ssl
docker ps
fi

docker run -it -d --restart=always   --network=host --privileged  --hostname=ovn-run_nb_ovsdb-ssl --env-file=/root/ovn/env.ovn-run_nb_ovsdb.list.${NODEID} --name ovn-run_nb_ovsdb-ssl  -v /root/ovn/log:/var/log/ovn/ -v /root/ovn/lib:/var/lib/ovn -v /root/ovn/run:/var/run/ovn  -v /root/ovn/etc:/etc/ovn ovn:v11
echo "sleep 8 sec."
sleep 8
docker run -it -d --restart=always  --network=host --privileged  --hostname=ovn-run_sb_ovsdb-ssl --env-file=/root/ovn/env.ovn-run_sb_ovsdb.list.${NODEID} --name ovn-run_sb_ovsdb-ssl -v /root/ovn/log:/var/log/ovn/ -v /root/ovn/lib:/var/lib/ovn -v /root/ovn/run:/var/run/ovn -v /root/ovn/etc:/etc/ovn ovn:v11
echo "sleep 8 sec."
sleep 8

docker run -it -d --restart=always  --network=host --privileged  --hostname=ovn-northd-ssl  --env-file=/root/ovn/env.ovn-northd.list.${NODEID} --name ovn-northd-ssl -v /root/ovn/log:/var/log/ovn/ -v /root/ovn/lib:/var/lib/ovn -v /root/ovn/run:/var/run/ovn -v /root/ovn/etc:/etc/ovn ovn:v11
echo "sleep 12 sec."
sleep 12

docker ps -a

#docker stop ovn-run_sb_ovsdb-ssl ovn-run_nb_ovsdb-ssl
#rm  /root/ovn/run/ovnsb_db.pid
#rm  /root/ovn/run/ovnsb_db.pid

docker exec -it ovn-northd-ssl /usr/share/ovn/scripts/ovn-ctl \
                                          --ovn-northd-ssl-key=/etc/ovn/ovn-privkey.pem  \
                                          --ovn-northd-ssl-cert=/etc/ovn/ovn-cert.pem    \
                                          --ovn-northd-ssl-ca-cert=/etc/ovn/cacert.pem \
                                          restart_northd

#docker start ovn-run_sb_ovsdb-ssl ovn-run_nb_ovsdb-ssl

echo "sleep 12 sec."
sleep 12
docker ps -a



docker exec -it ovn-run_nb_ovsdb-ssl ovn-nbctl set-ssl /etc/ovn/ovn-privkey.pem /etc/ovn/ovn-cert.pem /etc/ovn/cacert.pem
docker exec -it ovn-run_sb_ovsdb-ssl ovn-sbctl set-ssl /etc/ovn/ovn-privkey.pem /etc/ovn/ovn-cert.pem /etc/ovn/cacert.pem
docker exec -it ovn-run_nb_ovsdb-ssl ovn-nbctl set-connection pssl:6641
docker exec -it ovn-run_sb_ovsdb-ssl ovn-sbctl set-connection pssl:6642

echo "sleep 12 sec."
sleep 12

docker ps -a

#docker exec -it ovn-run_nb_ovsdb ovn-nbctl --inactivity-probe=60000 set-connection pssl:6641:0.0.0.0
#docker exec -it ovn-run_sb_ovsdb ovn-sbctl --inactivity-probe=60000 set-connection pssl:6642:0.0.0.0

