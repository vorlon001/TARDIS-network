```

docker run -it --rm --hostname ceph-x --name ceph-x -v /var/run/docker.sock:/var/run/docker.sock harbor.iblog.pro/test/ubuntu:main.ubuntu.22.04 bash

```

```


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
192.168.200.140 node140
192.168.200.141 node141
192.168.200.142 node142
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
#pip3 install 'ansible-core>=2.12,<=2.12'
pip3 install 'ansible==5.*'
pip3 install docker

useradd vorlon
echo "vorlon:123" | chpasswd
echo "root:root" | chpasswd



#################### ----------------- #################### ----------------- #################### ----------------- #################### ----------------- #################### -----------------


cat <<EOF>hosts.yaml
[all]
node140 ansible_ssh_host=192.168.200.140
node141 ansible_ssh_host=192.168.200.141
node142 ansible_ssh_host=192.168.200.142

[all:vars]
ansible_connection=ssh
ansible_user=root
ansible_ssh_pass=root

[bootstrap]
node140 ansible_ssh_host=192.168.200.140

[bootstrap:vars]
ansible_connection=ssh
ansible_user=root
ansible_ssh_pass=root

EOF


cat <<EOF>vars.yaml
public_network: 192.168.200.0/24
cluster_network: 192.168.201.0/24
ceph_version: v18.2
wait_seconds: 30
attached_node:
  - node141
  - node142
attached_node_mon:
  - node141
  - node142
attached_node_mgr:
  - node141
  - node142
attached_node_diag:
  - ceph orch device ls
  - ceph orch host ls
  - ceph orch ps
  - cephadm shell -- ceph -s
ceph_rbd:
  - name: images
    pg_num_1: 32
    pg_num_2: 32
  - name: volumes
    pg_num_1: 32
    pg_num_2: 32
  - name: backups
    pg_num_1: 32
    pg_num_2: 32
  - name: vms
    pg_num_1: 32
    pg_num_2: 32
ceph_osd:
  - name: node140
    packages:
      - sdb
      - sdc
      - sdd
  - name: node141
    packages:
      - sdb
      - sdc
      - sdd
  - name: node142
    packages:
      - sdb
      - sdc
      - sdd
ceph_s3:
  - name: cloud
    port: 8060
    tenant: testx
    uid: tester
    displayname: "Test User"
    access_key: TESTER
    secret_key: test123
    maxobjects: 1000
    maxsize: 9000000000
    user: subtester
    user_access_key: SYSTEM_ACCESS_KEY
    user_secret_key: SYSTEM_SECRET_KEY
configure_ceph:
      - cephadm list-networks
      - cephadm shell -- ceph -s
      - cephadm install ceph-common
      - cephadm pull
      - cephadm ls
      - ceph config get mon
      - ceph config get mgr
      - ceph config set mon public_network {{ public_network }}
      - ceph config set global cluster_network {{ cluster_network }}
      - ceph config get mon
      - ceph config get mgr
      - ceph mgr module enable prometheus
      - ceph mgr module enable dashboard
      - ceph mgr module enable balancer
      - ceph balancer mode upmap
      - ceph balancer on
      - cephadm shell -- ceph -s
      - ceph orch ps
diagnostic_post_deploy:
      - ceph orch ls osd --export
      - ceph orch ls osd
      - ceph orch device ls
      - ceph osd tree
      - cephadm ceph-volume lvm list
      - ceph dashboard ac-user-show
      - ceph orch device ls
      - cephadm shell -- ceph -s
      - ceph osd df tree
      - ceph orch status
      - ceph orch device ls --wide
      - ceph orch ps
      - ceph mon dump
EOF


ansible -i hosts.yaml -m debug -a "var=hostvars[inventory_hostname]"  --extra-vars "@vars.yaml" all




mkdir -p templates/etc
cat <<EOF>templates/etc/hosts.j2
# Your system has configured 'manage_etc_hosts' as True.
# As a result, if you wish for changes to this file to persist
# then you will need to either
# a.) make changes to the master file in /etc/cloud/templates/hosts.debian.tmpl
# b.) change or remove the value of 'manage_etc_hosts' in
#     /etc/cloud/cloud.cfg or cloud-config from user-data
#
127.0.1.1 {{ inventory_hostname }}.cloud.local {{ inventory_hostname }}
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Network nodes as generated through Ansible.

{% for host in groups['all'] %}
{{ hostvars[host]['ansible_facts']['default_ipv4']['address'] }} {{ host }}
{% endfor %}
EOF



cat <<EOF>playbook.001.init-server.yaml
---
- hosts: all
  become: yes
  tasks:
    - name: "generate /etc/hosts.ansible file"
      template: "src=etc/hosts.j2 dest='/etc/hosts.ansible' owner=root group=root mode=0644"
      become: true
    - name: "check if debian generated hosts file has a backup"
      stat: "path=/etc/hosts.debian"
      register: etc_hosts_debian
    - name: Print to screen google authenticator details
      command: /bin/cat /etc/hosts.ansible
      register: details
    - debug: msg="{{ details.stdout_lines }}"
    - name: "backup debian generated /etc/hosts"
      command: "cp /etc/hosts /etc/hosts.debian"
      when: etc_hosts_debian.stat.islnk is not defined
      become: true
    - name: "install /etc/hosts.ansible file"
      command: "cp /etc/hosts.ansible /etc/hosts"
      become: true

    - name: Print to screen google authenticator details
      command: /bin/cat /etc/hosts.debian
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: Print to screen google authenticator details
      command: /bin/cat /etc/hosts.ansible
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: Install a list of packages
      ansible.builtin.apt:
        update_cache: yes
        pkg:
        - apt-transport-https
        - ca-certificates
        - curl
        - gnupg
        - lsb-release
        - docker.io
        - containerd
        - ntpdate

    - name: ntpdate -u pool.ntp.org
      ansible.builtin.shell:
        cmd: ntpdate -u pool.ntp.org
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: sed -i '/#NTP=/a NTP=time.google.com' /etc/systemd/timesyncd.conf
      ansible.builtin.shell:
        cmd: sed -i '/#NTP=/a NTP=time.google.com' /etc/systemd/timesyncd.conf

    - name: Restart service systemd-timesyncd
      ansible.builtin.systemd:
        state: restarted
        daemon_reload: true
        name: systemd-timesyncd

    - name: timedatectl
      ansible.builtin.shell:
        cmd: timedatectl
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: apt list --installed |grep ^lvm
      ansible.builtin.shell:
        cmd: apt list --installed | grep ^lvm
      register: details
    - debug: msg="{{ details.stdout_lines }}"

EOF

ansible-playbook -i hosts.yaml playbook.001.init-server.yaml  --extra-vars "@vars.yaml"



cat <<EOF>playbook.004.install-ceph.yaml
---
- hosts: bootstrap
  become: yes
  tasks:
 

    - name: Download https://raw.githubusercontent.com/ceph/ceph/reef/src/cephadm/cephadm.py
      ansible.builtin.get_url:
        url: https://raw.githubusercontent.com/ceph/ceph/reef/src/cephadm/cephadm.py
        dest: /usr/bin/cephadm
        mode: '777'


    - name: cephadm add-repo --release reef
      ansible.builtin.shell:
        cmd: cephadm add-repo --release reef
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: apt update
      ansible.builtin.shell:
        cmd: apt update
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: cephadm install
      ansible.builtin.shell:
        cmd: cephadm install
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: mkdir -p /etc/ceph
      ansible.builtin.shell:
        cmd: mkdir -p /etc/ceph
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: apt update
      ansible.builtin.shell:
        cmd: cephadm --image harbor.iblog.pro/quayio/ceph/ceph:{{ ceph_version }} bootstrap  --mon-ip {{ hostvars[inventory_hostname]['ansible_facts']['default_ipv4']['address'] }} --allow-overwrite
      register: details
    - debug: msg="{{ details.stdout_lines }}"

    - name: configure ceph
      ansible.builtin.shell: "{{ item}}"
      loop: "{{ configure_ceph }}"
      register: details

    - name: Debug Msg
      debug:
          msg="{{ item.stdout_lines }}"
      loop: "{{ details.results }}"
- hosts: bootstrap
  become: yes
  gather_facts: false
  remote_user: root
  tasks:
    - name: fetch all public ssh keys
      shell: cat /etc/ceph/ceph.pub
      register: ssh_keys

    - name: check keys
      debug: msg="{{ ssh_keys.stdout }}"

    - name: deploy keys on all servers
      authorized_key: user=root key="{{ item[0] }}"
      delegate_to: "{{ item[1] }}"
      with_nested:
        - "{{ ssh_keys.stdout }}"
        - "{{groups['all']}}"
      tags:
        - ssh
EOF

ansible-playbook -i hosts.yaml playbook.004.install-ceph.yaml --extra-vars "@vars.yaml"



cat <<EOF>playbook.005.install-ceph.yaml
---
- hosts: bootstrap
  become: yes
  tasks:
  - name: ceph orch host add nodeXXX
    ansible.builtin.shell:
      cmd: ceph orch host add {{ item }}
    loop: "{{ attached_node }}"

  - name: ceph orch host ls
    ansible.builtin.shell:
      cmd: ceph orch host ls
    register: details
  - debug: msg="{{ details.stdout_lines }}"

  - name: ceph orch apply mon xxxxxxx
    ansible.builtin.shell:
      cmd: ceph orch apply mon {{ inventory_hostname }}{% for host in attached_node_mon %},{{ host }}{% endfor %}
    register: details
  - debug: msg="{{ details.stdout_lines }}"

  - name: ceph -s
    ansible.builtin.shell:
      cmd: ceph -s
    register: details
  - debug: msg="{{ details.stdout_lines }}"

  - name: ceph orch apply mgr xxxxxxx
    ansible.builtin.shell:
      cmd: ceph orch apply mgr {{ inventory_hostname }}{% for host in attached_node_mgr %},{{ host }}{% endfor %}
    register: details
  - debug: msg="{{ details.stdout_lines }}"

  - name: ceph -s
    ansible.builtin.shell:
      cmd: ceph -s
    register: details
  - debug: msg="{{ details.stdout_lines }}"


  - name: pause for {{ wait_seconds | int }} second(s)
    ansible.builtin.pause:
      seconds: "{{ wait_seconds | int }}"

  - name: ceph orch host add nodeXXX
    ansible.builtin.shell: "{{ item}}"
    loop: "{{ attached_node_diag }}"
    register: details

  - name: Debug Msg
    debug:
        msg="{{ item.stdout_lines }}"
    loop: "{{ details.results }}"


EOF

ansible-playbook -i hosts.yaml playbook.005.install-ceph.yaml  --extra-vars "@vars.yaml"




### Defining variables at runtime
### You can define variables when you run your playbook by passing variables at the command line using the --extra-vars (or -e) argument. You can also request user input with a vars_prompt (see Interactive input: prompts). When you pass variables at the command line, use a single quoted string, that contains one or more variables, in one of the formats below.
### 
### key=value format
### Values passed in using the key=value syntax are interpreted as strings. Use the JSON format if you need to pass non-string values such as Booleans, integers, floats, lists, and so on.
### 
### ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"
### JSON string format
### ansible-playbook release.yml --extra-vars '{"version":"1.23.45","other_variable":"foo"}'
### ansible-playbook arcade.yml --extra-vars '{"pacman":"mrs","ghosts":["inky","pinky","clyde","sue"]}'
### When passing variables with --extra-vars, you must escape quotes and other special characters appropriately for both your markup (for example, JSON), and for your shell:
### 
### ansible-playbook arcade.yml --extra-vars "{\"name\":\"Conan O\'Brien\"}"
### ansible-playbook arcade.yml --extra-vars '{"name":"Conan O'\\\''Brien"}'
### ansible-playbook script.yml --extra-vars "{\"dialog\":\"He said \\\"I just can\'t get enough of those single and double-quotes"\!"\\\"\"}"
### vars from a JSON or YAML file
### If you have a lot of special characters, use a JSON or YAML file containing the variable definitions. Prepend both JSON and YAML filenames with @.
### 
### ansible-playbook release.yml --extra-vars "@some_file.json"
### ansible-playbook release.yml --extra-vars "@vars.yaml"




cat <<EOF>playbook.006.install-ceph.yaml
---
- hosts: bootstrap
  become: yes
  tasks:
    - name: ceph orch daemon add osd .....
      ansible.builtin.shell:
        cmd: ceph orch daemon add osd {{ item.0.name }}:/dev/{{ item.1 }}
      loop: "{{ ceph_osd | subelements('packages') }}"
    - name: pause for {{ wait_seconds | int }} second(s)
      ansible.builtin.pause:
        seconds: "{{ wait_seconds | int }}"
    - name: ceph orch device ls
      ansible.builtin.shell:
        cmd: ceph orch device ls
      register: details
    - debug: msg="{{ details.stdout_lines }}"
- name: Post Install Ceph
  hosts: bootstrap
  gather_facts: no
  tasks:

  - name: run cmd ceph .........
    ansible.builtin.shell: "{{ item}}"
    loop: "{{ diagnostic_post_deploy }}"
    register: details

  - name: Debug Msg
    debug:
        msg="{{ item.stdout_lines }}"
    loop: "{{ details.results }}"

EOF

ansible-playbook -i hosts.yaml playbook.006.install-ceph.yaml --extra-vars "@vars.yaml"




cat <<EOF>playbook.016.install-ceph.yaml
---
- hosts: bootstrap
  become: yes
  tasks:
  - name: ceph orch host label add ... rgw
    ansible.builtin.shell: "ceph orch host label add  {{ item.name }} rgw"
    loop: "{{ ceph_osd }}"
    register: details

  - name: Debug Msg
    debug:
        msg="{{ item.stdout_lines }}"
    loop: "{{ details.results }}"


  - name: Debug Msg
    debug:
        msg="{{ item.stdout_lines }}"
    loop: "{{ details.results }}"

  - name: ceph osd pool create .... .... ....
    ansible.builtin.shell:
      cmd: ceph osd pool create {{ item.name }} {{ item.pg_num_1 }} {{ item.pg_num_1 }}
    loop: "{{ ceph_rbd }}"
  - name: pause for {{ wait_seconds | int }} second(s)
    ansible.builtin.pause:
      seconds: "{{ wait_seconds | int }}"

  - name: ceph osd pool ls
    ansible.builtin.shell:
      cmd: ceph osd pool ls
    register: details
  - debug: msg="{{ details.stdout_lines }}"

  - name: ceph osd pool application enable ..... rbd
    ansible.builtin.shell:
      cmd: ceph osd pool application enable {{ item.name }} rbd
    loop: "{{ ceph_rbd }}"

  - name: pause for {{ wait_seconds | int }} second(s)
    ansible.builtin.pause:
      seconds: "{{ wait_seconds | int }}"

  - name: ceph auth list
    ansible.builtin.shell:
      cmd: ceph auth list
    register: details
  - debug: msg="{{ details.stdout_lines }}"

  - name: ceph auth get client.admin
    ansible.builtin.shell:
      cmd: ceph auth get client.admin
    register: details
  - debug: msg="{{ details.stdout_lines }}"


  - name: ceph auth get-or-create client.....
    ansible.builtin.shell:
      cmd: ceph auth get-or-create client.{{ item.name }}
    loop: "{{ ceph_rbd }}"
  - name: pause for {{ wait_seconds | int }} second(s)
    ansible.builtin.pause:
      seconds: "{{ wait_seconds | int }}"

  - name: ceph auth caps client..... mon 'allow r' osd 'allow rwx pool=images'
    ansible.builtin.shell:
      cmd: ceph auth caps client.{{ item.name }} mon 'allow r' osd 'allow rwx pool=images'
    loop: "{{ ceph_rbd }}"
  - name: pause for {{ wait_seconds | int }} second(s)
    ansible.builtin.pause:
      seconds: "{{ wait_seconds | int }}"

  - name: ceph auth get client.....
    ansible.builtin.shell:
      cmd: ceph auth get client.{{ item.name }}
    loop: "{{ ceph_rbd }}"
  - name: pause for {{ wait_seconds | int }} second(s)
    ansible.builtin.pause:
      seconds: "{{ wait_seconds | int }}"

  - name: ceph auth get client..... -o ~/ceph.client.....keyring
    ansible.builtin.shell:
      cmd: ceph auth get client.{{ item.name }} -o ~/ceph.client.{{ item.name }}.keyring
    loop: "{{ ceph_rbd }}"

EOF

ansible-playbook -i hosts.yaml playbook.016.install-ceph.yaml --extra-vars "@vars.yaml"






cat <<EOF>playbook.017.install-ceph.yaml
---
- hosts: bootstrap
  become: yes
  tasks:
  - name: ansible copy file from remote to local.
    loop: "{{ ceph_rbd }}"
    fetch:
     src: /root/ceph.client.{{ item.name }}.keyring
     dest: /

EOF

ansible-playbook -i hosts.yaml playbook.017.install-ceph.yaml --extra-vars "@vars.yaml"



root@ceph-x:/# ls -la node140/root/ceph.client.images.keyring
-rw-r--r-- 1 root root 122 Sep 25 18:01 node140/root/ceph.client.images.keyring






cat <<EOF>playbook.024.install-ceph.yaml
---
- hosts: bootstrap
  become: yes
  tasks:
 
   - name: ceph orch apply rgw ....
     ansible.builtin.shell:
       cmd: ceph orch apply rgw {{ item.name }}
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"


   - name: ceph orch apply rgw ....
     ansible.builtin.shell:
       cmd: ceph orch apply rgw {{ item.name }} --port={{ item.port }}
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"

   - name: ceph orch apply rgw ....
     ansible.builtin.shell:
       cmd: ceph orch apply rgw {{ item.name }} '--placement=label:rgw count-per-host:1' --port={{ item.port }}
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"

   - name: pause for {{ wait_seconds | int }} second(s)
     ansible.builtin.pause:
       seconds: "{{ wait_seconds | int }}"

EOF

ansible-playbook -i hosts.yaml playbook.024.install-ceph.yaml --extra-vars "@vars.yaml"


cat <<EOF>playbook.026.install-ceph.yaml
---
- hosts: bootstrap
  become: yes
  tasks:

   - name: radosgw-admin .... stage 1
     ansible.builtin.shell:
       cmd: radosgw-admin --tenant {{ item.tenant }} --uid {{ item.uid }} --display-name "{{ item.displayname }}" --access_key {{ item.access_key }} --secret {{ item.secret_key }} user create
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"

   - name: radosgw-admin .... stage 2
     ansible.builtin.shell:
       cmd: radosgw-admin subuser create --tenant {{ item.tenant }} --uid={{ item.uid }} --subuser={{ item.user }} --access=readwrite
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"


   - name: radosgw-admin .... stage 3
     ansible.builtin.shell:
       cmd: radosgw-admin quota enable --quota-scope=user --tenant {{ item.tenant }} --uid={{ item.uid }} --max-objects={{ item.maxobjects }} --max-size={{ item.maxsize }}
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"


   - name: radosgw-admin .... stage 4
     ansible.builtin.shell:
       cmd: radosgw-admin user info --tenant {{ item.tenant }}  --uid={{ item.uid }}
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"

   - name: radosgw-admin .... stage 5
     ansible.builtin.shell:
       cmd: radosgw-admin user info --tenant {{ item.tenant }} --uid={{ item.uid }}  --access-key={{ item.user_access_key }} --secret={{ item.user_secret_key }}
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"


   - name: radosgw-admin .... stage 6
     ansible.builtin.shell:
       cmd: radosgw-admin user modify --tenant {{ item.tenant }} --uid={{ item.uid }}  --access-key={{ item.user_access_key }} --secret={{ item.user_secret_key }}
     loop: "{{ ceph_s3 }}"
     register: details
   - name: Debug Msg
     debug:
         msg="{{ item.stdout_lines }}"
     loop: "{{ details.results }}"

EOF

ansible-playbook -i hosts.yaml playbook.026.install-ceph.yaml --extra-vars "@vars.yaml"


```
