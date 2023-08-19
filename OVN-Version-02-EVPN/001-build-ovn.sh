#!/usr/bin/bash
export DEBIAN_FRONTEND=noninteractive
cat <<EOF>/root/e.sh
apt install docker.io  iproute2 net-tools iputils-ping iperf3 wget -y
EOF
chmod +x /root/e.sh
/root/e.sh

cat <<EOF>/root/e.sh
depmod -a
modprobe openvswitch
modprobe vport_geneve

rm -R /root/ovs
rm -R /root/ovn
rm -R /root/ovs-ic
rm -R /root/ovn-base

mkdir /root/ovs
mkdir /root/ovn
mkdir /root/ovs-ic
mkdir /root/ovn-base

EOF
chmod +x /root/e.sh
/root/e.sh


cat <<EOF>/root/ovn/create_ovs_db.sh
#!/bin/sh
ovsdb-tool create /etc/openvswitch/ovs.db \
  /usr/share/openvswitch/vswitch.ovsschema
ovsdb-tool create /etc/openvswitch/vtep.db \
  /usr/share/openvswitch/vtep.ovsschema
ovsdb-tool create /etc/openvswitch/conf.db \
  /usr/share/openvswitch/vswitch.ovsschema
EOF


chmod +x /root/ovn/create_ovs_db.sh

cat <<EOF>/root/ovn/ovs-override.conf
override openvswitch * extra
override vport-geneve * extra
override vport-stt * extra
override vport-* * extra
EOF


