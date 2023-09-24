```shell


array=( 180 181 182 170 171 172 )
for i in "${array[@]}"
do
  scp -r * root@192.168.200.${i}:.
done

```



```

root@node1:/KVM/init.kube.24.hardway/UTILS# ./nerdctl namespace list
NAME            CONTAINERS    IMAGES    VOLUMES    LABELS
example         0             1         0
example-ns-1    1             1         0
k8s.io          0             14        0
moby            8             0         0


root@node1:/KVM/init.kube.24.hardway/UTILS# ./nerdctl -n moby ps -a
CONTAINER ID    IMAGE    COMMAND                   CREATED           STATUS    PORTS    NAMES
0c8862475f9d             "/entrypoint.sh /etc…"    12 days ago       Up
1b307dea66fd             "/docker-entrypoint.…"    35 minutes ago    Up
40022b910e2f             "/usr/sbin/named -g …"    56 minutes ago    Up
4ca590585179             "/container/tool/run…"    12 days ago       Up
8b67fd5270d7             "/usr/bin/dumb-init …"    12 days ago       Up
995cab92941c             "docker-entrypoint.s…"    46 minutes ago    Up
e1e49a963382             "/docker-entrypoint.…"    12 days ago       Up
e2eb315436f2             "/opt/sonatype/nexus…"    34 minutes ago    Up

```
