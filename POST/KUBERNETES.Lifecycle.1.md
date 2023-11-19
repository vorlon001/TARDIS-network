Kubernetes Pod Lifecycle Explained With Examples
================================================

In this blog, we will look at the lifecycle of a Kubernetes pod with examples and illustrations.

If you are new to the concepts of pods, please read the [Kubernetes pod](https://devopscube.com/kubernetes-pod/) blog to understand all the basics and do hands-on on creating and managing pods.

To understand the lifecycle of a pod, we will look a the following

1.  Pod Phases
2.  Pod Conditions
3.  Container Status

To understand the concepts better, let’s assume a multi-container pod with the following

1.  An init container to fetch an API secret in the runtime.
2.  container-01 (java-api) runs the **java application**
3.  container-02 (log-reader) fetches the application logs and sends them to a log forwarder.

We will understand the pod lifecycle by understanding what happens when we deploy the pod with the above requirements.

Pod Phases
----------

When you deploy a pod, it could typically fall under any one of the following phases.

Po Phases

Description

**Pending**

The Pod is created but not yet running.

**Running**

At least one container is running, or is in the process of starting or restarting.

**Succeeded**

All containers have been completed successfully.

**Failed**

At least one container has failed.

**Unknown**

The Pod status couldn’t be obtained by the API server.

Now let us understand these phases with a **real-time example** using our application pod. Let’s call our pod **java-api-pod**

Here is how the pod phases work when you deploy a pod multi-container pod.

### 1\. Pending Phase

When you deploy the api-pod, it will be in the pending phase. Before the Pod moves to the “**Running**” phase, the **init container will run to completion** before any other containers start.

Following are some of the common scenarios where a Pod continues to be in the pending stage.

1.  Lack of and CPU & Memory resources for the pod.
2.  If the pod has a volume definition and the volume is not available.
3.  If Kubernetes can’t pull the container image.
4.  If an init container fails to start

If the init container fails with a non-zero exit code and the **restartPolicy** is set to **`Never`**, the pod directly goes to the failed phase.

### 2\. Running Phase

After the init container finishes fetching the secret, the Pod moves to the “Running” phase. Both **container-01** and **container-02** will start. Because our Java application is an API that needs to be running, the Pod will stay in the “**Running**” phase as long as the Java API application is up. For some reason, if any of the containers fail to start, the pod goes to the failed phase.

### 3\. Succeeded Phase:

This phase is not applicable for our Java application, because “**Succeeded**” is for containers that complete their tasks and then exit.

Our **java-api-pod** is meant to keep running, so it won’t reach this phase unless you manually stop it.

The succeeded phase is applicable for pods that are part of Kubernetes Job/Cronjob Objects.

### 4\. **Failed Phase**

If your init container, Java application container, or the log reader container crashes or exits for some reason, the Pod will move to the “Failed” phase.

A pod moves to the failed phase in the following scenarios

1.  If the init container or main container exits with a non-zero exit code and has **restartPolicy** set to **Never**.
2.  If a node fails or a pod is evicted from a node and can’t be moved to another node, it moves to a failed state.
3.  If a pod has **activeDeadlineSeconds** (Typically on [Jobs & Cronjobs](https://devopscube.com/create-kubernetes-jobs-cron-jobs/)) field enabled and it exceeds the time limits, the pod gets terminated and marked as Failed.
4.  If you manually delete the pod and it can’t gracefully terminate, the pod moves to a failed state.

### 5\. Unknown Phase

This is rare, but if the api-server can’t get the status of your Pod for some reason, it will be marked as “Unknown.”

Pod Conditions
--------------

The pod’s phase gives a brief update on the pod’s current status as **Pod conditions** give you detailed information related to scheduling, readiness, and initialization.

If you describe a pod, you will see the conditions section as shown below. The conditions are part of the **`PodStatus`** object.