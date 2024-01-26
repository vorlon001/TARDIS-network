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


ANSIBLE_LOG_PATH=./ansible.deploy-docker-pull.log ansible-playbook -i hosts.yaml playbook/deploy-docker-pull.yaml  --extra-vars "@vars/docker-pull-vars.yaml"  || throw ${LINENO}

### ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"
### ansible-playbook release.yml --extra-vars '{"version":"1.23.45","other_variable":"foo"}'
### ansible-playbook arcade.yml --extra-vars '{"pacman":"mrs","ghosts":["inky","pinky","clyde","sue"]}'
### ansible-playbook arcade.yml --extra-vars "{\"name\":\"Conan O\'Brien\"}"
### ansible-playbook arcade.yml --extra-vars '{"name":"Conan O'\\\''Brien"}'
### ansible-playbook script.yml --extra-vars "{\"dialog\":\"He said \\\"I just can\'t get enough of those single and double-quotes"\!"\\\"\"}"
### ansible-playbook release.yml --extra-vars "@some_file.json"
### ansible-playbook release.yml --extra-vars "@vars.yaml"

