
Kubernetes Pod Priority, PriorityClass, and Preemption Explained
================================================================

In this [Kubernetes tutorial](https://devopscube.com/kubernetes-tutorials-beginners/), you will learn about important [Kubernetes pod](https://devopscube.com/kubernetes-pod/) scheduling concepts such as Pod priority, Preemption, and Pod PriorityClass

What is Pod priority in Kubernetes?
-----------------------------------

**Pod priority** is a Kubernetes scheduling feature that allows Kubernetes to make scheduling decisions comparing other pods based on priority number. Let’s look at the following two main concepts in pod priority.

1.  Pod Preemption
2.  Pod Priority Class

### Pod Preemption

The pod preemption feature allows Kubernetes to preempt (evict) lower-priority pods from nodes when higher-priority pods are in the scheduling queue and no node resources are available.

### Kubernetes Pod Priority Class

To assign a pod a certain priority, you need a priority class.

You can set a priority for a Pod using the `PriorityClass` object (non-namespaced) with a Value.

The value determines the priority. It can be **1,000,000,000 (one billion) or lower.** Larger the number, the higher the priority.

![Kubernetes Pod Priority value](https://cdn.substack.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F59a8997e-28af-411e-b91f-28fbfccb375e_423x198.png)

The name of the priorityclass (`priorityClassName`) will be used in the pod specification to set the priority.

> If you don’t want the priority class to preempt the pods, you can set `PreemptionPolicy: Never`. By default, Priorityclasss use `PreemptLowerPriority` policy.

![Kubernetes Pod Priorityclass name](https://cdn.substack.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fbucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com%2Fpublic%2Fimages%2F6aca5db6-9358-4279-b7ea-3440bac090bb_415x320.png)

### Pod PriorityClass Example

The following example has a PriorityClass object and a pod that uses the PriorityClass.

    apiVersion: scheduling.k8s.io/v1
    kind: PriorityClass
    metadata:
      name: high-priority-apps
    value: 1000000
    preemptionPolicy: PreemptLowerPriority
    globalDefault: false
    description: "Mission Critical apps."
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
      labels:
        env: dev
    spec:
      containers:
      - name: web
        image: nginx:latest
        imagePullPolicy: IfNotPresent
      priorityClassName: high-priority-apps

### Kubernetes System High PriorityClass

How do you **safeguard system-critical pods** from preemption?

Well, there are two default high-priority classes set by Kubernetes

1.  **system-node-critical:** This class has a value of `2000001000`. Static pods Pods like etcd, kube-apiserver, kube-scheduler and Controller manager use this priority class.
2.  **system-cluster-critical:** This class has a value of `2000000000`. Addon Pods like coredns, calico controller, metrics server, etc use this Priority class.

How does Kubernetes Pod Priority & Preemption work?
---------------------------------------------------

1.  If a pod is deployed with `PriorityClassName`, the priority admission controller gets the priority value using the PriorityClassName value.
2.  If there are many pods in the scheduling queue, the scheduler arranges the scheduling order based on priority. Meaning, the scheduler places the high-priority pod ahead of low priority pods
3.  Now, if there are no nodes available with resources to accommodate a higher-priority pod, the preemption logic kicks in.
4.  The scheduler preempts (evicts) low priority pod from a node where it can schedule the higher-priority pod. The evicted pod gets a graceful default termination time of 30 seconds. If pods have `terminationGracePeriodSeconds` set for `preStop` [container Lifecycle Hooks](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/), it overrides the default 30 seconds.
5.  However, if for some reason, the scheduling requirements are not met, the scheduler goes ahead with scheduling the lower-priority pods.

![Pod priorityclass scheduling workflow](https://devopscube.com/wp-content/uploads/2022/04/pod-priorityclass.png)

Now we know how **kubernetes pod scheduling priority works** with Priorityclass and preemption.

Pod Priority FAQs
-----------------

* * *

### What is Kubernetes DaemonSet Priority?

[Daemonset](https://devopscube.com/kubernetes-daemonset/) has priority like any other pod. Therefore, if you want your Daemonsets to be stable and not evicted during a node resource crunch, you need to set a higher pod PriorityClass to the Daemonset.

### How is Pod QoS related to Pod Priority & Preemption?

Kubelet first considers the QoS class and then the pod priority value to evict pods. This happens only when there is a resource shortage on the nodes.

However, preemption logic kicks in only when high-priority pods are on the scheduling queue. The scheduler ignores the pod QoS during pod preemption. Whereas a QoS-based eviction happens without a scheduling queue due to a resource crunch.

### What is the significance of Pod Priority?

When you deploy apps to Kubernetes in production, there are certain apps you don’t want to get killed. For example, a metrics collector Daemonset, logging agents, payment service, etc.

To ensure the availability of mission-critical pods, you can create a hierarchy of pod tiers with priorities; when there is a resource crunch in the clusters, kubelet tries to kill the low-priority pods to accommodate pods with higher PriorityClass.

