#!/usr/bin/bash


ansible  -i node-hosts-all.yaml --become -m shell -a 'uptime' kubernetes
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-000.yaml
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-001.yaml
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-002.yaml
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-003.yaml

ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-004.yaml
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-005.yaml
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-006.yaml
ansible-playbook -i  node-hosts-all.yaml playbook-kubernetes/init-kube-007.yaml

