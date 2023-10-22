

https://github.com/vitabaks/postgresql_cluster`-
https://elma365.com/ru/help/platform/configure-hot-standby-postgresql.html

https://github.com/IlgizMamyshev/pgsql_cluster/tree/master


###  схема стенда
node5
path: /cloud/TEST.1/postgresql_cluster
```
192.168.200.140
192.168.200.141
192.168.200.142
```

node4
path: /cloud/TEST.1/postgresql_cluster.2
```
192.168.200.180
192.168.200.181
192.168.200.182
```


# change ansible role

edit: /cloud/TEST.1/postgresql_cluster/roles/haproxy/templates/haproxy.cfg.j2
edit: /cloud/TEST.1/postgresql_cluster.2/roles/haproxy/templates/haproxy.cfg.j2
```
listen master5432
{% if cluster_vip is defined and cluster_vip | length > 0 %}
    bind {{ cluster_vip }}:{{ postgresql_port }}
{% else %}
    bind {{ hostvars[inventory_hostname]['inventory_hostname'] }}:{{ haproxy_listen_port.master }}
{% endif %}
    maxconn {{ haproxy_maxconn.master }}
    option tcplog
    option httpchk OPTIONS /primary
    http-check expect status 200
    default-server inter 3s fastinter 1s fall 3 rise 4 on-marked-down shutdown-sessions
{% if pgbouncer_install|bool %}
  {% for host in groups['postgres_cluster'] %}
server {{ hostvars[host]['ansible_hostname'] }} {{ hostvars[host]['inventory_hostname'] }}:{{ postgresql_port }} check port {{ patroni_restapi_port }}
  {% endfor %}
{% endif %}
```

edit: /cloud/TEST.1/postgresql_cluster/roles/confd/templates/haproxy.tmpl.j2
edit: /cloud/TEST.1/postgresql_cluster.2/roles/confd/templates/haproxy.tmpl.j2
```
listen master
{% if cluster_vip is defined and cluster_vip | length > 0 %}
    bind {{ cluster_vip }}:{{ postgresql_port }}
{% else %}
    bind {{ hostvars[inventory_hostname]['inventory_hostname'] }}:{{ haproxy_listen_port.master }}
{% endif %}
    maxconn {{ haproxy_maxconn.master }}
    option tcplog
    option httpchk OPTIONS /primary
    http-check expect status 200
    default-server inter 3s fastinter 1s fall 3 rise 4 on-marked-down shutdown-sessions
{% if pgbouncer_install|bool %}
{% raw %}{{range gets "/members/*"}} server {{base .Key}} {{$data := json .Value}}{{base (replace (index (split (index (split $data.conn_url ":") 1) "/") 2) "@" "/" -1)}}:{% endraw %}{{ postgresql_port }}{% raw %} check port {{index (split (index (split $data.api_url "/") 2) ":") 1}}
{{end}}{% endraw %}
{% endif %}
```


edit: /cloud/TEST.1/postgresql_cluster/roles/keepalived/templates/keepalived.conf.j2
edit: /cloud/TEST.1/postgresql_cluster.2/roles/keepalived/templates/keepalived.conf.j2
```
global_defs {
   router_id ocp_vrrp
   enable_script_security
   script_user root
}

vrrp_script haproxy_check {
   script "/usr/libexec/keepalived/haproxy_check.sh"
   interval 2
   weight 2
}

vrrp_instance VI_1 {
   interface {{ vip_interface }}
   virtual_router_id {{ cluster_vip.split('.')[3] | int }}
   priority  100
   advert_int 2
   state  BACKUP
   virtual_ipaddress {
       {{ cluster_vip  }}
   }

   unicast_src_ip {{ ansible_default_ipv4.address }}
   unicast_peer {
{% for host in groups['balancers'] %}{% if  hostvars[host]['ansible_facts']['default_ipv4']['address']  != ansible_default_ipv4.address %}
           {{ hostvars[host]['ansible_facts']['default_ipv4']['address'] }}
{% endif %}{% endfor %}
   }

   track_script {
       haproxy_check
   }
   authentication {
      auth_type {{ keepalived_auth_type}}
      auth_pass {{ keepalived_auth_pass}}
   }
}
```




