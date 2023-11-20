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



ip link add dev vm1 type veth peer name vm2
ip link set dev vm1 up
ip link del dev vm1 type veth peer name vm2

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






Q: How do I configure a port as an access port?

A. Add tag=VLAN to your ovs-vsctl add-port command. For example, the following commands configure br0 with eth0 as a trunk port (the default) and tap0 as an access port for VLAN 9:

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 eth0
$ ovs-vsctl add-port br0 tap0 tag=9
If you want to configure an already added port as an access port, use ovs-vsctl set, e.g.:

$ ovs-vsctl set port tap0 tag=9
Q: How do I configure a port as a SPAN port, that is, enable mirroring of all traffic to that port?

A. The following commands configure br0 with eth0 and tap0 as trunk ports. All traffic coming in or going out on eth0 or tap0 is also mirrored to tap1; any traffic arriving on tap1 is dropped:

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 eth0
$ ovs-vsctl add-port br0 tap0
$ ovs-vsctl add-port br0 tap1 \
    -- --id=@p get port tap1 \
    -- --id=@m create mirror name=m0 select-all=true output-port=@p \
    -- set bridge br0 mirrors=@m
To later disable mirroring, run:

$ ovs-vsctl clear bridge br0 mirrors
Q: Does Open vSwitch support configuring a port in promiscuous mode?

A: Yes. How you configure it depends on what you mean by “promiscuous mode”:

Conventionally, “promiscuous mode” is a feature of a network interface card. Ordinarily, a NIC passes to the CPU only the packets actually destined to its host machine. It discards the rest to avoid wasting memory and CPU cycles. When promiscuous mode is enabled, however, it passes every packet to the CPU. On an old-style shared-media or hub-based network, this allows the host to spy on all packets on the network. But in the switched networks that are almost everywhere these days, promiscuous mode doesn’t have much effect, because few packets not destined to a host are delivered to the host’s NIC.

This form of promiscuous mode is configured in the guest OS of the VMs on your bridge, e.g. with “ip link set <device> promisc”.

The VMware vSwitch uses a different definition of “promiscuous mode”. When you configure promiscuous mode on a VMware vNIC, the vSwitch sends a copy of every packet received by the vSwitch to that vNIC. That has a much bigger effect than just enabling promiscuous mode in a guest OS. Rather than getting a few stray packets for which the switch does not yet know the correct destination, the vNIC gets every packet. The effect is similar to replacing the vSwitch by a virtual hub.

This “promiscuous mode” is what switches normally call “port mirroring” or “SPAN”. For information on how to configure SPAN, see “How do I configure a port as a SPAN port, that is, enable mirroring of all traffic to that port?”

Q: How do I configure a DPDK port as an access port?

A: Firstly, you must have a DPDK-enabled version of Open vSwitch.

If your version is DPDK-enabled it may support the dpdk_version and dpdk_initialized keys in the configuration database. Earlier versions of Open vSwitch only supported the other-config:dpdk-init key in the configuration in the database. All versions will display lines with “EAL:…” during startup when other_config:dpdk-init is set to ‘true’.

Secondly, when adding a DPDK port, unlike a system port, the type for the interface and valid dpdk-devargs must be specified. For example:

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 myportname -- set Interface myportname \
    type=dpdk options:dpdk-devargs=0000:06:00.0
Refer to Open vSwitch with DPDK for more information on enabling and using DPDK with Open vSwitch.

Q: How do I configure a VLAN as an RSPAN VLAN, that is, enable mirroring of all traffic to that VLAN?

A: The following commands configure br0 with eth0 as a trunk port and tap0 as an access port for VLAN 10. All traffic coming in or going out on tap0, as well as traffic coming in or going out on eth0 in VLAN 10, is also mirrored to VLAN 15 on eth0. The original tag for VLAN 10, in cases where one is present, is dropped as part of mirroring:

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 eth0
$ ovs-vsctl add-port br0 tap0 tag=10
$ ovs-vsctl \
    -- --id=@m create mirror name=m0 select-all=true select-vlan=10 \
       output-vlan=15 \
    -- set bridge br0 mirrors=@m
