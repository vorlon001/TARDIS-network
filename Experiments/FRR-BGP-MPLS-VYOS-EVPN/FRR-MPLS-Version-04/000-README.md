```

[node170: CE]--(vlan 31)--[node171:PE]--(vlan 32)--[node172:PE:BGP:RR]--(vlan 33)--[node170: PE]--(vlan 34)--[node180: CE)


```

```
### DEBIAN 12
```shell

array=( 170 171 172 180 181 )
for i in "${array[@]}"
do
  scp * root@192.168.200.${i}:.
done


```


```shell
# need after reload
sysctl -p
sysctl -a | grep mpls

```


```shell
array=( 170 171 172 180 181 )
for i in "${array[@]}"w
do
  scp root@192.168.200.${i}:/root/*yaml .
  scp root@192.168.200.${i}:/root/*config .
done


```