change only ansible role standby
edit: /cloud/TEST.1/postgresql_cluster.2/roles/pgbouncer/config/tasks/main.yml
```
# if pgbouncer_auth_user is 'false'
- block:
    - name: Get users and password md5 from pg_shadow
      run_once: true
      become: true
      become_user: postgres
      ansible.builtin.command: >-
        {{ postgresql_bin_dir }}/psql -p {{ postgresql_port }} -U {{ patroni_superuser_username }} -d postgres -tAXcq
        "SELECT concat('\"', usename, '\" \"', passwd, '\"') FROM pg_shadow where usename != '{{ patroni_replication_username }}'"
      register: pg_shadow_result
      changed_when: false
      delegate_to: "{{ groups.master[0] }}"

    - name: "Generate {{ pgbouncer_conf_dir }}/userlist.txt"
      become: true
      become_user: postgres
      ansible.builtin.copy:
        content: |
          {{ pg_shadow_result.stdout }}
        dest: "{{ pgbouncer_conf_dir }}/userlist.txt"
      notify: "reload pgbouncer"
      when:
        - pg_shadow_result.rc == 0
        - pg_shadow_result.stdout is defined
        - pg_shadow_result.stdout | length > 0
  when: pgbouncer_auth_user|bool
  tags: pgbouncer, pgbouncer_conf, pgbouncer_generate_userlist

# if pgbouncer_auth_user is 'true'
- name: "Create function 'user_search' for pgbouncer 'auth_query' option in all databases"
  become: true
  become_user: postgres
  ansible.builtin.shell: |
    for db in $({{ postgresql_bin_dir }}/psql -p {{ postgresql_port }} -U {{ patroni_superuser_username }} -d postgres -tAXc \
    "select datname from pg_catalog.pg_database where datname <> 'template0'"); do
      {{ postgresql_bin_dir }}/psql -p {{ postgresql_port }} -U {{ patroni_superuser_username }} -d "$db" -tAXc '
        CREATE OR REPLACE FUNCTION user_search(uname TEXT) RETURNS TABLE (usename name, passwd text) AS
        $$
        SELECT usename, passwd FROM pg_shadow WHERE usename=$1;
        $$
        LANGUAGE sql SECURITY DEFINER;
        REVOKE ALL ON FUNCTION user_search(uname TEXT) FROM public;
        GRANT EXECUTE ON FUNCTION user_search(uname TEXT) TO {{ pgbouncer_auth_username }};
      '; done
  args:
    executable: /bin/bash
  when: pgbouncer_auth_user|bool and is_master|bool
  tags: pgbouncer, pgbouncer_conf, pgbouncer_auth_query
```

###  inventory стенда node5

inventory master node5
inventory
```
# if dcs_exists: false and dcs_type: "etcd"
[etcd_cluster]  # recommendation: 3, or 5-7 nodes
192.168.200.140
192.168.200.141
192.168.200.142

# if dcs_exists: false and dcs_type: "consul"
[consul_instances]  # recommendation: 3 or 5-7 nodes
192.168.200.140 consul_node_role=server consul_bootstrap_expect=true consul_datacenter=dc1
192.168.200.141 consul_node_role=server consul_bootstrap_expect=true consul_datacenter=dc1
192.168.200.142 consul_node_role=server consul_bootstrap_expect=true consul_datacenter=dc1
#192.168.200.144 consul_node_role=client consul_datacenter=dc1
#192.168.200.145 consul_node_role=client consul_datacenter=dc2

# if with_haproxy_load_balancing: true
[balancers]
192.168.200.140
192.168.200.141
192.168.200.142
#192.168.200.144 new_node=true

# PostgreSQL nodes
[master]
192.168.200.140 hostname=node140 postgresql_exists=false

[replica]
192.168.200.141 hostname=node141 postgresql_exists=false
192.168.200.142 hostname=node142 postgresql_exists=false
#192.168.200.144 hostname=node144 postgresql_exists=false new_node=true

[postgres_cluster:children]
master
replica

# if pgbackrest_install: true and "repo_host" is set
[pgbackrest]  # optional (Dedicated Repository Host)


# Connection settings
[all:vars]
ansible_connection='ssh'
ansible_ssh_port='22'
ansible_user='root'
ansible_ssh_pass='secretpassword'  # "sshpass" package is required for use "ansible_ssh_pass"
#ansible_ssh_private_key_file=
#ansible_python_interpreter='/usr/bin/python3'  # is required for use python3

[pgbackrest:vars]
ansible_user='postgres'
ansible_ssh_pass='secretpassword'
```


