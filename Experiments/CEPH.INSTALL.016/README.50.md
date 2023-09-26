```

docker run -it --rm --hostname ceph-x --name ceph-x -v /var/run/docker.sock:/var/run/docker.sock harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04 bash

```

```

- block:
  when:
      - inventory_hostname in groups['opensearch-data']

```

### ----------------------

```

cat <<EOF>local_import_1.yaml
  - name: Debug Msg
    debug:
        msg="33333333333333"
  - name: Debug Msg
    ansible.builtin.shell:
      cmd: ps auxf && id && pwd
    register: details
  - debug:
      msg:
        cmd: "{{ details.cmd }}"
        stdout_lines: "{{ details.stdout_lines }}"
        stderr_lines:  "{{ details.stderr_lines }}"

  - name: run task_block_1
    ansible.builtin.shell: "{{ item }}"
    loop: "{{ task_block_1 }}"
    register: details

  - name: Debug Msg
    debug:
        msg:
          cmd: "{{ item.cmd }}"
          stdout_lines: "{{ item.stdout_lines }}"
          stderr_lines:  "{{ item.stderr_lines }}"
    loop: "{{ details.results }}"
EOF


cat <<EOF>local.yaml
---
- hosts: localhost
  become: yes
  vars:
    task_block_1:
      - ps auxf
      - id
      - pwd
    pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - docker.io
      - containerd
      - ntpdate
  tasks:
  - block:

    - import_tasks: local_import_1.yaml

  - name: Install a list of packages
    ansible.builtin.apt:
      name: "{{ item }}"
      update_cache: yes
    loop: "{{ pkgs }}"

  - name: Debug Msg
    debug:
        msg="33333333333333"
  - name: Debug Msg
    ansible.builtin.shell:
      cmd: ps auxf && id && pwd
    register: details
  - debug:
      msg:
        cmd: "{{ details.cmd }}"
        stdout_lines: "{{ details.stdout_lines }}"
        stderr_lines:  "{{ details.stderr_lines }}"
EOF

ansible-playbook local.yaml


```
