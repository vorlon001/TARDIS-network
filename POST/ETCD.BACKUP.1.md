### etcd backup

https://ithelp.ithome.com.tw/articles/10240323
https://github.com/Neskem/ironman_2020/
https://github.com/Neskem/ironman_2020/tree/day-28


```

$ apt install etcd-client

$ ETCDCTL_API=3 etcdctl version

$ cd /etc/kubernetes/manifests
$ cat etcd.yaml

...
    - --advertise-client-urls=https://172.17.0.14:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    ...
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    ...
...

$ ETCDCTL_API=3 etcdctl member list --endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt 
a9a3a87b9b08ff5e, started, g8master, https://192.168.132.241:2380, https://192.168.132.241:2379

## 以etcdctl snapshot save備份
$ ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
--endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt 
Snapshot saved at /tmp/etcd-backup.db

$ ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup.db -w table \
--endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt 
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| 24b6552d |  5488124 |       1113 |     4.6 MB |
+----------+----------+------------+------------+

```

### Security Context for a Pod

```
$ cat security-context.yaml 

apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /data/demo
    securityContext:
      allowPrivilegeEscalation: false
```

![](https://i.imgur.com/cLMAK3b.png)
![](https://i.imgur.com/iqr8Yk3.png)
![](https://i.imgur.com/0DWIhtq.png)
![](https://i.imgur.com/3YTr1N3.png)

```
$ kubectl run super-user-pod --image=busybox:1.28 --restart=Never --dry-run=client -o yaml > q8.yaml

$ vim q8.yaml

apiVersion: v1
kind: Pod
metadata: 
    name: super-user-pod
spec: 
    containers:
    - image: busybox:1.28
      name: super-user-pod
      ## 加上securityContext參數
      securityContext:
        capabilities:
        ## 允許設定SYS_TIME
          add: ["SYS_TIME"]
      ## container sleep 4800
      command: ["sleep"]
      args: ["4800"]
    restartPolicy: Never

$ kubectl apply -f q8.yaml
```

### Kubernetes: A Pod's Life
https://cloud.redhat.com/blog/kubernetes-pods-life

As you might have guessed, the title of this blog is a reference to the 1998 Pixar movie A Bug's Life and indeed, there are many parallels between a worker ant and a pod in Kubernetes. In the following, we'll have a closer look at the entire pod lifecycle here from a practitioners point-of-view, including ways how you can influence the start-up and shut-down behavior and good practices around application health-checking.

No matter if you create a pod manually or, preferably through a supervisor such as a deployment, a daemon set or a stateful set, the pod can be in one of the following phases:

Pending: The API Server has created a pod resource and stored it in etcd, but the pod has not been scheduled yet, nor have container images been pulled from the registry.
Running: The pod has been scheduled to a node and all containers have been created by the kubelet.
Succeeded: All containers in the pod have terminated successfully and will not be restarted.
Failed: All containers in the pod have terminated. At least one container has terminated in failure.
Unknown: The API Server was unable to query the state of the pod, typically due to an error in communicating with the kubelet.
When you do a kubectl get pod, note that the STATUS column might show a different message than the above five messages, such as Init:0/1 or CrashLoopBackOff. This is due to the fact that the phase is only part of the overall status of a pod. A good way to get an idea of what exactly has happened is to execute kubectl describe pod/$PODNAME and look at the Events: entry at the bottom. This lists relevant activities such as that a container image has been pulled, the pod has been scheduled, or that a container is unhealthy.

Let's now have a look at a concrete end-to-end example of a pod lifecycle as shown in the following:

![](https://assets.openshift.com/hubfs/Imported_Blog_Media/loap.png)

So, what is happening in this example, above? The steps are as follows:

Not shown in the diagram, before anything else, the infra container is launched establishing namespaces the other containers join.
The first user-defined container launching is the init container which you can use for pod-wide initialization.
Next, the main container and the post-start hook launch at the same time, in our case after 4 seconds. You define hooks on a per-container basis.
Then, at second 7, the liveness and readiness probes kick in, again on a per-container basis.
At second 11, when the pod is killed, the pre-stop hook is executed and finally, the main container is killed, after a grace period. Note that the actual pod termination is a bit more complicated.
But how did I arrive at the above shown sequence and the attached timing? I used the following deployment, which in itself is not very useful, other than to establish the order in which things are happening:

```
kind:                   Deployment
apiVersion:             apps/v1beta1
metadata:
  name:                 loap
spec:
  replicas:             1
  template:
    metadata:
      labels:
        app:            loap
    spec:
      initContainers:
      - name:           init
        image:          busybox
        command:       ['sh', '-c', 'echo $(date +%s): INIT >> /loap/timing']
        volumeMounts:
        - mountPath:    /loap
          name:         timing
      containers:
      - name:           main
        image:          busybox
        command:       ['sh', '-c', 'echo $(date +%s): START >> /loap/timing; sleep 10; echo $(date +%s): END >> /loap/timing;']
        volumeMounts:
        - mountPath:    /loap
          name:         timing
        livenessProbe:
          exec:
            command:   ['sh', '-c', 'echo $(date +%s): LIVENESS >> /loap/timing']
        readinessProbe:
          exec:
            command:   ['sh', '-c', 'echo $(date +%s): READINESS >> /loap/timing']
        lifecycle:
          postStart:
            exec:
              command:   ['sh', '-c', 'echo $(date +%s): POST-START >> /loap/timing']
          preStop:
            exec:
              command:  ['sh', '-c', 'echo $(date +%s): PRE-HOOK >> /loap/timing']
      volumes:
      - name:           timing
        hostPath:
          path:         /tmp/loap
```

Note that in order to force the termination of the pod, I executed the following once the main container was running:
```
$ kubectl scale deployment loap --replicas=0
```
Now that we've seen a concrete sequence of events in action, let's move on to some good practices around pod lifecycle management:

Use init containers to prepare the pod for normal operation. For example, to pull some external data, create database tables, or wait until a service it depends on is available. You can have multiple init containers if necessary and all need to complete successfully for the regular containers to start.
Always add a livenessProbe and a readinessProbe. The former is used by the kubelet to determine if and when to re-start a container and by a deployment to decide if a rolling update is successful. The later is used by a service to determine if a pod should receive traffic. If you don't provide the probes, the kubelet assumes for both types that they are successful and two things happen: The re-start policy can't be applied and containers in the pod immediately receive traffic from a service that fronts it, even if they're still busy starting up.
Use hooks to initialize a container and to tear it down properly. This is useful if, for example, you're running an app where you don't have access to the source code or you can't modify the source but it still requires some initialization or shutdown, such as cleaning up database connections. Note that when using a service, it can take a bit until the API Server, the endpoints controller, and the kube-proxy have completed their work, that is, removing the respective IPtables entries. Hence, in-flight requests might be impacted by a pod shutting down. Often, a simple sleep pre stop hook is sufficient to address this.
For debugging purposes and in general to understand why a pod terminated, your app can write to /dev/termination-log and you can view the message using kubectl describe pod .... You can change this default using terminationMessagePath and/or leverage the terminationMessagePolicy on the pod spec, see the API reference for details.
What we didn't cover in this post are initializers. This is a fairly new concept, introduced with Kubernetes 1.7. These initializers work in the control plane (API Server) rather than directly within the context of the kubelet and can be used to enrich pods, such as injecting side-car containers or enforce security policies. Also, we didn't discuss PodPresets which, going forward, may be superseded by the more flexible initializer concept.

#### NodePort

![](https://i.imgur.com/G5EuUDx.png)

```
apiVersion: v1
kind: Service
metadata:
  name: test-service1
  namespace: test
spec:
  type: NodePort
  selector:
    name: test-pod
  ports:
  - name: foo
    port: 80
    targetPort: 80
    nodePort: 30080
```

![](https://i.imgur.com/N0HFoWt.png)

#### LoadBalancer

![](https://i.imgur.com/uJH4lFj.png)

#### ExternalName

```
apiVersion: v1
kind: Service
metadata:
  name: opendata-api
  namespace: test
spec:
  type: ExternalName
  externalName: opendata.cwb.gov.tw
  ports:
  - port: 443
```

#### Taints and Tolerations vs. Node Affinity

```
kubectl taint nodes node1 key1=value1:NoSchedule

kubectl taint nodes node1 key1=value1:NoSchedule-

kubectl describe nodes node1
```

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "example-key"
    operator: "Exists"
    effect: "NoSchedule"
	- key: "key1"
	  operator: "Equal"
	  value: "value1"
	  effect: "NoExecute"
	  tolerationSeconds: 3600
```

```
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: In
            values:
            - antarctica-east1
            - antarctica-west1
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

#### Images

```
kubectl create secret docker-registry <name> --docker-server=DOCKER_REGISTRY_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL
```

```
apiVersion: v1
kind: Pod
metadata:
  name: foo
  namespace: awesomeapps
spec:
  containers:
    - name: foo
      image: janedoe/awesomeapp:v1
  imagePullSecrets:
    - name: myregistrykey
```


### Service Account

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
```

```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: build-robot
  automountServiceAccountToken: false
```

#### Kubernetes Volume EmptyDir

```
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-pod
spec:
  volumes:
    - name: html
      emptyDir: {}
  containers:
    - name: nginx
      image: nginx:latest
      volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
    - name: alpine
      image: alpine
      volumeMounts:
        - name: html
          mountPath: /html
      command: [ "/bin/sh", "-c" ]
      args: 
        - while true; do
          echo $(hostname) $(date) >> /html/index.html;
          sleep 10;
          done
```

```
kubectl apply -f emptydir.yaml

pod/emptydir-pod created

```

```
kubectl describe pod/emptydir-pod
--------
Containers:
  nginx:
    Container ID:   docker://64883c01c4e987beaa4cfbda1bba5cbe571b934dcc47b978e4adca4569a21170
    Image:          nginx:latest
    Image ID:       docker-pullable://nginx@sha256:1761fb5661e4d77e107427d8012ad3a5955007d997e0f4a3d41acc9ff20467c7
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 26 Jul 2022 17:05:41 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /usr/share/nginx/html from html (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-bmdwh (ro)
  alpine:
    Container ID:  docker://7881eb57f048f56e9d9ed4eedab818aaf876138cc488bef79746008c2a1047e9
    Image:         alpine
    Image ID:      docker-pullable://alpine@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
    Args:
      while true; do echo $(hostname) $(date) >> /html/index.html; sleep 10; done
    State:          Running
      Started:      Tue, 26 Jul 2022 17:05:47 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /html from html (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-bmdwh (ro)
	Conditions:
	  Type              Status
	  Initialized       True 
	  Ready             True 
	  ContainersReady   True 
	  PodScheduled      True 
	Volumes:
	  html:
	    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
	    Medium:     
	    SizeLimit:  <unset>
```

```
kubectl port-forward pod/emptydir-pod 8080:80
-------
Forwarding from 127.0.0.1:8080 -> 80pod 8080:80
Forwarding from [::1]:8080 -> 80
```

```
kubectl exec -it pods/emptydir-pod -c nginx -- sh
```

```
head -3 /usr/share/nginx/html/index.html
--------
emptydir-pod Tue Jul 26 09:05:47 UTC 2022
emptydir-pod Tue Jul 26 09:05:57 UTC 2022
emptydir-pod Tue Jul 26 09:06:07 UTC 2022
```

```
kubectl exec -it pods/emptydir-pod -c alpine -- sh

```

```
ps aux
--------
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sh -c while true; do echo $(hostname) $(date) >> /html/index.html; sleep 10; done
  371 root      0:00 sh
  395 root      0:00 sleep 10
  396 root      0:00 ps aux
```

```
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-memory-pod
spec:
  volumes:
    - name: html
      emptyDir:
        medium: Memory
        sizeLimit: 256Mi
  containers:
    - name: nginx
      image: nginx:latest
      volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
    - name: alpine
      image: alpine
      volumeMounts:
        - name: html
          mountPath: /html
      command: [ "/bin/sh", "-c" ]
      args:
        - while true; do
          echo $(hostname) $(date) >> /html/index.html;
          sleep 10;
          done
```

#### ConfigMap & Secret

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data:
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"
  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5    
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
```


```
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      env:
        - name: PLAYER_INITIAL_LIVES 
          valueFrom:
            configMapKeyRef:
              name: game-demo           
              key: player_initial_lives 
        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: ui_properties_file_name
      volumeMounts:
      - name: config
        mountPath: "/config"
        readOnly: true
  volumes:
    - name: config
      configMap:
        name: game-demo
        items:
        - key: "game.properties"
          path: "game.properties"
        - key: "user-interface.properties"
          path: "user-interface.properties"
```


```
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "echo $(SPECIAL_LEVEL_KEY) $(SPECIAL_TYPE_KEY)" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.how
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.type
```

```
kubectl create configmap my-config --from-file=path/to/bar

kubectl create configmap my-config --from-file=key1=/path/to/bar/file1.txt --from-file=key2=/path/to/bar/file2.txt

kubectl create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2

kubectl create configmap my-config --from-env-file=path/to/bar/file.env
```


```
apiVersion: v1
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: { ... }
  creationTimestamp: 2020-01-22T18:41:56Z
  name: mysecret
  namespace: default
  resourceVersion: "164619"
  uid: cfee02d6-c137-11e5-8d73-42010af00002
type: Opaque
```

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
		env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
            optional: false
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
            optional: false
  volumes:
  - name: foo
    secret:
      secretName: mysecret
      optional: false 
      defaultMode: 0400
```

#### Affinity 與 Anti-Affinity

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ironman
  labels:
    name: ironman
    app: ironman
spec:
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: ironman
  replicas: 1
  template:
    metadata:
      labels:
        app: ironman
    spec:
      nodeSelector:
        env: stg
      containers:
       - name: ironman
         image: ghjjhg567/ironman:latest
         imagePullPolicy: Always
         ports:
           - containerPort: 8100
         resources:
           limits:
             cpu: "1"
             memory: "2Gi"
           requests:
             cpu: 500m
             memory: 256Mi
         envFrom:
           - secretRef:
               name: ironman-config
         command: ["./docker-entrypoint.sh"]
       - name: redis
         image: redis:4.0
         imagePullPolicy: Always
         ports:
           - containerPort: 6379
       - name: nginx
         image: nginx
         imagePullPolicy: Always
         ports:
           - containerPort: 80
         volumeMounts:
           - mountPath: /etc/nginx/nginx.conf
             name: nginx-conf-volume
             subPath: nginx.conf
             readOnly: true
           - mountPath: /etc/nginx/conf.d/default.conf
             subPath: default.conf
             name: nginx-route-volume
             readOnly: true
         readinessProbe:
           httpGet:
             path: /v1/hc
             port: 80
           initialDelaySeconds: 5
           periodSeconds: 10
      volumes:
        - name: nginx-conf-volume
          configMap:
            name: nginx-config
        - name: nginx-route-volume
          configMap:
            name: nginx-route-volume
```

```
$ kubectl get pod --watch
NAME                      READY   STATUS    RESTARTS   AGE
ironman-7c7d8dd78-b2zp5   3/3     Running   0          24s
```

```
$ kubectl get pod
NAME                      READY   STATUS              RESTARTS   AGE
ironman-7c7d8dd78-b2zp5   0/3     ContainerCreating   0          5s
$ kubectl describe pod ironman-7c7d8dd78-b2zp5
Name:         ironman-7c7d8dd78-b2zp5
Namespace:    default
Priority:     0
Node:         gke-my-first-cluster-1-default-pool-dddd2fae-tz38/10.140.0.3
Start Time:   Mon, 05 Oct 2020 17:50:32 +0800
Labels:       app=ironman
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ironman
  labels:
    name: ironman
    app: ironman
spec:
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: ironman
  replicas: 1
  template:
    metadata:
      labels:
        app: ironman
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: env
                    operator: In
                    values:
                      - test
                      - uat
      containers:
       - name: ironman
         image: ghjjhg567/ironman:latest
         imagePullPolicy: Always
         ports:
           - containerPort: 8100
         resources:
           limits:
             cpu: "1"
             memory: "2Gi"
           requests:
             cpu: 500m
             memory: 256Mi
         envFrom:
           - secretRef:
               name: ironman-config
         command: ["./docker-entrypoint.sh"]
       - name: redis
         image: redis:4.0
         imagePullPolicy: Always
         ports:
           - containerPort: 6379
       - name: nginx
         image: nginx
         imagePullPolicy: Always
         ports:
           - containerPort: 80
         volumeMounts:
           - mountPath: /etc/nginx/nginx.conf
             name: nginx-conf-volume
             subPath: nginx.conf
             readOnly: true
           - mountPath: /etc/nginx/conf.d/default.conf
             subPath: default.conf
             name: nginx-route-volume
             readOnly: true
         readinessProbe:
           httpGet:
             path: /v1/hc
             port: 80
           initialDelaySeconds: 5
           periodSeconds: 10
      volumes:
        - name: nginx-conf-volume
          configMap:
            name: nginx-config
        - name: nginx-route-volume
          configMap:
            name: nginx-route-volume
```

```
$ kubectl apply -f deployment.yaml
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
ironman   0/1     1            0           17s
kubectl get pod --watch
NAME                       READY   STATUS        RESTARTS   AGE
ironman-6d655d444d-gffx6   2/3     Terminating   0          9m32s
ironman-db66975d8-rtvgg    0/3     Pending       0          21s
ironman-6d655d444d-gffx6   0/3     Terminating   0          9m36s
ironman-6d655d444d-gffx6   0/3     Terminating   0          9m48s
ironman-6d655d444d-gffx6   0/3     Terminating   0          9m48s
ironman-db66975d8-rtvgg    0/3     Pending       0          37s
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ironman
  labels:
    name: ironman
    app: ironman
spec:
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: ironman
  replicas: 1
  template:
    metadata:
      labels:
        app: ironman
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: env
                    operator: In
                    values:
                      - test
                      - stg
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 1
              preference:
                matchExpressions:
                  - key: priority
                    operator: In
                    values:
                      - first
      containers:
       - name: ironman
         image: ghjjhg567/ironman:latest
         imagePullPolicy: Always
         ports:
           - containerPort: 8100
         resources:
           limits:
             cpu: "1"
             memory: "2Gi"
           requests:
             cpu: 500m
             memory: 256Mi
         envFrom:
           - secretRef:
               name: ironman-config
         command: ["./docker-entrypoint.sh"]
       - name: redis
         image: redis:4.0
         imagePullPolicy: Always
         ports:
           - containerPort: 6379
       - name: nginx
         image: nginx
         imagePullPolicy: Always
         ports:
           - containerPort: 80
         volumeMounts:
           - mountPath: /etc/nginx/nginx.conf
             name: nginx-conf-volume
             subPath: nginx.conf
             readOnly: true
           - mountPath: /etc/nginx/conf.d/default.conf
             subPath: default.conf
             name: nginx-route-volume
             readOnly: true
         readinessProbe:
           httpGet:
             path: /v1/hc
             port: 80
           initialDelaySeconds: 5
           periodSeconds: 10
      volumes:
        - name: nginx-conf-volume
          configMap:
            name: nginx-config
        - name: nginx-route-volume
          configMap:
            name: nginx-route-volume
```

```
$ kubectl apply -f deployment.yaml
deployment.apps/ironman created
$ kubectl get pod --watch
NAME                       READY   STATUS              RESTARTS   AGE
ironman-5bb87585db-pqp8b   0/3     ContainerCreating   0          3s
ironman-5bb87585db-pqp8b   2/3     Running             0          8s
ironman-5bb87585db-pqp8b   2/3     Running             0          14s
ironman-5bb87585db-pqp8b   3/3     Running             0          18s
ironman-5bb87585db-pqp8b   3/3     Running             0          18s
```


```
$ kubectl label nodes gke-my-first-cluster-1-default-pool-dddd2fae-rfl8 env=stg
node/gke-my-first-cluster-1-default-pool-dddd2fae-rfl8 labeled
$ kubectl label nodes gke-my-first-cluster-1-default-pool-dddd2fae-rfl8 priority=first
node/gke-my-first-cluster-1-default-pool-dddd2fae-rfl8 labeled
$ kubectl apply -f deployment.yaml
deployment.apps/ironman created
```

```
$ kubectl get pod
NAME                      READY   STATUS    RESTARTS   AGE
ironman-9c45876f7-ztskh   3/3     Running   0          39s
$ kubectl describe pod ironman-9c45876f7-ztskh
Name:         ironman-9c45876f7-ztskh
Namespace:    default
Priority:     0
Node:         gke-my-first-cluster-1-default-pool-dddd2fae-rfl8/10.140.0.2
Start Time:   Mon, 05 Oct 2020 18:16:40 +0800
Labels:       app=ironman
              pod-template-hash=9c45876f7
Annotations:  <none>
Status:       Running
IP:           10.0.0.25
IPs:
```

ironman1.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ironman-1
  labels:
    name: ironman
    app: ironman
spec:
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: ironman
  replicas: 1
  template:
    metadata:
      labels:
        app: ironman
        ironman: one
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: ironman
                operator: In
                values:
                - one
                - three
            topologyKey: kubernetes.io/hostname
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: ironman
                  operator: In
                  values:
                  - two
              topologyKey: kubernetes.io/hostname
      containers:
       - name: ironman
         image: ghjjhg567/ironman:latest
         imagePullPolicy: Always
         ports:
           - containerPort: 8100
         envFrom:
           - secretRef:
               name: ironman-config
         command: ["./docker-entrypoint.sh"]
       - name: redis
         image: redis:4.0
         imagePullPolicy: Always
         ports:
           - containerPort: 6379
       - name: nginx
         image: nginx
         imagePullPolicy: Always
         ports:
           - containerPort: 80
         volumeMounts:
           - mountPath: /etc/nginx/nginx.conf
             name: nginx-conf-volume
             subPath: nginx.conf
             readOnly: true
           - mountPath: /etc/nginx/conf.d/default.conf
             subPath: default.conf
             name: nginx-route-volume
             readOnly: true
         readinessProbe:
           httpGet:
             path: /v1/hc
             port: 80
           initialDelaySeconds: 5
           periodSeconds: 10
      volumes:
        - name: nginx-conf-volume
          configMap:
            name: nginx-config
        - name: nginx-route-volume
          configMap:
            name: nginx-route-volume
```

ironman2.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ironman-2
  labels:
    name: ironman
    app: ironman
spec:
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: ironman
  replicas: 1
  template:
    metadata:
      labels:
        app: ironman
        ironman: two
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: ironman
                operator: In
                values:
                - two
            topologyKey: kubernetes.io/hostname
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: ironman
                  operator: In
                  values:
                  - one
                  - three
              topologyKey: kubernetes.io/hostname
      containers:
       - name: ironman
         image: ghjjhg567/ironman:latest
         imagePullPolicy: Always
         ports:
           - containerPort: 8100
         envFrom:
           - secretRef:
               name: ironman-config
         command: ["./docker-entrypoint.sh"]
       - name: redis
         image: redis:4.0
         imagePullPolicy: Always
         ports:
           - containerPort: 6379
       - name: nginx
         image: nginx
         imagePullPolicy: Always
         ports:
           - containerPort: 80
         volumeMounts:
           - mountPath: /etc/nginx/nginx.conf
             name: nginx-conf-volume
             subPath: nginx.conf
             readOnly: true
           - mountPath: /etc/nginx/conf.d/default.conf
             subPath: default.conf
             name: nginx-route-volume
             readOnly: true
         readinessProbe:
           httpGet:
             path: /v1/hc
             port: 80
           initialDelaySeconds: 5
           periodSeconds: 10
      volumes:
        - name: nginx-conf-volume
          configMap:
            name: nginx-config
        - name: nginx-route-volume
          configMap:
            name: nginx-route-volume
```

ironman3.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ironman-3
  labels:
    name: ironman
    app: ironman
spec:
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: ironman
  replicas: 1
  template:
    metadata:
      labels:
        app: ironman
        ironman: three
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: ironman
                operator: In
                values:
                - one
                - three
            topologyKey: kubernetes.io/hostname
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: ironman
                  operator: In
                  values:
                  - two
              topologyKey: kubernetes.io/hostname
      containers:
       - name: ironman
         image: ghjjhg567/ironman:latest
         imagePullPolicy: Always
         ports:
           - containerPort: 8100
         envFrom:
           - secretRef:
               name: ironman-config
         command: ["./docker-entrypoint.sh"]
       - name: redis
         image: redis:4.0
         imagePullPolicy: Always
         ports:
           - containerPort: 6379
       - name: nginx
         image: nginx
         imagePullPolicy: Always
         ports:
           - containerPort: 80
         volumeMounts:
           - mountPath: /etc/nginx/nginx.conf
             name: nginx-conf-volume
             subPath: nginx.conf
             readOnly: true
           - mountPath: /etc/nginx/conf.d/default.conf
             subPath: default.conf
             name: nginx-route-volume
             readOnly: true
         readinessProbe:
           httpGet:
             path: /v1/hc
             port: 80
           initialDelaySeconds: 5
           periodSeconds: 10
      volumes:
        - name: nginx-conf-volume
          configMap:
            name: nginx-config
        - name: nginx-route-volume
          configMap:
            name: nginx-route-volume
```

```
$ kubectl apply -f ironman-1.yaml
deployment.apps/ironman-1 created
$ kubectl apply -f ironman-2.yaml
deployment.apps/ironman-2 created
$ kubectl apply -f ironman-3.yaml
deployment.apps/ironman-3 created
```


```
$ kubectl get pod
NAME                         READY   STATUS    RESTARTS   AGE
ironman-1-59cc5784ff-l9lh6   3/3     Running   0          41s
ironman-2-67647c9b7c-5n6f4   3/3     Running   0          34s
ironman-3-5797656cf5-662td   3/3     Running   0          29s

$ kubectl describe pod ironman-1-59cc5784ff-l9lh6
Name:         ironman-1-59cc5784ff-l9lh6
Namespace:    default
Priority:     0
Node:         gke-my-first-cluster-1-default-pool-dddd2fae-j0k1/10.140.0.4
Start Time:   Mon, 05 Oct 2020 19:20:14 +0800

kubectl describe pod ironman-2-67647c9b7c-5n6f4
Name:         ironman-2-67647c9b7c-5n6f4
Namespace:    default
Priority:     0
Node:         gke-my-first-cluster-1-default-pool-dddd2fae-tz38/10.140.0.3

$ kubectl describe pod ironman-3-5797656cf5-662td
Name:         ironman-3-5797656cf5-662td
Namespace:    default
Priority:     0
Node:         gke-my-first-cluster-1-default-pool-dddd2fae-j0k1/10.140.0.4
```

#### Kubernetes AutoScaler

![](https://ithelp.ithome.com.tw/upload/images/20201014/20129737cjsTiEEohC.png)

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: ironman-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ironman
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 50
```


Algorithm details
desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]

![](https://ithelp.ithome.com.tw/upload/images/20201014/20129737HRbHkYUf9O.png)

deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ironman
  labels:
    name: ironman
    app: ironman
spec:
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: ironman
  replicas: 1
  template:
    metadata:
      labels:
        app: ironman
    spec:
      containers:
       - name: ironman
         image: ghjjhg567/ironman:latest
         imagePullPolicy: Always
         ports:
           - containerPort: 8100
         resources:
           limits:
             cpu: "1"
             memory: "2Gi"
           requests:
             cpu: 500m
             memory: 256Mi
         envFrom:
           - secretRef:
               name: ironman-config
         command: ["./docker-entrypoint.sh"]
       - name: redis
         image: redis:4.0
         imagePullPolicy: Always
         ports:
           - containerPort: 6379
       - name: nginx
         image: nginx
         imagePullPolicy: Always
         ports:
           - containerPort: 80
         volumeMounts:
           - mountPath: /etc/nginx/nginx.conf
             name: nginx-conf-volume
             subPath: nginx.conf
             readOnly: true
           - mountPath: /etc/nginx/conf.d/default.conf
             subPath: default.conf
             name: nginx-route-volume
             readOnly: true
           - mountPath: "/var/www/html"
             name: mypd
         readinessProbe:
           httpGet:
             path: /v1/hc
             port: 80
           initialDelaySeconds: 5
           periodSeconds: 10
      volumes:
        - name: nginx-conf-volume
          configMap:
            name: nginx-config
        - name: nginx-route-volume
          configMap:
            name: nginx-route-volume
        - name: mypd
          persistentVolumeClaim:
            claimName: pvc
```

### StatefulSet

![](https://ithelp.ithome.com.tw/upload/images/20201012/20129737xpZvzODwUM.png)
![](https://ithelp.ithome.com.tw/upload/images/20201012/2012973728agqHjEC0.png)

```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```

```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: slow
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
```

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
spec:
  selector:
    matchLabels:
      role: mongo
      environment: test
  serviceName: "mongo"
  replicas: 3
  template:
    metadata:
      labels:
        role: mongo
        environment: test
    spec:
      terminationGracePeriodSeconds: 10
      containers:
        - name: mongo
          image: mongo:3.4
          command:
            - mongod
            - "--replSet"
            - rs0
            - "--bind_ip"
            - 0.0.0.0
            - "--smallfiles"
            - "--noprealloc"
          ports:
            - containerPort: 27017
          volumeMounts:
            - name: mongo-persistent-storage
              mountPath: /data/db
        - name: mongo-sidecar
          image: cvallance/mongo-k8s-sidecar
          env:
            - name: MONGO_SIDECAR_POD_LABELS
              value: "role=mongo,environment=test"
  volumeClaimTemplates:
  - metadata:
      name: mongo-persistent-storage
      annotations:
        volume.beta.kubernetes.io/storage-class: "fast"
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 100Gi
```


```
apiVersion: v1
kind: Service
metadata:
  name: mongo
  labels:
    name: mongo
spec:
  ports:
  - port: 27017
    targetPort: 27017
  clusterIP: None
  selector:
    role: mongo
```

```
$ kubectl apply -f ssd.yaml
storageclass.storage.k8s.io/fast created

$ kubectl apply -f hhd.yaml
storageclass.storage.k8s.io/slow created
```


```
$ kubectl apply -f statefulset.yaml
statefulset.apps/mongo created
$ kubectl apply -f headless-service.yaml 
service/mongo created
```

#### Namespace Rbac
https://ithelp.ithome.com.tw/articles/10252766

![](https://ithelp.ithome.com.tw/upload/images/20201013/20129737F10FwgsSWh.png)

```
$ kubectl create namespace newspace
namespace/newspace created
```

```
$ kubectl delete namespace newspace
namespace "newspace" deleted
```

```
apiVersion: v1
kind: Namespace
metadata:
  name: newspace
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: newspace-quotas-1
  namespace: newspace
spec:
  hard:
    requests.cpu: "1"
    limits.cpu: "1"
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: newspace-quotas-2
  namespace: newspace
spec:
  hard:
    services: "3"
    secrets: "3"
    configmaps: "3"
    replicationcontrollers: "10"
```

- count/persistentvolumeclaims
- count/services
- count/secrets
- count/configmaps
- count/replicationcontrollers
- count/deployments.apps
- count/replicasets.apps
- count/statefulsets.apps
- count/jobs.batch
- count/cronjobs.batch
- count/deployments.extensions

#### What is Role ?

![](https://ithelp.ithome.com.tw/upload/images/20201013/20129737j2seMDtGN9.png)

role.yaml
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: newspace
  name: jenkins-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "list", "watch"]
```


role.yaml
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: newspace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: newspace
  name: jenkins-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "list", "watch"]
```

#### What is RoleBinding ?

role.yaml
```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: newspace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: newspace
  name: jenkins-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-rolebinding
  namespace: newspace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: jenkins-role
subjects:
  - kind: ServiceAccount
    name: jenkins
    namespace: newspace
```

Deployment with serviceAccount, role and roleBinding

```
$ kubectl apply -f role.yaml
serviceaccount/jenkins created
role.rbac.authorization.k8s.io/jenkins-role created
rolebinding.rbac.authorization.k8s.io/jenkins-rolebinding created
```

```
$ kubectl get rolebinding -n newspace
NAME                  ROLE                AGE
jenkins-rolebinding   Role/jenkins-role   26s
```

#### What is ClusterRole ?

clusterrole.yaml
```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-global
  namespace: newspace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: newspace
  name: jenkins-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["services", "endpoints"]
    verbs: ["get", "list", "watch"]```
```

#### What is ClusterRoleBinding ?

```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-global
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: newspace
  name: jenkins-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["services", "endpoints"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-rolebinding
  namespace: newspace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins-role
subjects:
  - kind: ServiceAccount
    name: jenkins-global
    namespace: newspace
```