edit: /cloud/TEST.1/postgresql_cluster/vars/main.yml
```

...........

keepalived_auth_type: AH
keepalived_auth_pass: U@l!dr8

...........

# Cluster variables
cluster_vip: "192.168.200.146"  # IP address for client access to the databases in the cluster (optional).
vip_interface: "{{ ansible_default_ipv4.interface }}"  # interface name (e.g., "ens32").

...........

synchronous_mode: true  # or 'true' for enable synchronous database replication
synchronous_mode_strict: true  # if 'true' then block all client writes to the master, when a synchronous replica is not available
synchronous_node_count: 1  # number of synchronous standby databases

...........

patroni_cluster_name: "postgres-cluster-node5"  # the cluster name (must be unique for each cluster)
patroni_install_version: "latest"  # or specific version (example 1.5.6)

...........

# if dcs_type: "etcd" and dcs_exists: false
etcd_version: "3.5.9"  # version for deploy etcd cluster
etcd_data_dir: "/var/lib/etcd"
etcd_cluster_name: "etcd-{{ patroni_cluster_name }}"  # ETCD_INITIAL_CLUSTER_TOKEN

...........

# specify additional hosts that will be added to the pg_hba.conf
postgresql_pg_hba:
  - { type: "local", database: "all", user: "{{ patroni_superuser_username }}", address: "", method: "trust" }
  - { type: "local", database: "replication", user: "{{ patroni_superuser_username }}", address: "", method: "trust" }
  - { type: "local", database: "all", user: "all", address: "", method: "peer" }
  - { type: "host", database: "all", user: "{{ pgbouncer_auth_username }}", address: "127.0.0.1/32", method: "trust" } # required for pgbouncer auth_user
  - { type: "host", database: "all", user: "all", address: "127.0.0.1/32", method: "{{ postgresql_password_encryption_algorithm }}" }
  - { type: "host", database: "all", user: "all", address: "::1/128", method: "{{ postgresql_password_encryption_algorithm }}" }
  - { type: "host", database: "all", user: "all", address: "192.168.200.0/24", method: "{{ postgresql_password_encryption_algorithm }}" }  # use pg_ident

...........

```


###  inventory стенда node4

inventory
```
# if dcs_exists: false and dcs_type: "etcd"
[etcd_cluster]  # recommendation: 3, or 5-7 nodes
192.168.200.180
192.168.200.181
192.168.200.182

# if dcs_exists: false and dcs_type: "consul"
[consul_instances]  # recommendation: 3 or 5-7 nodes
192.168.200.180 consul_node_role=server consul_bootstrap_expect=true consul_datacenter=dc1
192.168.200.181 consul_node_role=server consul_bootstrap_expect=true consul_datacenter=dc1
192.168.200.182 consul_node_role=server consul_bootstrap_expect=true consul_datacenter=dc1
#192.168.200.184 consul_node_role=client consul_datacenter=dc1
#192.168.200.185 consul_node_role=client consul_datacenter=dc2

# if with_haproxy_load_balancing: true
[balancers]
192.168.200.180
192.168.200.181
192.168.200.182
#192.168.200.184 new_node=true

# PostgreSQL nodes
[master]
192.168.200.180 hostname=node180 postgresql_exists=false

[replica]
192.168.200.181 hostname=node181 postgresql_exists=false
192.168.200.182 hostname=node182 postgresql_exists=false
#192.168.200.184 hostname=pgnode04 postgresql_exists=false new_node=true

[postgres_cluster:children]
master
replica

# if pgbackrest_install: true and "repo_host" is set
[pgbackrest]  # optional (Dedicated Repository Host)


# Connection settings
[all:vars]
ansible_connection='ssh'
ansible_ssh_port='22'
ansible_user='root'
ansible_ssh_pass='root'  # "sshpass" package is required for use "ansible_ssh_pass"
#ansible_ssh_private_key_file=
#ansible_python_interpreter='/usr/bin/python3'  # is required for use python3

[pgbackrest:vars]
ansible_user='postgres'
ansible_ssh_pass='secretpassword'
```


