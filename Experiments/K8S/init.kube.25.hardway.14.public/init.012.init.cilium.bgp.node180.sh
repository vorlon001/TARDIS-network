#!/usr/bin/bash




# BGP VERSION

kubectl label node node170 bgp=zone1
kubectl label node node171 bgp=zone1
kubectl label node node172 bgp=zone1


cat <<EOF | kubectl apply -f -
apiVersion: cilium.io/v2alpha1
kind: CiliumBGPPeeringPolicy
metadata:
  name: vyos
spec:
  nodeSelector:
    matchLabels:
      bgp: zone1
  virtualRouters:
  - localASN: 65000
    exportPodCIDR: true
    neighbors:
    - peerASN: 65000
      peerAddress: 192.168.200.180/32
    - peerASN: 65000
      peerAddress: 192.168.200.181/32
    - peerASN: 65000
      peerAddress: 192.168.200.182/32
    serviceSelector:
      matchExpressions:
      - key: somekey
        operator: NotIn
        values:
        - never-used-value
EOF


kubectl rollout restart -n kube-system daemonset cilium
kubectl get pod -n kube-system  -o wide