cat <<EOF>/root/ovn/start-ovn
#!/bin/bash
echo "OVNCLUSTERJOINIP - \$OVNCLUSTERJOINIP"
echo "OVNICCLUSTERJOINIP - \$OVNICCLUSTERJOINIP"
echo "OVNICIP - \$OVNICIP"
echo "OVNHOSTIP -\$OVNHOSTIP"
echo "OVNCLUSTER6641 - \$OVNCLUSTER6641"
echo "OVNCLUSTER6642 - \$OVNCLUSTER6642"
echo "OVNCLUSTER6645 - \$OVNCLUSTER6645"
echo "OVNCLUSTER6646 - \$OVNCLUSTER6646"
echo "OVNCLUSTER6647 - \$OVNCLUSTER6647"
echo "OVNCLUSTER6648 - \$OVNCLUSTER6648"
echo "OVNCMD - \$OVNCMD"
echo "OVNCTEPGATEWAY - \$OVNCTEPGATEWAY"
case \$OVNCMD in
        "ovsdb-init") ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
        ;;
        "ovsdb-vtep-init") ovsdb-tool create /etc/openvswitch/vtep.db /usr/share/openvswitch/vtep.ovsschema
        ;;
        "ovsdb-server") ovsdb-server --pidfile /etc/openvswitch/conf.db \
                        -vconsole:emer -vsyslog:err -vfile:info \
                        --remote=punix:/var/run/openvswitch/db.sock \
                        --private-key=db:Open_vSwitch,SSL,private_key \
                        --certificate=db:Open_vSwitch,SSL,certificate \
                        --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
                        --log-file=/var/log/openvswitch/ovsdb-server.log \
                        --no-chdir
        ;;
        "ovs-vswitchd") ovs-vswitchd --pidfile -vconsole:emer \
                        -vsyslog:err -vfile:info --mlockall --no-chdir \
                        --log-file=/var/log/openvswitch/ovs-vswitchd.log
        ;;
        "ovs-controller") ovn-controller unix:/var/run/openvswitch/db.sock --no-chdir \
                         --log-file=/var/log/openvswitch/ovn-controller.log \
                         --pidfile=/var/run/openvswitch/ovn-controller.pid
        ;;

        "ovs-vswitchd-vtep") ovs-vswitchd --pidfile --no-chdir \
                        --log-file=/var/log/openvswitch/ovs-vswitchd.log --pidfile unix:/var/run/openvswitch/db.sock
        ;;
        "ovn-controller-vtep") ovn-controller-vtep  \
                        --overwrite-pidfile \
                        --monitor \
                        --vtep-db=unix:/var/run/openvswitch/db.sock \
                        --ovnsb-db=\${OVNCLUSTER6642} \
                        --pidfile \
                        --log-file /var/log/ovn/ovn-controller-vtep.log \
                        --no-chdir
        ;;
        "ovsdb-server-vtep") ovsdb-server --pidfile  \
                        -vconsole:emer -vsyslog:err -vfile:info \
                        --overwrite-pidfile \
                        --monitor \
                        --log-file=/var/log/ovn/ovsdb-server.log \
                        --remote punix:/var/run/openvswitch/db.sock \
                        --remote=db:hardware_vtep,Global,managers \
                        /etc/openvswitch/conf.db /etc/openvswitch/vtep.db
        ;;
        "ovs-vtepd") /usr/share/openvswitch/scripts/ovs-vtep \
                        --overwrite-pidfile \
                        --monitor \
                        --log-file=/var/log/openvswitch/ovs-vtep.log \
                        --pidfile=/var/run/openvswitch/ovs-vtep.pid \
                        --monitor \${OVNCTEPGATEWAY}
        ;;
        "ovn-run_nb_ovsdb-host") /usr/share/ovn/scripts/ovn-ctl run_nb_ovsdb \
                                --db-nb-addr=\${OVNHOSTIP} \
                                --db-sb-addr=\${OVNHOSTIP} \
                                --db-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes \
                                --ovn-northd-nb-db=tcp:\${OVNHOSTIP}:6641 \
                                --ovn-northd-sb-db=tcp:\${OVNHOSTIP}:6642
        ;;
        "ovn-run_sb_ovsdb-host") /usr/share/ovn/scripts/ovn-ctl run_sb_ovsdb \
                                --db-nb-addr=\${OVNHOSTIP} \
                                --db-sb-addr=\${OVNHOSTIP} \
                                --db-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes \
                                --ovn-northd-nb-db=tcp:\${OVNHOSTIP}:6641 \
                                --ovn-northd-sb-db=tcp:\${OVNHOSTIP}:6642
        ;;
        "ovn-run_nb_ovsdb-cluster") /usr/share/ovn/scripts/ovn-ctl run_nb_ovsdb \
                                --db-nb-addr=\${OVNHOSTIP} \
                                --db-sb-addr=\${OVNHOSTIP} \
                                --db-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes \
                                --ovn-northd-nb-db=\${OVNCLUSTER6641} \
                                --ovn-northd-sb-db=\${OVNCLUSTER6642}
        ;;
        "ovn-run_nb_ovsdb-cluster-join") /usr/share/ovn/scripts/ovn-ctl run_nb_ovsdb \
                                --db-nb-addr=\${OVNHOSTIP} \
                                --db-sb-addr=\${OVNHOSTIP} \
                                --db-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes \
                                --ovn-northd-nb-db=\${OVNCLUSTER6641} \
                                --ovn-northd-sb-db=\${OVNCLUSTER6642} \
                                --db-nb-cluster-remote-addr=\${OVNCLUSTERJOINIP} \
                                --db-sb-cluster-remote-addr=\${OVNCLUSTERJOINIP} 
        ;;
        "ovn-run_sb_ovsdb-cluster") /usr/share/ovn/scripts/ovn-ctl run_sb_ovsdb \
                                --db-nb-addr=\${OVNHOSTIP} \
                                --db-sb-addr=\${OVNHOSTIP} \
                                --db-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes \
                                --ovn-northd-nb-db=\${OVNCLUSTER6641} \
                                --ovn-northd-sb-db=\${OVNCLUSTER6642}
        ;;
        "ovn-run_sb_ovsdb-cluster-join") /usr/share/ovn/scripts/ovn-ctl run_sb_ovsdb \
                                --db-nb-addr=\${OVNHOSTIP} \
                                --db-sb-addr=\${OVNHOSTIP} \
                                --db-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes \
                                --ovn-northd-nb-db=\${OVNCLUSTER6641} \
                                --ovn-northd-sb-db=\${OVNCLUSTER6642} \
                                --db-nb-cluster-remote-addr=\${OVNCLUSTERJOINIP} \
                                --db-sb-cluster-remote-addr=\${OVNCLUSTERJOINIP} 
        ;;
        "ovn-northd-host") ovn-northd  \
                                --ovnnb-db=tcp:\${OVNHOSTIP}:6641 \
                                --ovnsb-db=tcp:\${OVNHOSTIP}:6642 \
                                --no-chdir --log-file=/var/log/ovn/ovn-northd.log --pidfile=/var/run/ovn/ovn-northd.pid
        ;;
        "ovn-northd-cluster") ovn-northd  \
                                --ovnnb-db=\${OVNCLUSTER6641} \
                                --ovnsb-db=\${OVNCLUSTER6642} \
                                --no-chdir --log-file=/var/log/ovn/ovn-northd.log --pidfile=/var/run/ovn/ovn-northd.pid
        ;;
        "ovn-ic-host") ovn-ic -vconsole:emer -vsyslog:err -vfile:info \
                                --ovnnb-db=tcp:\${OVNICIP}:6641 \
                                --ovnsb-db=tcp:\${OVNICIP}:6642 \
                                --ic-nb-db=tcp:\${OVNHOSTIP}:6645 \
                                --ic-sb-db=tcp:\${OVNHOSTIP}:6646 \
                                --no-chdir --log-file=/var/log/ovn/ovn-ic.log --pidfile=/var/run/ovn/ovn-ic.pid --monitor
        ;;
        "ovn-ic-cluster") ovn-ic -vconsole:emer -vsyslog:err -vfile:info \
                                --ovnnb-db=\${OVNCLUSTER6641} \
                                --ovnsb-db=\${OVNCLUSTER6642} \
                                --ic-nb-db=\${OVNCLUSTER6645} \
                                --ic-sb-db=\${OVNCLUSTER6646} \
                                --no-chdir --log-file=/var/log/ovn/ovn-ic.log --pidfile=/var/run/ovn/ovn-ic.pid --monitor
        ;;
        "run_ic_sb_ovsdb-host") /usr/share/ovn/scripts/ovn-ctl run_ic_sb_ovsdb \
                                --db-ic-nb-create-insecure-remote=yes --db-ic-sb-create-insecure-remote=yes \
                                --db-ic-nb-addr=\${OVNHOSTIP} --db-ic-nb-port=6645 \
                                --db-ic-sb-addr=\${OVNHOSTIP} --db-ic-sb-port=6646 \
                                --ovn-ic-sb-db=tcp:6648:\${OVNHOSTIP} \
                                --ovn-ic-nb-db=tcp:6647:\${OVNHOSTIP} \
                                --db-ic-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-nb-cluster-local-port=6647 --db-ic-nb-cluster-remote-port=6647 \
                                --db-ic-sb-cluster-remote-port=6648 --db-ic-sb-cluster-local-port=6648 \
                                --db-ic-nb-cluster-local-proto=tcp --db-ic-nb-cluster-remote-proto=tcp \
                                --db-ic-sb-cluster-local-proto=tcp --db-ic-sb-cluster-remote-proto=tcp \
                                --ovn-northd-nb-db= \
                                --ovn-northd-sb-db=
        ;;
        "run_ic_nb_ovsdb-host") /usr/share/ovn/scripts/ovn-ctl run_ic_nb_ovsdb \
                                --db-ic-nb-create-insecure-remote=yes --db-ic-sb-create-insecure-remote=yes \
                                --db-ic-nb-addr=\${OVNHOSTIP} --db-ic-nb-port=6645 \
                                --db-ic-sb-addr=\${OVNHOSTIP}--db-ic-sb-port=6646 \
                                --ovn-ic-sb-db=tcp:6648:\${OVNHOSTIP} \
                                --ovn-ic-nb-db=tcp:6647:\${OVNHOSTIP} \
                                --db-ic-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-nb-cluster-local-port=6647 --db-ic-nb-cluster-remote-port=6647 \
                                --db-ic-sb-cluster-remote-port=6648 --db-ic-sb-cluster-local-port=6648 \
                                --db-ic-nb-cluster-local-proto=tcp --db-ic-nb-cluster-remote-proto=tcp \
                                --db-ic-sb-cluster-local-proto=tcp --db-ic-sb-cluster-remote-proto=tcp \
                                --ovn-northd-nb-db= \
                                --ovn-northd-sb-db=
        ;;
        "run_ic_sb_ovsdb-cluster") /usr/share/ovn/scripts/ovn-ctl run_ic_sb_ovsdb \
                                --db-ic-nb-create-insecure-remote=yes --db-ic-sb-create-insecure-remote=yes \
                                --db-ic-nb-addr=\${OVNHOSTIP} --db-ic-nb-port=6645 \
                                --db-ic-sb-addr=\${OVNHOSTIP} --db-ic-sb-port=6646 \
                                --ovn-ic-sb-db=\${OVNCLUSTER6648} \
                                --ovn-ic-nb-db=\${OVNCLUSTER6647} \
                                --db-ic-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-nb-cluster-local-port=6647 --db-ic-nb-cluster-remote-port=6647 \
                                --db-ic-sb-cluster-remote-port=6648 --db-ic-sb-cluster-local-port=6648 \
                                --db-ic-nb-cluster-local-proto=tcp --db-ic-nb-cluster-remote-proto=tcp \
                                --db-ic-sb-cluster-local-proto=tcp --db-ic-sb-cluster-remote-proto=tcp \
                                --ovn-northd-nb-db= \
                                --ovn-northd-sb-db=
        ;;
        "run_ic_nb_ovsdb-cluster") /usr/share/ovn/scripts/ovn-ctl run_ic_nb_ovsdb \
                                --db-ic-nb-create-insecure-remote=yes --db-ic-sb-create-insecure-remote=yes \
                                --db-ic-nb-addr=\${OVNHOSTIP} --db-ic-nb-port=6645 \
                                --db-ic-sb-addr=\${OVNHOSTIP} --db-ic-sb-port=6646 \
                                --ovn-ic-sb-db=\${OVNCLUSTER6648} \
                                --ovn-ic-nb-db=\${OVNCLUSTER6647} \
                                --db-ic-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-nb-cluster-local-port=6647 --db-ic-nb-cluster-remote-port=6647 \
                                --db-ic-sb-cluster-remote-port=6648 --db-ic-sb-cluster-local-port=6648 \
                                --db-ic-nb-cluster-local-proto=tcp --db-ic-nb-cluster-remote-proto=tcp \
                                --db-ic-sb-cluster-local-proto=tcp --db-ic-sb-cluster-remote-proto=tcp \
                                --ovn-northd-nb-db= \
                                --ovn-northd-sb-db=
        ;;
        "run_ic_sb_ovsdb-cluster-join") /usr/share/ovn/scripts/ovn-ctl run_ic_sb_ovsdb \
                                --db-ic-nb-create-insecure-remote=yes --db-ic-sb-create-insecure-remote=yes \
                                --db-ic-nb-addr=\${OVNHOSTIP} --db-ic-nb-port=6645 \
                                --db-ic-sb-addr=\${OVNHOSTIP} --db-ic-sb-port=6646 \
                                --ovn-ic-sb-db=\${OVNCLUSTER6648} \
                                --ovn-ic-nb-db=\${OVNCLUSTER6647} \
                                --db-ic-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-nb-cluster-local-port=6647 --db-ic-nb-cluster-remote-port=6647 \
                                --db-ic-sb-cluster-remote-port=6648 --db-ic-sb-cluster-local-port=6648 \
                                --db-ic-nb-cluster-local-proto=tcp --db-ic-nb-cluster-remote-proto=tcp \
                                --db-ic-sb-cluster-local-proto=tcp --db-ic-sb-cluster-remote-proto=tcp \
                                --ovn-northd-nb-db= \
                                --ovn-northd-sb-db= \
                                --db-ic-nb-cluster-remote-addr=\${OVNICCLUSTERJOINIP} \
                                --db-ic-sb-cluster-remote-addr=\${OVNICCLUSTERJOINIP}
        ;;
        "run_ic_nb_ovsdb-cluster-join") /usr/share/ovn/scripts/ovn-ctl run_ic_nb_ovsdb \
                                --db-ic-nb-create-insecure-remote=yes --db-ic-sb-create-insecure-remote=yes \
                                --db-ic-nb-addr=\${OVNHOSTIP} --db-ic-nb-port=6645 \
                                --db-ic-sb-addr=\${OVNHOSTIP} --db-ic-sb-port=6646 \
                                --ovn-ic-sb-db=\${OVNCLUSTER6648} \
                                --ovn-ic-nb-db=\${OVNCLUSTER6647} \
                                --db-ic-nb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-sb-cluster-local-addr=\${OVNHOSTIP} \
                                --db-ic-nb-cluster-local-port=6647 --db-ic-nb-cluster-remote-port=6647 \
                                --db-ic-sb-cluster-remote-port=6648 --db-ic-sb-cluster-local-port=6648 \
                                --db-ic-nb-cluster-local-proto=tcp --db-ic-nb-cluster-remote-proto=tcp \
                                --db-ic-sb-cluster-local-proto=tcp --db-ic-sb-cluster-remote-proto=tcp \
                                --ovn-northd-nb-db= \
                                --ovn-northd-sb-db= \
                                --db-ic-nb-cluster-remote-addr=\${OVNICCLUSTERJOINIP} \
                                --db-ic-sb-cluster-remote-addr=\${OVNICCLUSTERJOINIP}
        ;;
        *)  echo "$0 [ovsdb-init|ovsdb-server|ovs-vswitchd|ovs-controller|ovn-run_sb_ovsdb-host|ovn-run_nb_ovsdb-host|ovn-run_sb_ovsdb-cluster|ovn-run_nb_ovsdb-cluster|ovn-northd|ovn-ic-host|ovn-ic-cluster|ovn-run_ic_nb_ovsdb-host|ovn-run_ic_sb_ovsdb-host|ovn-run_ic_nb_ovsdb-cluster|ovn-run_ic_sb_ovsdb-cluster|ovn-run_nb_ovsdb-cluster-join|ovn-run_sb_ovsdb-cluster-join]"
            echo "OVN IC IP on OVN-IC on OVN CENTRAL"
            echo "OVN HOST IP  on OVN CENTRAL"
            echo "OVNICCLUSTERJOINIP IP IVN-IC INIT NODE"
            echo "OVNCLUSTERJOINIP IP OVN INIT NODE"
            echo "OVNCLUSTER6641  on OVN NB CENTRAL - tcp:x.x.x.x:6641,tcp:y.y.y.y:6642,tcp:z.z.z.z:6641"
            echo "OVNCLUSTER6642  on OVN SB CENTRAL - tcp:x.x.x.x:6642,tcp:y.y.y.y:6641,tcp:z.z.z.z:6642"
            echo "OVNCLUSTER6645  on OVN IC CLUSTER EXTERNAL PORT NB 6645 - tcp:x.x.x.x:6645,tcp:y.y.y.y:6645,tcp:z.z.z.z:6645"
            echo "OVNCLUSTER6646  on OVN IC CLUSTER EXTERNAL PORT SB 6646 - tcp:x.x.x.x:6646,tcp:y.y.y.y:6646,tcp:z.z.z.z:6646"
            echo "OVNCLUSTER6647  on OVN IC CLUSTER NB 6647 - tcp:6647:x.x.x.x,tcp:6647:y.y.y.y,tcp:6647:z.z.z.z"
            echo "OVNCLUSTER6648  on OVN IC CLUSTER SB 6648 - tcp:6648:x.x.x.x,tcp:6648:y.y.y.y,tcp:6648:z.z.z.z"
