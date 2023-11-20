```

https://arthurchiao.art/blog/ovs-deep-dive-6-internal-port/

https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/hotplug.md
https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/cpu.md
https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/live_migration.md
https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/vfio.md
https://github.com/cloud-hypervisor/cloud-hypervisor
https://www.cloudhypervisor.org/docs/prologue/commands/
https://docs.openvswitch.org/en/latest/faq/configuration/


cd /cloud/RUST-VMM
apt install qemu-utils -y 


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


ip tuntap add mode tap tap0
ovs-vsctl add-port sw1 tap0


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


./ch-remote --api-socket=/tmp/ch-socket resize --cpus 5
## The extra vCPU threads will be created and advertised to the running kernel. The kernel does not bring up the CPUs immediately and instead the user must "online" them from inside the VM:

## root@ch-guest ~ # lscpu | grep list:
## On-line CPU(s) list:             0-3
## Off-line CPU(s) list:            4-7
## root@ch-guest ~ # echo 1 | tee /sys/devices/system/cpu/cpu[4,5,6,7]/online
## 1
## root@ch-guest ~ # lscpu | grep list:
## On-line CPU(s) list:             0-7

./ch-remote --api-socket=/tmp/ch-socket resize --memory 4G


```
