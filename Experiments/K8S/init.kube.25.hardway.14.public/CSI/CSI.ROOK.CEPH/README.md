```



#kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
#kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
#kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
#kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
#kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml




helm repo add rook-release https://charts.rook.io/release

helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph -f helm-values.yaml

kubectl get pod -n rook-ceph

# git clone --single-branch --branch master https://github.com/rook/rook.git
# cd rook/deploy/examples
kubectl create -f yaml/cluster.yaml
kubectl create -f yaml/toolbox.yaml
kubectl apply -f yaml/filesystem.yaml
kubectl apply -f yaml/ceph-client.yaml
kubectl apply -f yaml/csi-ceph-conf-override.yaml


kubectl create -f rbd/storageclass.yaml
kubectl create -f cephfs/storageclass.yaml

kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash

kubectl apply -f rbd/pvc.yaml
kubectl apply -f rbd/pod.yaml

kubectl create -f cephfs/pvc.yaml
kubectl create -f cephfs/pod.yaml

kubectl apply -f yaml/mysql.yaml
kubectl apply -f yaml/wordpress.yaml

kubectl apply -f cephfs/pod-ephemeral.yaml

kubectl get pod,pvc



```
