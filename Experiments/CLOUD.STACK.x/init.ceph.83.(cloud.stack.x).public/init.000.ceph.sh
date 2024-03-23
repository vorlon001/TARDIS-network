#!/usr/bin/bash

apt update
apt install -y python3-dev sshpass pdsh libffi-dev gcc libssl-dev python3-pip python3-virtualenv python3-venv nano curl  docker.io sshpass inetutils-ping mc jq

apt install openssh-server -y
/etc/init.d/ssh start
echo "root:root" | chpasswd

cat <<EOF> /etc/ssh/sshd_config
Include /etc/ssh/sshd_config.d/*.conf
Port 22
ListenAddress 0.0.0.0
SyslogFacility AUTH
LogLevel INFO
PermitRootLogin yes
StrictModes yes
MaxAuthTries 6
ChallengeResponseAuthentication no
UsePAM yes
AllowTcpForwarding yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp  /usr/lib/openssh/sftp-server
PasswordAuthentication yes
EOF

/etc/init.d/ssh restart
export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Yekaterinburg
apt-get install -y tzdata
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Yekaterinburg  /etc/localtime


cat <<EOF>>/etc/hosts
192.168.200.130 node130
192.168.200.131 node131
192.168.200.132 node132
192.168.200.133 node133
192.168.200.140 node140
192.168.200.141 node141
192.168.200.142 node142
192.168.200.143 node143
EOF

mkdir /etc/ansible
cat << EOF >/etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF


pip3 install -U pip
pip install --upgrade pip
pip3 install --user virtualenv==20.24
#pip3 install 'ansible-core>=2.14,<=2.15
pip3 install 'ansible==7.4.0' ## antilope
#pip3 install 'ansible==5.*'     ## zed
pip3 install python-openstackclient
pip3 install python-octaviaclient
pip3 install python-senlinclient
pip3 install docker
pip3 install python-openstackclient python-designateclient

#pip3 install -U pip
#pip install --upgrade pip
##pip3 install 'ansible-core>=2.12,<=2.12'
#pip3 install 'ansible==5.*'
#pip3 install docker

useradd vorlon
echo "vorlon:123" | chpasswd
echo "root:root" | chpasswd

