How To Create Kubernetes Service Account For API Access
=======================================================

This tutorial will guide you through the process of creating the service account, role, and role binding to have API access to the kubernetes cluster

The best and recommended way to allow API access to the Kubernetes cluster is through service accounts following the **principle of least privilege** (PoLP).

Use Cases
---------

Following are the example use cases of Kubernetes service account for external API access.

1.  Allowing third-party [monitoring tools](https://devopscube.com/best-opensource-monitoring-tools/) to access Kubernetes data
2.  External applications to access kubernetes resources.

Now, why would you need this access?

Lets take an example of [Prometheus monitoring](https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/) stack.

Prometheus needs read access to cluster API to get information from metrics server, read pods, etc.

When you deploy Prometheus, you add cluster read permissions to the default service account where the Prometheus pods are deployed. This way, Prometheus pods get read access to cluster resources.

Setup Kubernetes API Access Using Service Account
-------------------------------------------------

Follow the steps given below for setting up the API access using the service account.

> _**Note:** If you are using GKE on Google Cloud, you might need to run the following two commands to add cluster-admin access to your user account for creating roles and role-bindings with your [gcloud](https://devopscube.com/setup-google-cloud-clisdk/) user._

ACCOUNT=$(gcloud info --format='value(config.account)')
kubectl create clusterrolebinding owner-cluster-admin-binding \\
    --clusterrole cluster-admin \\
    --user $ACCOUNT

Step 1: Create service account in a namespace
---------------------------------------------

We will create a service account in a custom namespace rather than the default namespace for demonstration purposes.

Create a `devops-tools` namespace.

    kubectl create namespace devops-tools

Create a service account named “`api-service-account`” in `devops-tools` namespace

kubectl create serviceaccount api-service-account -n devops-tools

or use the following manifest.

```shell
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: api-service-account
      namespace: devops-tools
    EOF
```

Step 2: Create a Cluster Role
-----------------------------

Assuming that the service account needs access to the entire cluster resources, we will create a cluster role with a list of allowed access.

Create a clusterRole named `api-cluster-role` with the following manifest file.
```shell
cat <<EOF | kubectl apply -f -
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: api-cluster-role
  namespace: devops-tools
rules:
  - apiGroups:
        - ""
        - apps
        - autoscaling
        - batch
        - extensions
        - policy
        - rbac.authorization.k8s.io
    resources:
      - pods
      - componentstatuses
      - configmaps
      - daemonsets
      - deployments
      - events
      - endpoints
      - horizontalpodautoscalers
      - ingress
      - jobs
      - limitranges
      - namespaces
      - nodes
      - pods
      - persistentvolumes
      - persistentvolumeclaims
      - resourcequotas
      - replicasets
      - replicationcontrollers
      - serviceaccounts
      - services
    verbs: \["get", "list", "watch", "create", "update", "patch", "delete"\]
EOF
```

The above YAML declaration has a `ClusterRole` with full access to all cluster resources and a role binding to “`api-service-account`“.

It is not recommended to create a service account with all cluster component access without any requirement.

To get the list of available API resources execute the following command.

```shell
    kubectl api-resources
```
Step 3: Create a CluserRole Binding
-----------------------------------

Now that we have the ClusterRole and service account, it needs to be mapped together.

Bind the `cluster-api-role` to `api-service-account` using a `RoleBinding`
```shell
    cat <<EOF | kubectl apply -f -
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: api-cluster-role-binding
    subjects:
    - namespace: devops-tools 
      kind: ServiceAccount
      name: api-service-account 
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: api-cluster-role 
    EOF
```
Step 4: Validate Service Account Access Using kubectl
-----------------------------------------------------

To validate the clusterrole binding, we can use `can-i` commands to validate the API access assuming a service account in a specific namespace.

For example, the following command checks if the `api-service-account` in the `devops-tools` namespace can list the pods.

    kubectl auth can-i get pods --as=system:serviceaccount:devops-tools:api-service-account

Here is another example, to check if the service account has permissions to delete deployments.

    kubectl auth can-i delete deployments --as=system:serviceaccount:devops-tools:api-service-account

**Step** 5: Validate Service Account Access Using API call
----------------------------------------------------------

To use a service account with an HTTP call, you need to have the token associated with the service account.

First, get the secret name associated with the `api-service-account`

kubectl get serviceaccount api-service-account  -o=jsonpath='{.secrets\[0\].name}' -n devops-tools

Use the secret name to get the base64 decoded token. It will be used as a bearer token in the API call.
```shell
kubectl get secrets  <service-account-token-name>  -o=jsonpath='{.data.token}' -n devops-tools | base64 -D
```
For example,
```shell
kubectl get secrets  api-service-account-token-pgtrr  -o=jsonpath='{.data.token}' -n devops-tools | base64 -D
```
Get the cluster endpoint to validate the API access. The following command will display the cluster endpoint (IP, DNS).

kubectl get endpoints | grep kubernetes

Now that you have the cluster endpoint and the service account token, you can test the API connectivity using the CURL or the postman app.

For example, list all the namespaces in the cluster using curl. Use the token after `Authorization: Bearer` section.
```shell
curl -k  https://35.226.193.217/api/v1/namespaces -H "Authorization: Bearer eyJhbGcisdfsdfsdfiJ9.eyJpc3MiOisdfsdfVhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3sdf3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImFwaS1zZXJ2aWNlsdfglkjoer876Y3BmNWYiLsdfsdfRlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmFwaS1zZXJ2aWNlLWFjY291bnQifQ.u5jgk2px\_lEs3f5e5lh\_UfS40fndtDKMTY5UvsdfrtsuhtgjrUj-ezrRXeLS8SLOae4DuOGGGbInSg\_gIo6oO7bLHhCixWOBJNOA5gzrLVioof\_kHDR8gH5crrsWoR-GSSsdfgsdfg6fA\_LDOqdxzqMC0WlXt6tgHfrwIHerPPvkI6NWLyCqX9tn\_akpcihd-bL6GwOKlph17l\_ND710FnTkE7kBfdXtQWWxaPPe06UEmoKK9t-0gsOCBxJxViwhHkvwqetr987q9enkadfgd\_2cY\_CA"
```
If can also try that same API call in postman.

![](https://devopscube.com/wp-content/uploads/2021/06/image.png)

The ClusterRole we created can be attached to pods/deployments as well.

You can also use the token to login to the Kubernetes dashboard.

