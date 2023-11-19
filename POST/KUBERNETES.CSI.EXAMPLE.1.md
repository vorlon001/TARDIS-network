Kube-Bench: Kubernetes CIS Benchmarking Tool
============================================


What is the **CIS Kubernetes benchmark**?
-----------------------------------------

> CIS Benchmark is the product of a community consensus process and consists of secure configuration guidelines developed for Kubernetes
> 
> cisecurity.org

Kubernetes CIS benchmarks cover security guidelines & recommendations for the following

1.  **Control Plane Components**: Control plane node configurations & component recommendations.
2.  **Worker Nodes:** Worker node configurations and Kubelet.
3.  **Policies:** RBAC, service accounts, Pod security standards, CNI and network policies, Secret Management, etc.

The following image shows the example list of CIS guidelines for the Kubernetes API server.

[![kube-bench Kubernetes CIS benchmarks](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20viewBox='0%200%20645%20603'%3E%3C/svg%3E)<br>![kube-bench Kubernetes CIS benchmarks](https://devopscube.com/wp-content/uploads/2023/02/image-8-1024x958.png)](https://devopscube.com/wp-content/uploads/2023/02/image-8.png)

What is Kube-bench?
-------------------

Kube-bench is an open-source tool to assess the security of Kubernetes clusters by running checks against the Center for Internet Security [(CIS) Kubernetes benchmark.](https://www.cisecurity.org/benchmark/kubernetes) It was developed in **GoLang** by [Aqua Security](https://www.aquasec.com/), a provider of cloud-native security solutions.

Kube-bench can help with the following.

1.  **Cluster hardening:** Kube-bench automates the process of checking the cluster configuration as per the security guidelines outlined in CIS benchmarks.
2.  **Policy Enforcement:** Kube-bech checks for RBAC configuration to ensure the necessary least privileges are applied to service accounts, users, etc. it also checks for pod security standards and secret management.
3.  **Network segmentation:** Kube-bench checks for CNI and its support for network policy to ensure that network policies are defined for all namespaces.

When it comes to the use of kube-bench by organizations, a [security survey](https://developers.redhat.com/e-books/2022-state-kubernetes-security-report) conducted by Red Hat found that 24% of the respondents use it.

![Kube-bench usage by organizations](https://devopscube.com/wp-content/uploads/2023/02/image-2.png)

Image Source: redhat.com

You can run kube-bench checks against a cluster in two ways.

1.  From the command line using kube-bench CLI
2.  Run inside a pod

Let’s look at both options.

Running Kube-bench From Command Line
------------------------------------

If you are preparing for [CKS certification](https://devopscube.com/cks-exam-guide-tips/), running kube-bench from the command line is one of the important tasks.

> **Note:** This method will only work if you have access to the control plane node. If you are utilizing a managed Kubernetes service, you can run kube-bench as a pod, as explained in the following section.

**Step 1:** Log in to the control plane(master) node and create a kube-bench directory

    sudo mkdir -p /opt/kube-bench

**Step 2:** Go to the [kube-bench releases](https://github.com/aquasecurity/kube-bench/releases) page and choose the latest Linux binary link.
```
    curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.6.11/kube-bench_0.6.11_linux_amd64.tar.gz -o /opt/kube-bench.tar.gz
```
**Step 3:** Untar the binary to **`/opt/kube-bench`** folder
```
    tar -xvf kube-bench.tar.gz -C /opt/kube-bench
```
If you check the **`/opt/kube-bench`** directory, You will see the **`kube-bench`** executable and **`cfg`** folder that contains the benchmark variations for different versions and versions of managed kubernetes services **GKE, EKS, AKS, etc** as shown in the following tree structure.
```
    vagrant@master-node:~$ tree
    .
    ├── cfg
    │   ├── ack-1.0
    │   │   ├── config.yaml
    │   │   ├── controlplane.yaml
    │   │   ├── etcd.yaml
    │   │   ├── managedservices.yaml
    │   │   ├── master.yaml
    │   │   ├── node.yaml
    │   │   └── policies.yaml
    │   ├── aks-1.0
    │   │   ├── config.yaml
    │   │   ├── controlplane.yaml
    │   │   ├── managedservices.yaml
    │   │   ├── master.yaml
    │   │   ├── node.yaml
    │   │   └── policies.yaml
    │   ├── cis-1.6-k3s
    │   │   ├── config.yaml
    │   │   ├── controlplane.yaml
    │   │   ├── etcd.yaml
    │   │   ├── master.yaml
    │   │   ├── node.yaml
    │   │   └── policies.yaml
    │   ├── config.yaml
    │   ├── eks-stig-kubernetes-v1r6
    │   │   ├── config.yaml
    │   │   ├── controlplane.yaml
    │   │   ├── managedservices.yaml
    │   │   ├── master.yaml
    │   │   ├── node.yaml
    │   │   └── policies.yaml
    │   ├── gke-1.2.0
    │   │   ├── config.yaml
    │   │   ├── controlplane.yaml
    │   │   ├── managedservices.yaml
    │   │   ├── master.yaml
    │   │   ├── node.yaml
    │   │   └── policies.yaml
    │   └── rh-1.0
    │       ├── config.yaml
    │       ├── controlplane.yaml
    │       ├── etcd.yaml
    │       ├── master.yaml
    │       ├── node.yaml
    │       └── policies.yaml
    ├── kube-bench
```
**Step 4:** Move the kube-bench executable to the `**/usr/local/bin**` directory that is part of the system PATH
```
    sudo mv /opt/kube-bench/kube-bench /usr/local/bin/
```
Now you can execute `kube-bench` from any system location.

**Step 4:** Let’s run the benchmark checks using **kube-bench** executable. We will be using the generic **config.yaml** to run the benchmarks using the following command. You have to run the command as sudo.
```
    sudo kube-bench --config-dir /opt/kube-bench/cfg --config /opt/kube-bench/cfg/config.yaml
```
The above command will run the benchmarks checks and creates the summary of checks, remediation, and summary as shown below.

    # Checks Example
    [INFO] 1 Control Plane Security Configuration
    [INFO] 1.1 Control Plane Node Configuration Files
    [PASS] 1.1.1 Ensure that the API server pod specification file permissions are set to 644 or more restrictive (Automated)
    [PASS] 1.1.2 Ensure that the API server pod specification file ownership is set to root:root (Automated)
    
    # Remediations Example
    == Remediations master ==
    1.1.9 Run the below command (based on the file location on your system) on the control plane node.
    For example, chmod 600 <path/to/cni/files>
    1.1.12 On the etcd server node, get the etcd data directory, passed as an argument --data-dir,
    from the command 'ps -ef | grep etcd'.
    
    # Summary Example
    == Summary master ==
    41 checks PASS
    9 checks FAIL
    11 checks WARN
    0 checks INFO

If you want the report in a separate file, you can direct the output to a file as shown below.
```
    sudo kube-bench --config-dir /opt/kube-bench/cfg --config /opt/kube-bench/cfg/config.yaml > kube-bench.report
```
![kube-bench CIS benchmark scan report](https://devopscube.com/wp-content/uploads/2023/02/image-6.png)

### Installing Kube-bench From Package

You can also install and run kube-bench using Linux packages. On the releases page, you will find both **`.deb`** and **`.rpm`** packages.

For example, to install on Debian/Ubuntu systems, you can execute the following commands.
```
    curl -L  https://github.com/aquasecurity/kube-bench/releases/download/v0.6.11/kube-bench_0.6.11_linux_amd64.deb -o kube-bench.deb
    
    sudo dpkg -i  kube-bench.deb
```
After the installation, you can find the kube-bench cfg folder in the `**/etc/kube-bench/**` directory.

Also, you can run the kube-bench checks without providing the config directory parameters as we did in the binary installation. By default, **`kube-bench`** refers the **`/etc/kube-bench/cfg`** directory.

To run the checks execute the following command.
```
    sudo kube-bench
```
Running Kube-bench In a Pod
---------------------------

Another method to run **`kube-bench`** is by deploying it as a **[Kubernetes job](https://devopscube.com/create-kubernetes-jobs-cron-jobs/) pod**. This method is particularly useful for running CIS benchmarks on managed Kubernetes clusters where root access to the control plane or worker nodes is not available.
```
    kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
```
Or if you want to modify the YAML, you can download it to a file and then apply it
```
    curl https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml > job.yaml

    kubectl apply -f job.yaml
```
Then kube-bench report will be available in the pod logs. First List the pod
```
    kubectl get pods
```
Now use the pod name to get the logs. Replace `kube-bench-4j2bs` with your pod name.
```
    kubectl logs kube-bench-4j2bs
```
You can also export the kube-bench log to a file
```
    kubectl logs kube-bench-4j2bs > kube-bench.report
```
Kube-bench Possible Errors
--------------------------

    unable to determine benchmark version: config file is missing 'version_mapping' sectio

If you run the **`kube-bench`** command without providing the **`--config-dir`** and **`--config`** parameters, you will get the above error.

Kube-bench for Managed Kubernetes Clusters (GKE, EKS, AKS etc)
--------------------------------------------------------------

If you look at managed Kubernetes services like GKE, EKS, or AKS, you don’t get access to the control plane node to install the kube-bench utility.

All managed kubernetes services follow the shared responsibility model where the Cloud providers take care of control plane availability and security and the user needs to take care of security in terms of users, policies, etc.

Also, when you deploy the pod, it gets scheduled on a node and Kube-bench figures out that only kubelet is running on that node and it runs the checks accordingly. Meaning, it runs the tests for worker nodes. If you schedule the pod to be in the control plane, it runs all the checks required for the control plane.

kube-bench Alternatives
-----------------------

If you are looking for open-source alternatives for kube-bench to run CIS benchmarks, you can look at the following two tools.

1.  Checkov
2.  KubeScape
