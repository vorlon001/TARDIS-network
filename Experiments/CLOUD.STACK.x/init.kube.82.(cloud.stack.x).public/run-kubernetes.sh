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

export DEBIAN_FRONTEND=noninteractive

ansible  -i node-hosts-all.yaml --become -m shell -a 'uptime' kubernetes || throw ${LINENO}
ANSIBLE_LOG_PATH=./ansible.init-kube-000.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-000.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ANSIBLE_LOG_PATH=./ansible.init-kube-001.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-001.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ANSIBLE_LOG_PATH=./ansible.init-kube-002.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-002.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ANSIBLE_LOG_PATH=./ansible.init-kube-003.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-003.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}

ANSIBLE_LOG_PATH=./ansible.init-kube-004.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-004.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ANSIBLE_LOG_PATH=./ansible.init-kube-005.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-005.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ANSIBLE_LOG_PATH=./ansible.init-kube-006.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-006.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ANSIBLE_LOG_PATH=./ansible.init-kube-007.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-007.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}

ANSIBLE_LOG_PATH=.//ansible.post-init-kube-050.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/post-init-kube-050.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ANSIBLE_LOG_PATH=.//ansible.post-init-kube-050.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/post-init-kube-051.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ANSIBLE_LOG_PATH=.//ansible.post-init-kube-050.log ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/post-init-kube-052.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}


# ansible  -i node-hosts-all.yaml --become -m shell -a 'mkdir -p /opt/local-path-provisioner' kubernetes
# ansible  -i node-hosts-all.yaml --become -m shell -a 'chmod 777 /opt/local-path-provisioner' kubernetes
