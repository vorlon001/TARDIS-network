
https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/8/html/director_installation_and_usage/sect-rebooting-ceph

10.3. Rebooting Ceph Storage Nodes
To reboot the Ceph Storage nodes, follow this process:
Select the first Ceph Storage node to reboot and log into it.
Disable Ceph Storage cluster rebalancing temporarily:
```shell
$ sudo ceph osd set noout
$ sudo ceph osd set norebalance
```

Reboot the node:
```shell
$ sudo reboot
```

Wait until the node boots.
Log into the node and check the cluster status:
```shell
$ sudo ceph -s
```

Check that the pgmap reports all pgs as normal (active+clean).
Log out of the node, reboot the next node, and check its status. Repeat this process until you have rebooted all Ceph storage nodes.
When complete, enable cluster rebalancing again:
```shell
$ sudo ceph osd unset noout
$ sudo ceph osd unset norebalance
```

Perform a final status check to make sure the cluster reports HEALTH_OK:
```shell
$ sudo ceph status
```
