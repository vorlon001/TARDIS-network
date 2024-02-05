#!/bin/bash

kubectl create -f tigera-operator.yaml

echo "sleep 20sec"
sleep 20

cat <<EOF>/root/CNI/CALICO/3.26.1/custom-resources.vxlan.yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
  namespace: default
spec:
  variant: Calico
  registry: harbor.iblog.pro/docker.io/
  calicoNetwork:
    linuxDataplane: Iptables
#    // +kubebuilder:validation:Enum=Iptables;BPF;VPP
    bgp: Enabled
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 10.96.0.0/17
#     // +kubebuilder:validation:Enum=IPIPCrossSubnet;IPIP;VXLAN;VXLANCrossSubnet;None
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
    nodeAddressAutodetectionV4:
      interface: "(enp1s0.800)"
---

# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF


kubectl apply  -f custom-resources.vxlan.yaml

