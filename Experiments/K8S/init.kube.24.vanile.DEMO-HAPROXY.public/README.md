```shell


array=( 130 131 132 133 180 181 182 170 171 172 )
for i in "${array[@]}"
do
  scp -r * root@192.168.200.${i}:.
done

```
