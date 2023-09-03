```shell

cat <<EOF>1.xml
<domainsnapshot>
  <name>snapshot</name>
</domainsnapshot>
EOF
virsh snapshot-create --domain node190 --xmlfile 1.xml --disk-only --atomic --quiesce --no-metadata
rm 1.xml

virsh snapshot-create-as --domain node190 snapshot --disk-only --atomic --quiesce --no-metadata --print-xml
<domainsnapshot>
  <name>snapshot</name>
</domainsnapshot>

<domainsnapshot>
  <name>snapshot</name>
</domainsnapshot>

virsh snapshot-create-as --domain node190 snapshot --disk-only --atomic --quiesce --no-metadata --print-xml
virsh blockcommit node190 sda --active --verbose --pivot

```


```
#!/bin/bash

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



data=`date +%Y-%m-%d`
backup_dir=/backup/VM

vm=`virsh list | grep . | awk '{print $2}'| sed 1,2d | tr -s '\n' ' '`

for activevm in $vm
do
    mkdir -p $backup_dir/$activevm
    echo "Бэкапим конфигурацию XML для виртуальной машины $activevm > $backup_dir/$activevm/$activevm-$data.xml"
    virsh dumpxml $activevm > $backup_dir/$activevm/$activevm-$data.xml || throw ${LINENO}
    echo "Список дисков виртуальных машин $activevm"
    disk_list=`virsh domblklist $activevm | grep sd | awk '{print $1}'`
    echo "Адрес дисков виртуальных машин $activevm"
    disk_path=`virsh domblklist $activevm | grep sd | awk '{print $2}'`
    echo "Адреса дисков виртуальных машин $activevm $disk_path"
    virsh snapshot-create-as --domain $activevm snapshot --disk-only --atomic --quiesce --no-metadata || throw ${LINENO}
    echo "sleep 3sec"
    sleep 3

    for path in $disk_path
    do
        echo "Убираем имя файла из пути $activevm $path"
        filename=`basename $path`
        echo "Создаем бэкап диска $activevm $path"
        # gzip -c $path > $backup_dir/$activevm/$filename-$data.gz
        cp $path $backup_dir/$activevm/$filename-$data.qcow2 || throw ${LINENO}
        echo "sleep 3sec"
        sleep 3
    done

    for disk in $disk_list
    do
        echo "Определяем путь до снепшота $activevm"
        snapshot=`virsh domblklist $activevm | grep $disk | awk '{print $2}'`
        echo "Объединяем vm $activevm  снапшот $snapshot с диском $disk"
        virsh blockcommit $activevm $disk --active --verbose --pivot || throw ${LINENO}
        echo "sleep 3sec"
        sleep 3
        echo "Удаляем снепшот $snapshot"
        rm -rf $snapshot || throw ${LINENO}
    done
done
/usr/bin/find /backup/VM -type f -mtime +7 -exec rm -rf {} \;

```
