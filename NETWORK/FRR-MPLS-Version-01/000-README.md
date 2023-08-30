
```shell

array=( 180 181 182 183 184 )
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
array=( 180 181 182 183 184 )
for i in "${array[@]}"
do
  scp root@192.168.200.${i}:/root/*yaml .
  scp root@192.168.200.${i}:/root/*config .
done


```