edit: /cloud/TEST.1/postgresql_cluster.2/vars/main.yml
```
...........

keepalived_auth_type: AH
keepalived_auth_pass: U@l!dr8

...........

# Cluster variables
cluster_vip: "192.168.200.186"  # IP address for client access to the databases in the cluster (optional).
vip_interface: "{{ ansible_default_ipv4.interface }}"  # interface name (e.g., "ens32").

...........

synchronous_mode: true  # or 'true' for enable synchronous database replication
synchronous_mode_strict: true  # if 'true' then block all client writes to the master, when a synchronous replica is not available
synchronous_node_count: 1  # number of synchronous standby databases

...........

patroni_cluster_name: "postgres-cluster-node4"  # the cluster name (must be unique for each cluster)
patroni_install_version: "latest"  # or specific version (example 1.5.6)

...........

# if dcs_type: "etcd" and dcs_exists: false
etcd_version: "3.5.9"  # version for deploy etcd cluster
etcd_data_dir: "/var/lib/etcd"
etcd_cluster_name: "etcd-{{ patroni_cluster_name }}"  # ETCD_INITIAL_CLUSTER_TOKEN
...........

# specify additional hosts that will be added to the pg_hba.conf
postgresql_pg_hba:
  - { type: "local", database: "all", user: "{{ patroni_superuser_username }}", address: "", method: "trust" }
  - { type: "local", database: "replication", user: "{{ patroni_superuser_username }}", address: "", method: "trust" }
  - { type: "local", database: "all", user: "all", address: "", method: "peer" }
  - { type: "host", database: "all", user: "{{ pgbouncer_auth_username }}", address: "127.0.0.1/32", method: "trust" } # required for pgbouncer auth_user
  - { type: "host", database: "all", user: "all", address: "127.0.0.1/32", method: "{{ postgresql_password_encryption_algorithm }}" }
  - { type: "host", database: "all", user: "all", address: "::1/128", method: "{{ postgresql_password_encryption_algorithm }}" }
  - { type: "host", database: "all", user: "all", address: "192.168.200.0/24", method: "{{ postgresql_password_encryption_algorithm }}" }  # use pg_ident

...........

pgbouncer_auth_user: false # or 'false' if you want to manage the list of users for authentication in the database via userlist.txt

...........

patroni_standby_cluster:
  host: "192.168.200.146" #  # an address of remote master
  port: "5432" ###5432  # a port of remote master

...........

```





В случае недоступности основного кластера для смены режима Standby кластера на основной удалите раздел standby_cluster из текущей конфигурации patroni с помощью команды:
```
patronictl edit-config --force -s standby_cluster.host='' -s standby_cluster.port='' -s standby_cluster.create_replica_methods=''
```

Важно не допустить работы двух мастеров, в момент восстановления вышедшего ранее основного кластера он также останется мастером.

После восстановления вышедшего ранее основного кластера для смены режима с основного на Standby кластер добавьте раздел standby_cluster в текущую конфигурацию patroni с помощью команды:
```
patronictl edit-config --force -s standby_cluster.host=192.168.200.146 -s standby_cluster.port=5432 -s standby_cluster.create_replica_methods='- basebackup'
```


