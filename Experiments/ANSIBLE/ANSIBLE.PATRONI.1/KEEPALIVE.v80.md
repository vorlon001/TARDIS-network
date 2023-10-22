## VIP1 VIP 2

systemctl stop multipathd && systemctl disable multipathd
apt install keepalived -y



# VIP 1 192.168.200.0/24

cat <<EOF>/etc/keepalived/keepalived.conf

vrrp_instance vi1 {
        virtual_router_id 51
        state BACKUP

        priority 30

        interface ens3
        virtual_ipaddress {
                192.168.200.233 dev lo label lo:1 # Virtual IP
        }

        unicast_src_ip 192.168.200.5
        unicast_peer {
           192.168.200.69
        }
	
        authentication {
            auth_type AH
            auth_pass k@l!ve3
        }
        track_script {
                ckhaproxy
        }
}
EOF

systemctl restart keepalived
systemctl status keepalived
ip address show



# VIP 2 192.168.201.0/24

cat <<EOF>/etc/keepalived/keepalived.conf

vrrp_instance vi1 {
        virtual_router_id 51
        state BACKUP

        priority 40

        interface ens3
        virtual_ipaddress {
                192.168.201.233 dev lo label lo:1 # Virtual IP
        }

        unicast_src_ip 192.168.201.69
        unicast_peer {
           192.168.201.5
        }
	
        authentication {
            auth_type AH
            auth_pass k@l!ve3
        }
        track_script {
                ckhaproxy
        }
}
EOF

systemctl restart keepalived
systemctl status keepalived
ip address show













# ----------------------


The first example I'll cover is using a basic health check test to determine if a route should be announced or withdrawn from BGP. Here is our python script healthcheck.py with comments inline:


cat <<EOF>/opt/healthcheck.py
#!/usr/bin/env python3
import subprocess
from sys import stdout
from time import sleep
import re
import traceback



def runMAASClient(cli: list) -> str:
    p = subprocess.Popen( cli, stdout=subprocess.PIPE)
    out = p.stdout.read()
    return out


def is_alive(address):
    try:
        response = runMAASClient(["ping","-c","2",address])
        ping = re.search(' 0% packet loss',response.decode('utf-8'))
        if response != None:
           return True
        else:
           return False
    except Exception as e:
        print(traceback.format_exc())
        return False


while True:
    if is_alive('192.168.200.233'):
        stdout.write('announce route 192.168.200.233/32 next-hop self' + '\n')
        stdout.flush()
    else:
        stdout.write('withdraw route 192.168.200.233/32 next-hop self' + '\n')
        stdout.flush()
    sleep(10)
EOF


# ------------
# VIP 1

Let's update our ExaBGP's conf.ini to run this python script:


cat <<EOF>/opt/conf.ini
process healthcheck {
    run /usr/bin/python3.8 /path/to/healthcheck.py;
    encoder json;
}



neighbor 192.168.200.2 {
    router-id 192.168.200.5;
    local-address 192.168.200.5;
    local-as 65666;
    peer-as 65020;

    api {
        processes [healthcheck];
    }
}

neighbor 192.168.200.3 {
    router-id 192.168.200.5;
    local-address 192.168.200.5;
    local-as 65666;
    peer-as 65020;

    api {
        processes [healthcheck];
    }
}
EOF

# ------------
# VIP 2

Let's update our ExaBGP's conf.ini to run this python script:


cat <<EOF>/opt/conf.ini
process healthcheck {
    run /usr/bin/python3.8 /opt/healthcheck.py;
    encoder json;
}

neighbor 192.168.201.66 {
    router-id 192.168.201.69;
    local-address 192.168.201.69;
    local-as 65666;
    peer-as 65050;

    api {
        processes [healthcheck];
    }
}

neighbor 192.168.201.67 {
    router-id 192.168.201.69;
    local-address 192.168.201.69;
    local-as 65666;
    peer-as 65050;

    api {
        processes [healthcheck];
    }
}
EOF


# 192.168.200.225
set protocols bgp neighbor 192.168.200.5 address-family ipv4-unicast nexthop-self
set protocols bgp neighbor 192.168.200.5 address-family ipv4-unicast soft-reconfiguration inbound
set protocols bgp neighbor 192.168.200.5 interface source-interface 'eth1'
set protocols bgp neighbor 192.168.200.5 remote-as '65666'
set protocols bgp neighbor 192.168.200.5 update-source '192.168.200.2'
# 192.168.200.226
set protocols bgp neighbor 192.168.200.5 address-family ipv4-unicast nexthop-self
set protocols bgp neighbor 192.168.200.5 address-family ipv4-unicast soft-reconfiguration inbound
set protocols bgp neighbor 192.168.200.5 interface source-interface 'eth1'
set protocols bgp neighbor 192.168.200.5 remote-as '65666'
set protocols bgp neighbor 192.168.200.5 update-source '192.168.200.3'

vyos
CeReev6ue5tei6zu

# AS 65030
192.168.201.231
192.168.201.232

# 192.168.201.227
set protocols bgp neighbor 192.168.201.69 address-family ipv4-unicast nexthop-self
set protocols bgp neighbor 192.168.201.69 address-family ipv4-unicast soft-reconfiguration inbound
set protocols bgp neighbor 192.168.201.69 interface source-interface 'eth1'
set protocols bgp neighbor 192.168.201.69 remote-as '65666'
set protocols bgp neighbor 192.168.201.69 update-source '192.168.201.66'

# 192.168.201.228
set protocols bgp neighbor 192.168.201.69 address-family ipv4-unicast nexthop-self
set protocols bgp neighbor 192.168.201.69 address-family ipv4-unicast soft-reconfiguration inbound
set protocols bgp neighbor 192.168.201.69 interface source-interface 'eth1'
set protocols bgp neighbor 192.168.201.69 remote-as '65666'
set protocols bgp neighbor 192.168.201.69 update-source '192.168.201.67'


pip3 install exabgp
sysctl -w net.ipv4.ip_forward=1
exabgp ./conf.ini


