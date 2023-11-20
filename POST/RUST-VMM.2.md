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
            - 192.168.220.90/24
            dhcp4: false
            dhcp6: false
            gateway4: 192.168.220.1
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

















# ATTACH 1 START @@@@@@@@@@@

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
    version: 2
    ethernets:
        enp1s0:
            addresses:
            - 192.168.220.90/24
            dhcp4: false
            dhcp6: false
            gateway4: 192.168.220.1
            match:
                macaddress: fa:16:3e:34:db:82
                name: enp*s0
            set-name: enp1s0
            nameservers:
                addresses:
                - 192.168.1.10
                search:
                - cloud.local
EOF

cloud-localds -d raw -v --network-config=./network.cfg ubuntu-cloudinit.img ./user-data ./meta-data


ip tuntap add mode tap tap0
ifconfig tap0 192.168.220.1/24

qemu-img convert -p -f qcow2 -O raw jammy-server-cloudimg-amd64.img jammy-server-cloudimg-amd64.raw
./cloud-hypervisor \
	--kernel ./hypervisor-fw \
	--disk path=/cloud/RUST-VMM/jammy-server-cloudimg-amd64.raw path=/cloud/RUST-VMM/ubuntu-cloudinit.img \
	--cpus boot=4,max=8 \
	--memory size=2048M,hotplug_size=8192M,hotplug_method=virtio-mem \
	--net "tap=tap0,mac=fa:16:3e:34:db:82,ip=,mask=" \
	--serial tty \
  --api-socket=/tmp/ch-socket \
	--console off 

ip tuntap del mode tap tap0

# ATTACH 1 END @@@@@@@@@@@


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



first create all required interfaces,

ip link add dev vm1 type veth peer name vm2
ip link set dev vm1 up
ip tuntap add tapm mode tap
ip link set dev tapm up
ip link add brm type bridge
Notice we did not bring up brm and vm2 because we have to assign them IP addresses, but we did bring up tapm and vm1, which is necessary to include them into the bridge brm. Now enslave the interfaces tapm and vm1 to the bridge brm,

ip link set tapm master brm
ip link set vm1 master brm
now give addresses to the bridge and to the remaining veth interface vm2,

ip addr add 10.0.0.1/24 dev brm
ip addr add 10.0.0.2/24 dev vm2


Here is a 5 node bridge setup that I use that works. You should be able to use ifconfig to assign addresses onto the NodeX interfaces

ip link add dev Node1s type veth peer name Node1
ip link add dev Node2s type veth peer name Node2
ip link add dev Node3s type veth peer name Node3
ip link add dev Node4s type veth peer name Node4
ip link add dev Node5s type veth peer name Node5

ip link set Node1 up
ip link set Node2 up
ip link set Node3 up
ip link set Node4 up
ip link set Node5 up

ip link set Node1s up
ip link set Node2s up
ip link set Node3s up
ip link set Node4s up
ip link set Node5s up

brctl addbr Br
ifconfig Br up

brctl addif Br Node1s
brctl addif Br Node2s
brctl addif Br Node3s
brctl addif Br Node4s
brctl addif Br Node5s
and to clean up

brctl delif Br Node1s
brctl delif Br Node2s
brctl delif Br Node3s
brctl delif Br Node4s
brctl delif Br Node5s
brctl delif Br Node1
brctl delif Br Node2
brctl delif Br Node3
brctl delif Br Node4
brctl delif Br Node5

ifconfig Br down
brctl delbr Br

ip link del dev Node1
ip link del dev Node2
ip link del dev Node3
ip link del dev Node4
ip link del dev Node5

```