Конфигурация HAproxy (блок postgres)
Дополните конфигурацию HAproxy блока postgres указав адреса всех серверов, используемых в кластерах:

```
listen postgres_master
    bind haproxy-server.your_domain:5000
    option tcplog
    option httpchk OPTIONS /master
    http-check expect status 200
    default-server inter 3s fastinter 1s fall 3 rise 4 on-marked-down shutdown-sessions
    server postgres-server1 postgres-server1.your_domain:5432 check port 8008
    server postgres-server2 postgres-server2.your_domain:5432 check port 8008
    server postgres-server3 postgres-server3.your_domain:5432 check port 8008
    server postgres-server4 postgres-server4.your_domain:5432 check port 8008
    server postgres-server5 postgres-server5.your_domain:5432 check port 8008
    server postgres-server6 postgres-server6.your_domain:5432 check port 8008

listen postgres_replicas
    bind haproxy-server.your_domain:5001
    option tcplog
    option httpchk OPTIONS /replica
    balance roundrobin
    http-check expect status 200
    default-server inter 3s fastinter 1s fall 3 rise 2 on-marked-down shutdown-sessions
    server postgres-server1 postgres-server1.your_domain:5432 check port 8008
    server postgres-server2 postgres-server2.your_domain:5432 check port 8008
    server postgres-server3 postgres-server3.your_domain:5432 check port 8008
    server postgres-server4 postgres-server4.your_domain:5432 check port 8008
    server postgres-server5 postgres-server5.your_domain:5432 check port 8008
    server postgres-server6 postgres-server6.your_domain:5432 check port 8008
```


```
root@node180:~# patronictl edit-config --force -s standby_cluster.host='' -s standby_cluster.port='' -s standby_cluster.create_replica_methods=''
2023-09-08 02:32:26,880 - WARNING - postgresql parameter max_prepared_transactions=0 failed validation, defaulting to 0
---
+++
@@ -84,9 +84,6 @@
   use_pg_rewind: true
   use_slots: true
 retry_timeout: 10
-standby_cluster:
-  host: 192.168.200.140
-  port: 5432
 synchronous_mode: false
 synchronous_mode_strict: false
 synchronous_node_count: 1

Configuration changed
root@node180:~# patronictl -c /etc/patroni/patroni.yml list
2023-09-08 02:32:36,264 - WARNING - postgresql parameter max_prepared_transactions=0 failed validation, defaulting to 0
+ Cluster: postgres-cluster-node4 ----+-----------+----+-----------+
| Member  | Host            | Role    | State     | TL | Lag in MB |
+---------+-----------------+---------+-----------+----+-----------+
| node180 | 192.168.200.180 | Leader  | running   |  4 |           |
| node181 | 192.168.200.181 | Replica | streaming |  4 |         0 |
| node182 | 192.168.200.182 | Replica | streaming |  4 |         0 |
+---------+-----------------+---------+-----------+----+-----------+
root@node180:~#
```

on node140
```
CREATE DATABASE test;

\c test


CREATE TABLE t1 (i serial, t text);
CREATE TABLE t2 (i int NOT NULL DEFAULT nextval('t1_i_seq'), t text);
SELECT * FROM t1;
SELECT * FROM t2;

INSERT INTO t2 (t) VALUES('The first value in table t22');
INSERT INTO t1 (t) VALUES('The first value in table t12');
INSERT INTO t2 (t) VALUES('The first value in table t23');
INSERT INTO t1 (t) VALUES('The first value in table t13');

INSERT INTO t2 (t) VALUES('The first value in table t22');
INSERT INTO t1 (t) VALUES('The first value in table t12');
INSERT INTO t2 (t) VALUES('The first value in table t23');
INSERT INTO t1 (t) VALUES('The first value in table t13');


SELECT * FROM t1;
SELECT * FROM t2;
```

on node180
```
\c test


SELECT * FROM t1;
SELECT * FROM t2;
```