esac
EOF


chmod +x /root/ovn/start-ovn


cd /root/ovn-base

cat <<EOF>/root/ovn-base/Dockerfile 
FROM harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04
#FROM ubuntu:23.04
RUN mkdir -p  /etc/openvswitch
RUN mkdir /var/run/ovn/

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install gpg -y
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 5EDB1B62EC4926EA
RUN gpg --export 5EDB1B62EC4926EA >/etc/apt/5EDB1B62EC4926EA.gpg
RUN apt-key add /etc/apt/5EDB1B62EC4926EA.gpg
RUN echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu jammy-updates/antelope main" >> /etc/apt/sources.list
RUN apt update
RUN apt upgrade -y
RUN apt-get -y install tzdata
RUN apt-get install openvswitch-switch openvswitch-common iproute2 net-tools iputils-ping wget -y
RUN apt install openssl wget mc ovn-common ovn-host ovn-central ovn-ic ovn-ic-db -y
RUN apt-get install -y openvswitch-vtep ovn-controller-vtep
EOF

docker build -t ovn-base:v10 .
cd ..


gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 5EDB1B62EC4926EA
gpg --export 5EDB1B62EC4926EA >/etc/apt/5EDB1B62EC4926EA.gpg
apt-key add /etc/apt/5EDB1B62EC4926EA.gpg


cd  /root/ovn

cat <<EOF>/root/ovn/Dockerfile 
FROM ovn-base:v10

ENV OVNHOSTIP "Not Yer Set"
ENV OVNCMD "Not Yer Set"
ENV OVNICIP "Not Yer Set"
ENV OVNCLUSTERJOINIP "Not Yer Set"
ENV OVNICCLUSTERJOINIP "Not Yer Set"
ENV OVNCLUSTER6641 "Not Yer Set"
ENV OVNCLUSTER6642 "Not Yer Set"
ENV OVNCLUSTER6645 "Not Yer Set"
ENV OVNCLUSTER6646 "Not Yer Set"
ENV OVNCLUSTER6647 "Not Yer Set"
ENV OVNCLUSTER6648 "Not Yer Set"
ENV OVNCTEPGATEWAY "Not Yer Set"

COPY create_ovs_db.sh /etc/openvswitch/create_ovs_db.sh
RUN /etc/openvswitch/create_ovs_db.sh

COPY ovs-override.conf /etc/depmod.d/openvswitch.conf

COPY start-ovn /bin/start-ovn
CMD ["/bin/start-ovn"]
EOF

docker build -t ovn:v10 .
cd ..
