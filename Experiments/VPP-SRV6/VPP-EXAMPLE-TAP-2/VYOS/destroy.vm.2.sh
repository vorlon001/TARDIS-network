
#!/bin/bash


virsh destroy node188
virsh undefine --domain node188
rm vyos-node188.qcow2
#rm ${NODENAME}.img