To later disable mirroring, run:

$ ovs-vsctl clear bridge br0 mirrors
Mirroring to a VLAN can disrupt a network that contains unmanaged switches. See ovs-vswitchd.conf.db(5) for details. Mirroring to a GRE tunnel has fewer caveats than mirroring to a VLAN and should generally be preferred.

Q: Can I mirror more than one input VLAN to an RSPAN VLAN?

A: Yes, but mirroring to a VLAN strips the original VLAN tag in favor of the specified output-vlan. This loss of information may make the mirrored traffic too hard to interpret.

To mirror multiple VLANs, use the commands above, but specify a comma-separated list of VLANs as the value for select-vlan. To mirror every VLAN, use the commands above, but omit select-vlan and its value entirely.

When a packet arrives on a VLAN that is used as a mirror output VLAN, the mirror is disregarded. Instead, in standalone mode, OVS floods the packet across all the ports for which the mirror output VLAN is configured. (If an OpenFlow controller is in use, then it can override this behavior through the flow table.) If OVS is used as an intermediate switch, rather than an edge switch, this ensures that the RSPAN traffic is distributed through the network.

Mirroring to a VLAN can disrupt a network that contains unmanaged switches. See ovs-vswitchd.conf.db(5) for details. Mirroring to a GRE tunnel has fewer caveats than mirroring to a VLAN and should generally be preferred.

Q: How do I configure mirroring of all traffic to a GRE tunnel?

A: The following commands configure br0 with eth0 and tap0 as trunk ports. All traffic coming in or going out on eth0 or tap0 is also mirrored to gre0, a GRE tunnel to the remote host 192.168.1.10; any traffic arriving on gre0 is dropped:

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 eth0
$ ovs-vsctl add-port br0 tap0
$ ovs-vsctl add-port br0 gre0 \
     -- set interface gre0 type=gre options:remote_ip=192.168.1.10 \
     -- --id=@p get port gre0 \
     -- --id=@m create mirror name=m0 select-all=true output-port=@p \
     -- set bridge br0 mirrors=@m
To later disable mirroring and destroy the GRE tunnel:

$ ovs-vsctl clear bridge br0 mirrors
$ ovs-vsctl del-port br0 gre0
Q: Does Open vSwitch support ERSPAN?

A: Yes. ERSPAN version I and version II over IPv4 GRE and IPv6 GRE tunnel are supported. See ovs-fields(7) for matching and setting ERSPAN fields.

$ ovs-vsctl add-br br0
$ #For ERSPAN type 2 (version I)
$ ovs-vsctl add-port br0 at_erspan0 -- \
        set int at_erspan0 type=erspan options:key=1 \
        options:remote_ip=172.31.1.1 \
        options:erspan_ver=1 options:erspan_idx=1
$ #For ERSPAN type 3 (version II)
$ ovs-vsctl add-port br0 at_erspan0 -- \
        set int at_erspan0 type=erspan options:key=1 \
        options:remote_ip=172.31.1.1 \
        options:erspan_ver=2 options:erspan_dir=1 \
        options:erspan_hwid=4
Q: Does Open vSwitch support IPv6 GRE?

A: Yes. L2 tunnel interface GRE over IPv6 is supported. L3 GRE tunnel over IPv6 is not supported.

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 at_gre0 -- \
        set int at_gre0 type=ip6gre \
        options:remote_ip=fc00:100::1 \
        options:packet_type=legacy_l2
Q: Does Open vSwitch support GTP-U?

A: Yes. Starting with version 2.13, the Open vSwitch userspace datapath supports GTP-U (GPRS Tunnelling Protocol User Plane (GTPv1-U)). TEID is set by using tunnel key field.

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 gtpu0 -- \
        set int gtpu0 type=gtpu options:key=<teid> \
        options:remote_ip=172.31.1.1
Q: Does Open vSwitch support SRv6?

