https://www.educative.io/blog/kubernetes-deployments-strategies

A deep dive into Kubernetes Deployment strategies
=================================================


With the use of containerized applications and microservices on the rise, there’s never been a better time to [become a Kubernetes expert](https://www.educative.io/catalog/kubernetes).

Kubernetes is an open-source **container orchestration system** designed to automate application scaling and management. While Kubernetes is incredibly powerful, it’s also notoriously difficult to learn.

Today, we’ll get you one step closer to Kubernetes expertise with a walkthrough of the **Deployment object**, Kubernetes’ vehicle for ReplicaSet management, and live system updates.

**Here’s what we’ll cover today:**

* [What is a Deployment in Kubernetes?](#what)
* [Deployment update strategies](#strategies)
* [Rolling update strategy](#rolling)
* [Recreate update strategy](#recreate)
* [Canary update strategy](#canary)
* [What to learn next](#next)

  
  

### **Brush up on top Kubernetes concepts**

Become an in-demand Kubernetes expert with hands-on lessons and practice build right into your browser.

**[Learn Kubernetes: A Deep Dive](https://www.educative.io/courses/the-kubernetes-course)**

  

  

What is a Deployment in Kubernetes?
-----------------------------------

A Deployment is a **resource object** in Kubernetes that defines the **desired state** for your program.

Deployments are declarative, meaning that you don’t dictate how to achieve the state. Instead, you declare your **endpoint** (called a “desired state”) and allow the Deployment-controller to automatically reach that end goal in the most efficient way.

Once running, the Deployment compares the current program state to the desired state. If they do not match, the Deployment-controller automatically alters the state to match.

> This automatic state maintenance is what gives Kubernetes it’s beloved self-healing properties.

Desired states can include how many Pods are running, what type of Pods those are, what container images are available to the program, and the desired workload for each Pod.

If any aspect of the desired state is missing, the Deployment-controller will alter the program until they are met.

  

### ReplicaSets

![Relationship between Deployments, ReplicaSets, and Pods](https://www.educative.io/api/page/5744315014840320/image/download/5896507618754560)

Relationship between Deployments, ReplicaSets, and Pods

The main way Deployments maintain a program’s desired state is through the use of **ReplicaSets**.

A ReplicaSet is a set of **identical backup Pods** maintained on the backend side to ensure a Pod is always available. If a user-facing Pod fails or becomes overworked, the Deployment allocates work to a Pod from the ReplicaSet to maintain responsiveness.

If a Pod from the ReplicaSet fails, it automatically creates an additional Pod from the template.

The Pods in a ReplicaSet are designed using a **single Pod template** provided by the Deployment that defines the specifications shared by the Pod cluster. The template specifications are properties like:

* What applications should run in the Pods?
* What labels should the Pods have?
* Under what conditions will the Pod restart?

It’s best practice to not manage ReplicaSets directly. You should perform all actions against the Deployment object and leave the Deployment to manage ReplicaSets.

> Each Deployment can only manage a single Pod template but can manage multiple Replica Pods from the same template.
> 
> You’ll need to create multiple Deployments to maintain multiple different ReplicaSets.

  

### Updating with Deployments

The main advantage of Deployments is for **automatically updating** your Kubernetes program.

Without Deployments, you’d have to manually end all old Pods, start new Pod versions and run a check to see if there were any problems during Pod creation.

Deployments automate the whole updating process as you can simply update the Pod template or desired state. The Deployment will alter the program state in the background with actions like creating new Pods, allocating more resources, and so on, until the updated desired state is met.

You can even **rollback updates** to a previous version. Old ReplicaSets still exist with full Pod configurations but simply don’t manage any Pods once a new ReplicaSet is made.

If you want to rollback to a previous version, you simply need to change the desired state to favor the old ReplicaSet and the Deployment will automatically revert.

  

Update Deployment Strategies
----------------------------

Kubernetes offers Deployment strategies that allow you to update in a variety of ways depending on the needs of the system. The three most common are:

* **Rolling update strategy**: Minimizes downtime at the cost of update speed.
* **Recreation Strategy**: Causes downtime but updates quickly.
* **Canary Strategy**: Quickly updates for a select few users with a full rollout later.

Let’s take a deeper look at each of these three strategies!

  

Rolling update strategy
-----------------------

The rolling update strategy is a gradual process that allows you to update your Kubernetes system with only a minor effect on performance and no downtime.

![Rolling update strategy flowchart](https://www.educative.io/api/page/5744315014840320/image/download/5966421029289984)

Rolling update strategy flowchart

In this strategy, the Deployment selects a Pod with the old programming, deactivates it, and creates an updated Pod to replace it. The Deployment repeats this process until no outdated Pods remain.

The advantage of the rolling update strategy is that the update is applied **Pod-by-Pod** so the greater system can remain active.

There is a minor performance reduction during this update process because the system is consistently one active Pod short of the desired number of Pods. This is often much preferred to a full system deactivation.

The rolling update strategy is used as the **default update strategy** but isn’t suited for all situations. Some considerations when deciding to use a rolling update strategy are:

* How will my system react to momentarily duplicated Pods?
* Is the update substantial enough to malfunction with some Pods still running old specifications?
* Will a minor performance reduction greatly affect the usability of my system? How finely time-sensitive is my system?

For example, imagine we wanted to change the specifications for our Pods. We’d first change the Pod template to new specifications, which is passed from the Deployment to the ReplicaSet.

The Deployment would then recognize that the current program state (Pods with old specifications) is different from the desired state (Pods with new specifications).

The Deployment would create Pods and a ReplicaSet with the updated specifications and transfer workload one-by-one from the old Pods to the new Pods.

By the end, we’ll have an entirely new set of Pods and ReplicaSet without any service downtime.

  

### Rolling Update Implementation

We’ll use a YAML file declaration named `deploy.yaml` to create our Deployment.

```yaml
apiVersion: apps/v1  #Older versions of k8s use apps/v1beta1
kind: Deployment
metadata:
  name: hello-deploy
spec:
  replicas: 10
  selector:
    matchLabels:
      app: hello-world
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-Pod
        image: educative/k8sbook:latest
        ports:
        - containerPort: 8080
```
Right at the very top, you specify the Kubernetes API version to use. Assuming that you’re using an up-to-date version of Kubernetes, Deployment objects are in the `apps/v1` API group.

Next, the `.kind` field tells Kubernetes you’re defining a Deployment object.

The `.metadata` section is where we give the Deployment a name and labels.

The `.spec` section is where most of the action happens. Anything directly below `.spec` relates to the Pod. Anything nested below `.spec.template` relates to the Pod template that the Deployment will manage. In this example, the Pod template defines a single container.

* `.spec.replicas` tells Kubernetes how many Pod replicas to deploy.
    
* `spec.selector` is a list of labels that Pods must have in order for the Deployment to manage them.
    
* `.spec.strategy` tells Kubernetes how to perform updates to the Pods managed by the Deployment, in this case `RollingUpdate`.
    

Finally, we’ll apply this Deployment to our Kubernetes cluster with the command:

    $ kubectl apply -f deploy.yml

  


Recreate update strategy
------------------------

The recreate update strategy is an all-or-nothing process that allows you to update all aspects of the system at once with a brief downtime period.

![Recreate update strategy flowchart](https://www.educative.io/api/page/5744315014840320/image/download/5370509315801088)

Recreate update strategy flowchart

In this strategy, the Deployment selects all **outdated Pods** and deactivates them at once.

Once all old Pods are deactivated, the Deployment creates updated Pods for the entire system. The system is inoperable starting at the old Pod’s deactivation and ending once the final updated Pod is created.

The recreate strategy is used for systems that cannot function in a partially updated state or if you would rather have downtime than provide users a lesser experience. The bigger the update, the more likely a rolling update will cause an error.

> Therefore, recreate strategy is better for large updates and overhauls.

When you’re considering the recreate strategy, ask yourself:

* Would my users have a better experience with downtime or temporarily reduced performance?
* Could my system function during a rolling update?
* Is there a time I could update the system without affecting a significant number of users?

  

### Recreate Update Implementation

This implementation is very similar to the rolling update strategy.

```yaml
apiVersion: apps/v1  #Older versions of k8s use apps/v1beta1
kind: Deployment
metadata:
  name: hello-deploy
spec:
  replicas: 10
  selector:
    matchLabels:
      app: hello-world
  minReadySeconds: 10
  strategy:
    type: Recreate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-Pod
        image: educative/k8sbook:latest
        ports:
        - containerPort: 8080
```

Enter to Rename, Shift+Enter to Preview

As you can see, the only difference between the implementation of rolling update and recreate is on line 12 where we’ve replaced `strategy.type: RollingUpdate` to `strategy.type: Recreate`.

Just as last time, we’ll deploy the Deployment via the command-line using:

    $ kubectl apply -f deploy.yml

  

Canary update strategy
----------------------

The canary update strategy is a partial update process that allows you to test your new program version on a real userbase without a commitment to a full rollout.

![Both steps of the canary update strategy](https://www.educative.io/api/page/5744315014840320/image/download/5388790506979328)

Both steps of the canary update strategy

In this strategy, the Deployment creates a **few new Pods** while keeping most Pods on the previous version, usually at a **1:4 ratio**.

Most users still use the previous version, but a small subset unknowingly use the new version to act as testers.

If we don’t detect any bugs from this subset, we can scale up the updated ReplicaSet to produce a full rollout.

If we do find a bug, we can easily rollback the few updated Pods until we’ve fixed the bug.

The advantage of the canary update strategy is it allows you to test a new version without the risk of a full system failure.

In the worst-case scenario, all users from the test subset experience critical errors while 75% or more of the user base continues without interruption.

The rollback process is also much quicker than the rolling update strategy because you only have to rollback a portion of the Pods rather than the entire system.

The downside is that the updated Pods will require a **separate Deployment**, which can be hard to manage at scale. Also, the canary strategy results in a slower rollout due to the waiting period after rollout to our initial subset and the completion of a full rollout.

When considering the canary strategy, ask yourself:

* What’s the worst-case scenario if this update fails?
* How soon do I need to finish the full rollout?
* How much internal testing have I done?

  

### Canary Update Implementation

For this implementation, we’ll need to create two Deployments in two YAML files.

  

**Version 1 Deployment**

Our first file, `k8s-deployment.yaml`, will be our outdated version that most of our Pods will run.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld
spec:
  replicas: 3
  strategy:
    rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
  minReadySeconds: 5
  template:
    metadata:
      labels:
        app: helloworld
        track: stable
    spec:
      containers:
      - name: helloworld
        image: educative/helloworld:1.0
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 50m
          limits:
            cpu: 100m
```

This will create 3 Pods of `v1` with the `app:helloworld` label that our Kubernetes service is looking for. Our image for these Pods is `educative/helloworld:1.0`, meaning that these Pods will be created off the old Pod specifications.

This Deployment will evenly divide any workload among available Pods.

You will deploy this by entering this line into the command-line:

    kubectl apply -f k8s-deployment.yaml

> **Notice:** Unlike the previous implementations, `canary` is not listed under `strategy` as its implementation is more complicated.
> 
> Instead, both versions are listed as `rollingUpdates` because updates within each version will be rollout while the overall system’s strategy is canary.

  

**Version 2 Deployment**

Now, we’ll create our second yaml file, `k8s-deployment-canary.yaml`, which is our new canary `v2` version.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-canary
spec:
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 5
  template:
    metadata:
      labels:
        app: helloworld
        track: canary
    spec:
      containers:
      - name: helloworld
        image: educative/helloworld:2.0
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 50m
          limits:
            cpu: 100m
```

For this Deployment, we only create a single Pod (line 6) to ensure most of our userbase still interacts with `v1`.

Both Deployments will balance the workload among all Pods which ensures only 25% of our workload will be on the updated Pod.

You can deploy this Deployment via the command-line using:

    kubectl apply -f k8s-deployment-canary.yaml

Once you’re satisfied that `v2` works, simply replace the image in our first Deployment YAML file, `k8s-deployment.yaml`, to be `educative/helloworld:2.0` rather than `educative/helloworld:1.0`.

Then remove the canary Deployment with:

    kubectl delete -f k8s-deployment-canary.yaml

Our desired state will then be to have all Pods with `v2` and workload will be balanced among the remaining 3 `v2` Pods.

Canary update achieved!

  

What to learn next
------------------



  
