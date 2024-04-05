#!/usr/bin/bash

function throw()
{
   errorCode=$?
   echo "Error: ($?) LINENO:$1"
   exit $errorCode
}

function check_error {
  if [ $? -ne 0 ]; then
    echo "Error: ($?) LINENO:$1"
    exit 1
  fi
}

apt install -y sshpass pdsh moreutils || throw ${LINENO}


echo root >password.node || throw ${LINENO}
sshpass -f password.node  ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.180 || throw ${LINENO}
sshpass -f password.node  ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.181 || throw ${LINENO}
sshpass -f password.node  ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.182 || throw ${LINENO}


ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.181 mkdir -p /etc/kubernetes/pki || throw ${LINENO}
ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.181 mkdir -p /etc/kubernetes/pki/etcd || throw ${LINENO}
ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.181 apt install -y ipvsadm || throw ${LINENO}
ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.181 mkdir -p /etc/kubernetes/policies/ || throw ${LINENO}

ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.182 mkdir -p /etc/kubernetes/pki || throw ${LINENO}
ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.182 mkdir -p /etc/kubernetes/pki/etcd || throw ${LINENO}
ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.182 apt install -y ipvsadm || throw ${LINENO}
ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.200.182 mkdir -p /etc/kubernetes/policies/ || throw ${LINENO}


scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/policies/audit-policy.yaml root@192.168.200.181:/etc/kubernetes/policies/audit-policy.yaml || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/policies/audit-policy.yaml root@192.168.200.182:/etc/kubernetes/policies/audit-policy.yaml || throw ${LINENO}

scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/ca* root@192.168.200.181:/etc/kubernetes/pki || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/front-proxy-ca*  root@192.168.200.181:/etc/kubernetes/pki || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/apiserver-etcd*  root@192.168.200.181:/etc/kubernetes/pki || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/sa* root@192.168.200.181:/etc/kubernetes/pki || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/etcd/ca* root@192.168.200.181:/etc/kubernetes/pki/etcd/ || throw ${LINENO}


scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/ca* root@192.168.200.182:/etc/kubernetes/pki || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/front-proxy-ca*  root@192.168.200.182:/etc/kubernetes/pki || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/apiserver-etcd* root@192.168.200.182:/etc/kubernetes/pki || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/sa* root@192.168.200.182:/etc/kubernetes/pki || throw ${LINENO}
scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /etc/kubernetes/pki/etcd/ca* root@192.168.200.182:/etc/kubernetes/pki/etcd/ || throw ${LINENO}

cp /etc/kubernetes/pki/*  /usr/local/share/ca-certificates/
update-ca-certificates || throw ${LINENO}

cp /etc/kubernetes/pki/etcd/*  /usr/local/share/ca-certificates/
update-ca-certificates || throw ${LINENO}



