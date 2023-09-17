#!/usr/bin/bash


wget https://github.com/projectcalico/calico/releases/download/v3.26.1/calicoctl-linux-amd64
chmod +x calicoctl-linux-amd64
cp calicoctl-linux-amd64 /usr/bin/calicoctl

calicoctl node status

calicoctl patch node node170 -p '{"spec":{"bgp":{"ipv4Address":"192.168.200.170/24"}}}'
calicoctl patch node node171 -p '{"spec":{"bgp":{"ipv4Address":"192.168.200.171/24"}}}'
calicoctl patch node node172 -p '{"spec":{"bgp":{"ipv4Address":"192.168.200.172/24"}}}'


calicoctl apply  -f - <<EOF
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: node180-ipv4
spec:
  peerIP: 192.168.200.180
  asNumber: 65000
EOF

calicoctl apply  -f - <<EOF
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: node181-ipv4
spec:
  peerIP: 192.168.200.181
  asNumber: 65000
EOF


calicoctl apply  -f - <<EOF
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: node182-ipv4
spec:
  peerIP: 192.168.200.182
  asNumber: 65000
EOF



# replace apply

cat <<EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: BGPConfigurationList
items:
- apiVersion: projectcalico.org/v3
  kind: BGPConfiguration
  metadata:
    name: default
  spec:
    asNumber: 65000
    logSeverityScreen: Info
    nodeToNodeMeshEnabled: true
    serviceClusterIPs:
    - cidr: 10.96.128.0/17
    serviceExternalIPs:
    - cidr: 10.220.128.0/17
    - cidr: 11.0.0.0/22
    - cidr: 11.0.10.1/32
    - cidr: 11.0.10.10/32
    - cidr: 11.0.10.20/32
    - cidr: 11.0.10.22/32
    - cidr: 192.168.13.0/24
EOF

