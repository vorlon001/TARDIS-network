```shell

{
    "url":"http://192.168.1.20:9011/api/v1/service-account-credentials",
    "accessKey":"zAVrtp2oqRCDjW2ZOqCG",
    "secretKey":"vGzn7d5aZLojdNFJAnb6dJoKGsj40wa0s9EYKCWm",
    "api":"s3v4",
    "path":"auto"
}

zAVrtp2oqRCDjW2ZOqCG
vGzn7d5aZLojdNFJAnb6dJoKGsj40wa0s9EYKCWm


cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: Secret
metadata:
  name: csi-s3-secret
  namespace: kube-system
stringData:
  accessKeyID: zAVrtp2oqRCDjW2ZOqCG
  secretAccessKey: vGzn7d5aZLojdNFJAnb6dJoKGsj40wa0s9EYKCWm
  endpoint: http://192.168.200.2:9001
EOF

https://github.com/yandex-cloud/k8s-csi-s3/tree/master

>>> cd deploy/kubernetes
>>> kubectl create -f provisioner.yaml
>>> kubectl create -f driver.yaml
>>> kubectl create -f csi-s3.yaml

kubectl apply --filename https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/master/deploy/kubernetes/provisioner.yaml
kubectl apply --filename https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/master/deploy/kubernetes/driver.yaml
kubectl apply --filename https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/master/deploy/kubernetes/csi-s3.yaml

kubectl apply --filename https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/master/deploy/kubernetes/examples/storageclass.yaml

root@node180:~/CSI/CSI.1-NFS-PVC-STORE# kubectl get StorageClass
NAME     PROVISIONER        RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
csi-s3   ru.yandex.s3.csi   Delete          Immediate           false                  1s


cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-s3-pvc
  namespace: default
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: csi-s3
EOF

cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: Pod
metadata:
  name: csi-s3-test-nginx
  namespace: default
spec:
  containers:
   - name: csi-s3-test-nginx
     image: nginx
     volumeMounts:
       - mountPath: /usr/share/nginx/html/s3
         name: webroot
  volumes:
   - name: webroot
     persistentVolumeClaim:
       claimName: csi-s3-pvc
       readOnly: false
EOF



cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: Pod
metadata:
  name: csi-s3-test-nginx2
  namespace: default
spec:
  containers:
   - name: csi-s3-test-nginx2
     image: nginx
     volumeMounts:
       - mountPath: /usr/share/nginx/html/s3
         name: webroot
  volumes:
   - name: webroot
     persistentVolumeClaim:
       claimName: csi-s3-pvc
       readOnly: false
EOF


## UPGRADE:
wget https://raw.githubusercontent.com/yandex-cloud/k8s-csi-s3/v0.35.5/deploy/kubernetes/attacher.yaml
kubectl delete -f attacher.yaml

>>>> root@node180:~/CNI/CALICO/3.26.1# kubectl get secret/csi-s3-secret -n kube-system
>>>> NAME            TYPE     DATA   AGE
>>>> csi-s3-secret   Opaque   3      14s
>>>> root@node180:~/CNI/CALICO/3.26.1# kubectl get secret/csi-s3-secret -n kube-system -o yaml
>>>> apiVersion: v1
>>>> data:
>>>>   accessKeyID: ekFWcnRwMm9xUkNEalcyWk9xQ0c=
>>>>   endpoint: aHR0cDovLzE5Mi4xNjguMjAwLjI6OTAwMA==
>>>>   secretAccessKey: dkd6bjdkNWFaTG9qZE5GSkFuYjZkSm9LR3NqNDB3YTBzOUVZS0NXbQ==
>>>> kind: Secret
>>>> metadata:
>>>>   annotations:
>>>>     kubectl.kubernetes.io/last-applied-configuration: |
>>>>       {"apiVersion":"v1","kind":"Secret","metadata":{"annotations":{},"name":"csi-s3-secret","namespace":"kube-system"},"stringData":{"accessKeyID":"zAVrtp2oqRCDjW2ZOqCG","endpoint":"http://192.168.200.2:9000","secretAccessKey":"vGzn7d5aZLojdNFJAnb6dJoKGsj40wa0s9EYKCWm"}}
>>>>   creationTimestamp: "2023-07-23T11:44:51Z"
>>>>   name: csi-s3-secret
>>>>   namespace: kube-system
>>>>   resourceVersion: "3303"
>>>>   uid: ac4a6639-6c9e-4646-8744-63b2f504dcd6
>>>> type: Opaque



root@node180:~/CSI/CSI.1-NFS-PVC-STORE# kubectl exec -it csi-s3-test-nginx bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@csi-s3-test-nginx:/#
root@csi-s3-test-nginx:/#
root@csi-s3-test-nginx:/#
root@csi-s3-test-nginx:/# df -h
Filesystem                                Size  Used Avail Use% Mounted on
overlay                                    29G  7.6G   22G  27% /
tmpfs                                      64M     0   64M   0% /dev
/dev/sda1                                  29G  7.6G   22G  27% /etc/hosts
shm                                        64M     0   64M   0% /dev/shm
pvc-8cdd9074-0905-4312-a940-26bdc150b614  1.0P     0  1.0P   0% /usr/share/nginx/html/s3
tmpfs                                     5.8G   12K  5.8G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                                     3.9G     0  3.9G   0% /proc/acpi
tmpfs                                     3.9G     0  3.9G   0% /proc/scsi
tmpfs                                     3.9G     0  3.9G   0% /sys/firmware
root@csi-s3-test-nginx:/# cd /usr/share/nginx/html/s3

head -c 10 /dev/random | base64 | head -c 10 > rand.txt
head -c 10000000 /dev/random | base64 | head -c 100000000 > rand3.txt


cat <<EOF | kubectl apply --filename -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-s3-pvc-2
  namespace: default
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: csi-s3
EOF

cat <<EOF | kubectl apply --filename -
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: csi-s3-test-nginx2
spec:
  replicas: 20
  selector:
    matchLabels:
      app: csi-s3-test-nginx2
  template:
    metadata:
      labels:
        app: csi-s3-test-nginx2
    spec:
      containers:
       - name: nginx
         image: nginx
         volumeMounts:
           - mountPath: /usr/share/nginx/html/s3
             name: webroot
      volumes:
       - name: webroot
         persistentVolumeClaim:
           claimName: csi-s3-pvc2
           readOnly: false
EOF
```
