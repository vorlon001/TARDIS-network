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
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-000.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-001.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-002.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-003.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}

ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-004.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-005.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-006.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-007.yaml --extra-vars "@run-kubernetes.vars.yaml" || throw ${LINENO}