A: Yes. Starting with version 3.2, the Open vSwitch userspace datapath supports SRv6 (Segment Routing over IPv6). The following example shows tunneling to fc00:300::1 via fc00:100::1 and fc00:200::1. In the current implementation, if “IPv6 in IPv6” or “IPv4 in IPv6” packets are routed to this interface, and these packets are not SRv6 packets, they may be dropped, so be careful in workloads with a mix of these tunnels. Also note the following restrictions:

Segment list length is limited to 6.

SRv6 packets with other than segments_left = 0 are simply dropped.

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 srv6_0 -- \
        set int srv6_0 type=srv6  \
        options:remote_ip=fc00:100::1 \
        options:srv6_segs="fc00:100::1,fc00:200::1,fc00:300::1"
Q: How do I connect two bridges?

A: First, why do you want to do this? Two connected bridges are not much different from a single bridge, so you might as well just have a single bridge with all your ports on it.

If you still want to connect two bridges, you can use a pair of patch ports. The following example creates bridges br0 and br1, adds eth0 and tap0 to br0, adds tap1 to br1, and then connects br0 and br1 with a pair of patch ports.

$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 eth0
$ ovs-vsctl add-port br0 tap0
$ ovs-vsctl add-br br1
$ ovs-vsctl add-port br1 tap1
$ ovs-vsctl \
    -- add-port br0 patch0 \
    -- set interface patch0 type=patch options:peer=patch1 \
    -- add-port br1 patch1 \
    -- set interface patch1 type=patch options:peer=patch0
Bridges connected with patch ports are much like a single bridge. For instance, if the example above also added eth1 to br1, and both eth0 and eth1 happened to be connected to the same next-hop switch, then you could loop your network just as you would if you added eth0 and eth1 to the same bridge (see the “Configuration Problems” section below for more information).

If you are using Open vSwitch 1.9 or an earlier version, then you need to be using the kernel module bundled with Open vSwitch rather than the one that is integrated into Linux 3.3 and later, because Open vSwitch 1.9 and earlier versions need kernel support for patch ports. This also means that in Open vSwitch 1.9 and earlier, patch ports will not work with the userspace datapath, only with the kernel module.

Q: How do I configure a bridge without an OpenFlow local port? (Local port in the sense of OFPP_LOCAL)

A: Open vSwitch does not support such a configuration. Bridges always have their local ports.

Q: Why does OVS pick its default datapath ID the way it does?

A: The default OpenFlow datapath ID for a bridge is the minimum non-local MAC address among all of the ports in a bridge. This means that a bridge with a given set of physical ports will always have the same datapath ID. This is useful for virtualization systems, which typically put a single physical port (or a single bond of multiple ports) on a given bridge alongside the virtual ports for running VMs. In such a setup, the IP address for the NIC associated with a physical port gets migrated from the physical NIC to the bridge port. The bridge port should have the same MAC address as the physical NIC, so that the host doesn’t suddenly start using a different MAC, and taking the minimum MAC address does this automatically and, if there is bond, consistently. Virtual ports for running VMs do not affect the situation because these normally have the “local” bit set, which OVS ignores.

If you want a stable MAC and datapath ID, you could set your own MAC by hwaddr in other_config of bridge.

ovs-vsctl set bridge br-int other_config:hwaddr=3a:4d:a7:05:2a:45













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
            set-name: enp1s0
            nameservers:
                addresses:
                - 192.168.1.10
                search:
                - cloud.local
        enp2s0:
            addresses:
            - 192.168.221.90/24
            dhcp4: false
            dhcp6: false
            gateway4: 192.168.222.1
            match:
                macaddress: fa:16:3e:34:db:84
            set-name: enp2s0
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
	--net "tap=,mac=fa:16:3e:34:db:82,ip=,mask=" "tap=,mac=fa:16:3e:34:db:84,ip=,mask=" \
	--serial tty \
        --api-socket=/tmp/ch-socket \
	--console off 



$ tunctl -t tap0
$ ip addr add 192.168.0.123/24 dev tap0
$ ip link set tap0 up
$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 tap0

```



```

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
