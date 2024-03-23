watch -n 2 ceph -s
$ ceph osd unset norebalance
$ ceph osd unset nobackfill
ceph osd set nobackfill
ceph osd set norebalance
ceph osd crush rm-device-class osd.12 && ceph osd crush set-device-class ssd osd.12
ceph osd crush rm-device-class osd.13 && ceph osd crush set-device-class ssd osd.13
ceph osd crush rm-device-class osd.14 && ceph osd crush set-device-class ssd osd.14
ceph osd crush rm-device-class osd.15 && ceph osd crush set-device-class ssd osd.15
ceph osd crush rm-device-class osd.16 && ceph osd crush set-device-class ssd osd.16
ceph osd crush rm-device-class osd.17 && ceph osd crush set-device-class ssd osd.17
ceph osd crush rm-device-class osd.18 && ceph osd crush set-device-class ssd osd.18
ceph osd crush rm-device-class osd.19 && ceph osd crush set-device-class ssd osd.19
ceph osd crush rm-device-class osd.20 && ceph osd crush set-device-class ssd osd.20
ceph osd crush rm-device-class osd.21 && ceph osd crush set-device-class ssd osd.21
ceph osd crush rm-device-class osd.22 && ceph osd crush set-device-class ssd osd.22
ceph osd crush rm-device-class osd.23 && ceph osd crush set-device-class ssd osd.23
ceph osd crush add-bucket zone-26 root
ceph osd crush move node130 root=zone-26
ceph osd crush move node131 root=zone-26
ceph osd crush move node132 root=zone-26
ceph osd crush move node133 root=zone-26
# node50
ceph osd crush rule create-replicated Zone_26_SSD zone-26 host ssd
ceph osd crush rule dump Zone_26_SSD
ceph orch device ls
ceph osd tree
ceph pg dump osds
ceph osd unset norebalance
ceph osd unset nobackfill
ceph osd tree
ceph pg dump osds
radosgw-admin realm create --default --rgw-realm=gold
radosgw-admin zonegroup delete --rgw-zonegroup=default
radosgw-admin realm default --default --rgw-realm=gold
radosgw-admin zone delete --rgw-zone=default
ceph tell mon.* injectargs --mon_allow_pool_delete true
ceph osd pool rm default.rgw.control default.rgw.control --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.data.root default.rgw.data.root --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.gc default.rgw.gc --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.log default.rgw.log --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.users.uid default.rgw.users.uid --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.meta default.rgw.meta   --yes-i-really-really-mean-it
radosgw-admin zonegroup create --rgw-zonegroup=us --master --default --endpoints=http://192.168.200.140:8400 --endpoints=http://192.168.200.141:8400   --endpoints=http://192.168.200.142:8400
radosgw-admin zone create --rgw-zone=us-east --master --rgw-zonegroup=us --endpoints=http://192.168.200.140:8400 --endpoints=http://192.168.200.141:8400   --endpoints=http://192.168.200.142:8400 --access-key=1234567 --secret=098765 --default
radosgw-admin user create --uid=repuser --display-name="Replication_user" --access-key=1234567 --secret=098765 --system
radosgw-admin caps add --uid=repuser --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"
radosgw-admin period update --rgw-realm=gold --commit
radosgw-admin zonegroup get --rgw-zonegroup=us
rados df
ceph osd tree
ceph pg dump osds
ceph osd set nobackfill
ceph osd set norebalance
ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_26_SSD
ceph osd tree
ceph pg dump osds
ceph -s
ceph pg dump osds
ceph -s
ceph osd unset norebalance
ceph osd unset nobackfill
ceph -s
ceph osd set nobackfill
ceph osd set norebalance
radosgw-admin user create --uid=zone.user --display-name="ZoneUser" --access-key=SYSTEM_ACCESS_KEY --secret=SYSTEM_SECRET_KEY --system
radosgw-admin caps add --uid=zone.user --caps="users=*;buckets=*;metadata=*;usage=*;zone=*"
ceph orch apply rgw gold us-east --placement="3 node140 node141 node142"  --port=8400
wget https://dl.min.io/client/mc/release/linux-amd64/mc
mv mc /usr/bin/mc
chmod +x /usr/bin/mc
mc alias rm gcs; mc alias rm local; mc alias rm local; mc alias rm play; mc alias rm s3
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-armhf-root.tar.xz
mc alias set minio http://192.168.200.140:8400 SYSTEM_ACCESS_KEY SYSTEM_SECRET_KEY
mc ls minio
mc mb minio/test
mc tree minio
mc ls minio/test
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test1
wget https://dl.min.io/client/mc/release/linux-amd64/mc
mv mc /usr/bin/mc
chmod +x /usr/bin/mc
mc alias rm gcs; mc alias rm local; mc alias rm local; mc alias rm play; mc alias rm s3
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-armhf-root.tar.xz
mc alias set minio http://192.168.200.140:8400 SYSTEM_ACCESS_KEY SYSTEM_SECRET_KEY
mc ls minio
mc mb minio/test
mc tree minio
mc ls minio/test
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test1
ceph osd pool set us-east.rgw.buckets.data crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.non-ec crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.buckets.index crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.log  crush_rule Zone_26_SSD
ceph osd pool set us-east.rgw.meta  crush_rule Zone_26_SSD
ceph osd tree
ceph pg dump osds
ceph osd unset norebalance
ceph osd unset nobackfill
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test2
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test3
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test4
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test5
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test6
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test7
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test8
ceph osd tree
ceph pg dump osds
ceph -s
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test10
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test11
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test12
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test13
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test14
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test15
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test16
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test17
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test18
ceph osd tree
ceph pg dump osds
ceph pg dump 
ceph pg dump osds
ceph osd tree
ceph pg dump osds
ceph -s
history 
history  >>logs
more logs 
history 
history  >logs
more logs 
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test20
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test21
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test22
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test23
mc cp jammy-server-cloudimg-armhf-root.tar.xz minio/test/test24
ceph pg dump osds
ceph osd tree
ceph pg dump osds
ceph osd tree
ceph pg dump osds
ceph -s
ceph orch device ls
ceph orch ps
ceph -s
ceph orch ps
ceph -s
ceph orch ps
ceph -s
rados df
history | more
history -n
history -h
history -anr
history -a
