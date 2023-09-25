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



ansible-playbook -i hosts.yaml playbook.001.init-server.yaml  --extra-vars "@vars.yaml"  || throw ${LINENO}
ansible-playbook -i hosts.yaml playbook.002.install-ceph.yaml --extra-vars "@vars.yaml"  || throw ${LINENO}
ansible-playbook -i hosts.yaml playbook.003.install-ceph.yaml  --extra-vars "@vars.yaml"  || throw ${LINENO}

### ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"
### ansible-playbook release.yml --extra-vars '{"version":"1.23.45","other_variable":"foo"}'
### ansible-playbook arcade.yml --extra-vars '{"pacman":"mrs","ghosts":["inky","pinky","clyde","sue"]}'
### ansible-playbook arcade.yml --extra-vars "{\"name\":\"Conan O\'Brien\"}"
### ansible-playbook arcade.yml --extra-vars '{"name":"Conan O'\\\''Brien"}'
### ansible-playbook script.yml --extra-vars "{\"dialog\":\"He said \\\"I just can\'t get enough of those single and double-quotes"\!"\\\"\"}"
### ansible-playbook release.yml --extra-vars "@some_file.json"
### ansible-playbook release.yml --extra-vars "@vars.yaml"

ansible-playbook -i hosts.yaml playbook.004.install-ceph.yaml --extra-vars "@vars.yaml"  || throw ${LINENO}
ansible-playbook -i hosts.yaml playbook.005.install-ceph.yaml --extra-vars "@vars.yaml"  || throw ${LINENO}
ansible-playbook -i hosts.yaml playbook.006.install-ceph.yaml --extra-vars "@vars.yaml"  || throw ${LINENO}
ansible-playbook -i hosts.yaml playbook.007.install-ceph.yaml --extra-vars "@vars.yaml"  || throw ${LINENO}
ansible-playbook -i hosts.yaml playbook.008.install-ceph.yaml --extra-vars "@vars.yaml"  || throw ${LINENO}

