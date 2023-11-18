```

cd /cloud/RUST-VMM
apt install qemu-utils -y 

touch meta-data
cat <<EOF>user-data
#cloud-config
hostname: rustvmm1
manage_etc_hosts: true
preserve_hostname: False
fqdn: rustvmm1

chpasswd:
  list: |
    vorlon:123
    root:root
  expire: false

ssh_pwauth: true
disable_root: false
EOF


cat <<EOF>./network.cfg
network:
    ethernets:
        enp1s0:
            dhcp4: false
            match:
                macaddress: fa:16:3e:34:db:82
                name: enp*s0
            set-name: enp1s0
    version: 2
    vlans:
        enp1s0.200:
            addresses:
            - 192.168.200.90/24
            dhcp4: false
            dhcp6: false
            gateway4: 192.168.200.1
            id: 200
            link: enp1s0
            nameservers:
                addresses:
                - 192.168.1.10
                search:
                - cloud.local
EOF

cloud-localds -d raw -v --network-config=./network.cfg ubuntu-cloudinit.img ./user-data ./meta-data


wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
qemu-img convert -p -f qcow2 -O raw focal-server-cloudimg-amd64.img focal-server-cloudimg-amd64.raw

wget https://cloud-images.ubuntu.com/jummy/current/jummyserver-cloudimg-amd64.img
qemu-img convert -p -f qcow2 -O raw jammy-server-cloudimg-amd64.img jammy-server-cloudimg-amd64.raw

wget https://github.com/cloud-hypervisor/cloud-hypervisor/releases/download/v36.0/ch-remote
wget https://github.com/cloud-hypervisor/cloud-hypervisor/releases/download/v36.0/cloud-hypervisor
wget https://github.com/cloud-hypervisor/rust-hypervisor-firmware/releases/download/0.4.2/hypervisor-fw

chmod +x ch-remote
chmod +x cloud-hypervisor


setcap cap_net_admin+ep ./cloud-hypervisor
./cloud-hypervisor \
	--kernel ./hypervisor-fw \
	--disk path=/cloud/RUST-VMM/focal-server-cloudimg-amd64.raw path=/cloud/RUST-VMM/ubuntu-cloudinit.img \
	--cpus boot=4,max=8 \
	--memory size=2048M,hotplug_size=8192M,hotplug_method=virtio-mem \
	--net "tap=,mac=fa:16:3e:34:db:82,ip=,mask=" \
	--serial tty \
  --api-socket=/tmp/ch-socket \
	--console off 

https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/hotplug.md
https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/cpu.md
https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/live_migration.md
https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/vfio.md
https://github.com/cloud-hypervisor/cloud-hypervisor
https://www.cloudhypervisor.org/docs/prologue/commands/

./ch-remote --api-socket=/tmp/ch-socket resize --cpus 6
./ch-remote --api-socket=/tmp/ch-socket resize --memory 3G
./ch-remote --api-socket=/tmp/ch-socket add-device path=/sys/bus/pci/devices/0000:01:00.0/

./ch-remote --api-socket=/tmp/ch-socket add-net tap=chtap0

./ch-remote --api-socket=/tmp/ch-socket add-disk path=/foo/bar/cloud.img
./ch-remote --api-socket=/tmp/ch-socket remove-device _disk0

./ch-remote --api-socket=/tmp/ch-socket add-fs tag=myfs,socket=/foo/bar/virtiofs.sock


```
