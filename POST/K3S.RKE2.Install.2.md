
```shell
curl -sfL https://get.rke2.io --output install.sh
chmod +x install.sh

## Installation
## The installation process defaults to the latest RKE2 version and no other qualifiers are necessary. However, if you want to specify a version, you should set the INSTALL_RKE2_CHANNEL environment variable. An example below:

INSTALL_RKE2_CHANNEL=latest ./install.sh

```



Configuration File
The primary way to configure RKE2 is through its config file. Command line arguments and environment variables are also available, but RKE2 is installed as a systemd service and thus these are not as easy to leverage.

By default, RKE2 will launch with the values present in the YAML file located at /etc/rancher/rke2/config.yaml.

NOTE
The RKE2 config file needs to be created manually. You can do that by running touch /etc/rancher/rke2/config.yaml as a privileged user.

An example of a basic server config file is below:

```yaml
write-kubeconfig-mode: "0644"
tls-san:
  - "foo.local"
node-label:
  - "foo=bar"
  - "something=amazing"
debug: true
```
##   --system-default-registry value               (image) Private registry to be used for all system images [$RKE2_SYSTEM_DEFAULT_REGISTRY]
##   --kube-apiserver-image value                  (image) Override image to use for kube-apiserver [$RKE2_KUBE_APISERVER_IMAGE]
##   --kube-controller-manager-image value         (image) Override image to use for kube-controller-manager [$RKE2_KUBE_CONTROLLER_MANAGER_IMAGE]
##   --kube-proxy-image value                      (image) Override image to use for kube-proxy [$RKE2_KUBE_PROXY_IMAGE]
##   --kube-scheduler-image value                  (image) Override image to use for kube-scheduler [$RKE2_KUBE_SCHEDULER_IMAGE]
##   --pause-image value                           (image) Override image to use for pause [$RKE2_PAUSE_IMAGE]
##   --runtime-image value                         (image) Override image to use for runtime binaries (containerd, kubectl, crictl, etc) [$RKE2_RUNTIME_IMAGE]
##   --etcd-image value                            (image) Override image to use for etcd [$RKE2_ETCD_IMAGE]
##   --profile value                               (security) Validate system configuration against the selected benchmark (valid items: cis-1.6, cis-1.23 ) [$RKE2_CIS_PROFILE]
##   --audit-policy-file value                     (security) Path to the file that defines the audit policy configuration [$RKE2_AUDIT_POLICY_FILE]

```images

IMAGE
IMAGE:TAG
docker.io/rancher/hardened-cluster-autoscaler:v1.8.6-build20230406
docker.io/rancher/hardened-cni-plugins:v1.0.1-build20221011
docker.io/rancher/hardened-coredns:v1.10.1-build20230406
docker.io/rancher/hardened-etcd:v3.5.7-k3s1-build20230406
docker.io/rancher/hardened-k8s-metrics-server:v0.6.3-build20230515
docker.io/rancher/hardened-kubernetes:v1.25.12-rke2r1-build20230719
docker.io/rancher/klipper-helm:v0.8.0-build20230510
docker.io/rancher/mirrored-cilium-cilium:v1.13.2
docker.io/rancher/mirrored-cilium-operator-aws:v1.13.2
docker.io/rancher/mirrored-ingress-nginx-kube-webhook-certgen:v20230312-helm-chart-4.5.2-28-g66a760794
docker.io/rancher/mirrored-sig-storage-snapshot-controller:v6.2.1
docker.io/rancher/mirrored-sig-storage-snapshot-validation-webhook:v6.2.1
docker.io/rancher/nginx-ingress-controller:nginx-1.7.1-hardened1
docker.io/rancher/pause:3.6
docker.io/rancher/rke2-cloud-provider:v1.26.3-build20230406

IMAGE                                                                TAG                                        IMAGE ID            SIZE
docker.io/rancher/hardened-cluster-autoscaler                        v1.8.6-build20230406                       e8ce8d527364d       58.2MB
docker.io/rancher/hardened-cni-plugins                               v1.0.1-build20221011                       ffd07315c2646       78.7MB
docker.io/rancher/hardened-coredns                                   v1.10.1-build20230406                      3c8207b045e32       64.3MB
docker.io/rancher/hardened-etcd                                      v3.5.7-k3s1-build20230406                  045ce52ecd52c       64.4MB
docker.io/rancher/hardened-k8s-metrics-server                        v0.6.3-build20230515                       9d8f4a693c64c       62.7MB
docker.io/rancher/hardened-kubernetes                                v1.25.12-rke2r1-build20230719              c9ce397e74f9e       214MB
docker.io/rancher/klipper-helm                                       v0.8.0-build20230510                       6f42df210d7fa       95MB
docker.io/rancher/mirrored-cilium-cilium                             v1.13.2                                    2480b5e5b4799       174MB
docker.io/rancher/mirrored-cilium-operator-aws                       v1.13.2                                    01e5959692a4f       26.2MB
docker.io/rancher/mirrored-ingress-nginx-kube-webhook-certgen        v20230312-helm-chart-4.5.2-28-g66a760794   5a86b03a88d23       20.1MB
docker.io/rancher/mirrored-sig-storage-snapshot-controller           v6.2.1                                     1ef6c138bd5f2       24.2MB
docker.io/rancher/mirrored-sig-storage-snapshot-validation-webhook   v6.2.1                                     46e6854cb7c5e       21MB
docker.io/rancher/nginx-ingress-controller                           nginx-1.7.1-hardened1                      05fbbb9f7b895       336MB
docker.io/rancher/pause                                              3.6                                        6270bb605e12e       299kB
docker.io/rancher/rke2-cloud-provider                                v1.26.3-build20230406                      f906d1e7a5774       63.7MB

```

```shell

RKE2 Server CLI Help
If an option appears in brackets below, for example [$RKE2_TOKEN], it means that the option can be passed in as an environment variable of that name.

NAME:
   rke2 server - Run management server

USAGE:
   rke2 server [OPTIONS]

OPTIONS:
   --config FILE, -c FILE                        (config) Load configuration from FILE (default: "/etc/rancher/rke2/config.yaml") [$RKE2_CONFIG_FILE]
   --debug                                       (logging) Turn on debug logs [$RKE2_DEBUG]
   --bind-address value                          (listener) rke2 bind address (default: 0.0.0.0)
   --advertise-address value                     (listener) IPv4 address that apiserver uses to advertise to members of the cluster (default: node-external-ip/node-ip)
   --tls-san value                               (listener) Add additional hostnames or IPv4/IPv6 addresses as Subject Alternative Names on the server TLS cert
   --data-dir value, -d value                    (data) Folder to hold state (default: "/var/lib/rancher/rke2")
   --cluster-cidr value                          (networking) IPv4/IPv6 network CIDRs to use for pod IPs (default: 10.42.0.0/16)
   --service-cidr value                          (networking) IPv4/IPv6 network CIDRs to use for service IPs (default: 10.43.0.0/16)
   --service-node-port-range value               (networking) Port range to reserve for services with NodePort visibility (default: "30000-32767")
   --cluster-dns value                           (networking) IPv4 Cluster IP for coredns service. Should be in your service-cidr range (default: 10.43.0.10)
   --cluster-domain value                        (networking) Cluster Domain (default: "cluster.local")
   --token value, -t value                       (cluster) Shared secret used to join a server or agent to a cluster [$RKE2_TOKEN]
   --token-file value                            (cluster) File containing the cluster-secret/token [$RKE2_TOKEN_FILE]
   --write-kubeconfig value, -o value            (client) Write kubeconfig for admin client to this file [$RKE2_KUBECONFIG_OUTPUT]
   --write-kubeconfig-mode value                 (client) Write kubeconfig with this mode [$RKE2_KUBECONFIG_MODE]
   --kube-apiserver-arg value                    (flags) Customized flag for kube-apiserver process
   --etcd-arg value                              (flags) Customized flag for etcd process
   --kube-controller-manager-arg value           (flags) Customized flag for kube-controller-manager process
   --kube-scheduler-arg value                    (flags) Customized flag for kube-scheduler process
   --etcd-expose-metrics                         (db) Expose etcd metrics to client interface. (Default false)
   --etcd-disable-snapshots                      (db) Disable automatic etcd snapshots
   --etcd-snapshot-name value                    (db) Set the base name of etcd snapshots. Default: etcd-snapshot-<unix-timestamp> (default: "etcd-snapshot")
   --etcd-snapshot-schedule-cron value           (db) Snapshot interval time in cron spec. eg. every 5 hours '0 */5 * * *' (default: "0 */12 * * *")
   --etcd-snapshot-retention value               (db) Number of snapshots to retain Default: 5 (default: 5)
   --etcd-snapshot-dir value                     (db) Directory to save db snapshots. (Default location: ${data-dir}/db/snapshots)
   --etcd-s3                                     (db) Enable backup to S3
   --etcd-s3-endpoint value                      (db) S3 endpoint url (default: "s3.amazonaws.com")
   --etcd-s3-endpoint-ca value                   (db) S3 custom CA cert to connect to S3 endpoint
   --etcd-s3-skip-ssl-verify                     (db) Disables S3 SSL certificate validation
   --etcd-s3-access-key value                    (db) S3 access key [$AWS_ACCESS_KEY_ID]
   --etcd-s3-secret-key value                    (db) S3 secret key [$AWS_SECRET_ACCESS_KEY]
   --etcd-s3-bucket value                        (db) S3 bucket name
   --etcd-s3-region value                        (db) S3 region / bucket location (optional) (default: "us-east-1")
   --etcd-s3-folder value                        (db) S3 folder
   --disable value                               (components) Do not deploy packaged components and delete any deployed components (valid items: rke2-coredns, rke2-ingress-nginx, rke2-metrics-server)
   --disable-scheduler                           (components) Disable Kubernetes default scheduler
   --disable-cloud-controller                    (components) Disable rke2 default cloud controller manager
   --disable-kube-proxy                          (components) Disable running kube-proxy
   --node-name value                             (agent/node) Node name [$RKE2_NODE_NAME]
   --node-label value                            (agent/node) Registering and starting kubelet with set of labels
   --node-taint value                            (agent/node) Registering kubelet with set of taints
   --image-credential-provider-bin-dir value     (agent/node) The path to the directory where credential provider plugin binaries are located (default: "/var/lib/rancher/credentialprovider/bin")
   --image-credential-provider-config value      (agent/node) The path to the credential provider plugin config file (default: "/var/lib/rancher/credentialprovider/config.yaml")
   --container-runtime-endpoint value            (agent/runtime) Disable embedded containerd and use alternative CRI implementation
   --snapshotter value                           (agent/runtime) Override default containerd snapshotter (default: "overlayfs")
   --private-registry value                      (agent/runtime) Private registry configuration file (default: "/etc/rancher/rke2/registries.yaml")
   --node-ip value, -i value                     (agent/networking) IPv4/IPv6 addresses to advertise for node
   --node-external-ip value                      (agent/networking) IPv4/IPv6 external IP addresses to advertise for node
   --resolv-conf value                           (agent/networking) Kubelet resolv.conf file [$RKE2_RESOLV_CONF]
   --kubelet-arg value                           (agent/flags) Customized flag for kubelet process
   --kube-proxy-arg value                        (agent/flags) Customized flag for kube-proxy process
   --protect-kernel-defaults                     (agent/node) Kernel tuning behavior. If set, error if kernel tunables are different than kubelet defaults.
   --agent-token value                           (experimental/cluster) Shared secret used to join agents to the cluster, but not servers [$RKE2_AGENT_TOKEN]
   --agent-token-file value                      (experimental/cluster) File containing the agent secret [$RKE2_AGENT_TOKEN_FILE]
   --server value, -s value                      (experimental/cluster) Server to connect to, used to join a cluster [$RKE2_URL]
   --cluster-reset                               (experimental/cluster) Forget all peers and become sole member of a new cluster [$RKE2_CLUSTER_RESET]
   --cluster-reset-restore-path value            (db) Path to snapshot file to be restored
   --system-default-registry value               (image) Private registry to be used for all system images [$RKE2_SYSTEM_DEFAULT_REGISTRY]
   --selinux                                     (agent/node) Enable SELinux in containerd [$RKE2_SELINUX]
   --lb-server-port value                        (agent/node) Local port for supervisor client load-balancer. If the supervisor and apiserver are not colocated an additional port 1 less than this port will also be used for the apiserver client load-balancer. (default: 6444) [$RKE2_LB_SERVER_PORT]
   --cni value                                   (networking) CNI Plugins to deploy, one of none, calico, canal, cilium; optionally with multus as the first value to enable the multus meta-plugin (default: canal) [$RKE2_CNI]
   --kube-apiserver-image value                  (image) Override image to use for kube-apiserver [$RKE2_KUBE_APISERVER_IMAGE]
   --kube-controller-manager-image value         (image) Override image to use for kube-controller-manager [$RKE2_KUBE_CONTROLLER_MANAGER_IMAGE]
   --kube-proxy-image value                      (image) Override image to use for kube-proxy [$RKE2_KUBE_PROXY_IMAGE]
   --kube-scheduler-image value                  (image) Override image to use for kube-scheduler [$RKE2_KUBE_SCHEDULER_IMAGE]
   --pause-image value                           (image) Override image to use for pause [$RKE2_PAUSE_IMAGE]
   --runtime-image value                         (image) Override image to use for runtime binaries (containerd, kubectl, crictl, etc) [$RKE2_RUNTIME_IMAGE]
   --etcd-image value                            (image) Override image to use for etcd [$RKE2_ETCD_IMAGE]
   --kubelet-path value                          (experimental/agent) Override kubelet binary path [$RKE2_KUBELET_PATH]
   --cloud-provider-name value                   (cloud provider) Cloud provider name [$RKE2_CLOUD_PROVIDER_NAME]
   --cloud-provider-config value                 (cloud provider) Cloud provider configuration file path [$RKE2_CLOUD_PROVIDER_CONFIG]
   --profile value                               (security) Validate system configuration against the selected benchmark (valid items: cis-1.6, cis-1.23 ) [$RKE2_CIS_PROFILE]
   --audit-policy-file value                     (security) Path to the file that defines the audit policy configuration [$RKE2_AUDIT_POLICY_FILE]
   --control-plane-resource-requests value       (components) Control Plane resource requests [$RKE2_CONTROL_PLANE_RESOURCE_REQUESTS]
   --control-plane-resource-limits value         (components) Control Plane resource limits [$RKE2_CONTROL_PLANE_RESOURCE_LIMITS]
   --kube-apiserver-extra-mount value            (components) kube-apiserver extra volume mounts [$RKE2_KUBE_APISERVER_EXTRA_MOUNT]
   --kube-scheduler-extra-mount value            (components) kube-scheduler extra volume mounts [$RKE2_KUBE_SCHEDULER_EXTRA_MOUNT]
   --kube-controller-manager-extra-mount value   (components) kube-controller-manager extra volume mounts [$RKE2_KUBE_CONTROLLER_MANAGER_EXTRA_MOUNT]
   --kube-proxy-extra-mount value                (components) kube-proxy extra volume mounts [$RKE2_KUBE_PROXY_EXTRA_MOUNT]
   --etcd-extra-mount value                      (components) etcd extra volume mounts [$RKE2_ETCD_EXTRA_MOUNT]
   --cloud-controller-manager-extra-mount value  (components) cloud-controller-manager extra volume mounts [$RKE2_CLOUD_CONTROLLER_MANAGER_EXTRA_MOUNT]
   --kube-apiserver-extra-env value              (components) kube-apiserver extra environment variables [$RKE2_KUBE_APISERVER_EXTRA_ENV]
   --kube-scheduler-extra-env value              (components) kube-scheduler extra environment variables [$RKE2_KUBE_SCHEDULER_EXTRA_ENV]
   --kube-controller-manager-extra-env value     (components) kube-controller-manager extra environment variables [$RKE2_KUBE_CONTROLLER_MANAGER_EXTRA_ENV]
   --kube-proxy-extra-env value                  (components) kube-proxy extra environment variables [$RKE2_KUBE_PROXY_EXTRA_ENV]
   --etcd-extra-env value                        (components) etcd extra environment variables [$RKE2_ETCD_EXTRA_ENV]
   --cloud-controller-manager-extra-env value    (components) cloud-controller-manager extra environment variables [$RKE2_CLOUD_CONTROLLER_MANAGER_EXTRA_ENV]```

```


```shell
RKE2 Agent CLI Help
If an option appears in brackets below, for example [$RKE2_URL], it means that the option can be passed in as an environment variable of that name.

NAME:
   rke2 agent - Run node agent

USAGE:
   rke2 agent command [command options] [arguments...]

COMMANDS:


OPTIONS:
   --config FILE, -c FILE                        (config) Load configuration from FILE (default: "/etc/rancher/rke2/config.yaml") [$RKE2_CONFIG_FILE]
   --debug                                       (logging) Turn on debug logs [$RKE2_DEBUG]
   --token value, -t value                       (cluster) Token to use for authentication [$RKE2_TOKEN]
   --token-file value                            (cluster) Token file to use for authentication [$RKE2_TOKEN_FILE]
   --server value, -s value                      (cluster) Server to connect to [$RKE2_URL]
   --data-dir value, -d value                    (data) Folder to hold state (default: "/var/lib/rancher/rke2")
   --node-name value                             (agent/node) Node name [$RKE2_NODE_NAME]
   --node-label value                            (agent/node) Registering and starting kubelet with set of labels
   --node-taint value                            (agent/node) Registering kubelet with set of taints
   --image-credential-provider-bin-dir value     (agent/node) The path to the directory where credential provider plugin binaries are located (default: "/var/lib/rancher/credentialprovider/bin")
   --image-credential-provider-config value      (agent/node) The path to the credential provider plugin config file (default: "/var/lib/rancher/credentialprovider/config.yaml")
   --container-runtime-endpoint value            (agent/runtime) Disable embedded containerd and use alternative CRI implementation
   --snapshotter value                           (agent/runtime) Override default containerd snapshotter (default: "overlayfs")
   --private-registry value                      (agent/runtime) Private registry configuration file (default: "/etc/rancher/rke2/registries.yaml")
   --node-ip value, -i value                     (agent/networking) IPv4/IPv6 addresses to advertise for node
   --node-external-ip value                      (agent/networking) IPv4/IPv6 external IP addresses to advertise for node
   --resolv-conf value                           (agent/networking) Kubelet resolv.conf file [$RKE2_RESOLV_CONF]
   --kubelet-arg value                           (agent/flags) Customized flag for kubelet process
   --kube-proxy-arg value                        (agent/flags) Customized flag for kube-proxy process
   --protect-kernel-defaults                     (agent/node) Kernel tuning behavior. If set, error if kernel tunables are different than kubelet defaults.
   --selinux                                     (agent/node) Enable SELinux in containerd [$RKE2_SELINUX]
   --lb-server-port value                        (agent/node) Local port for supervisor client load-balancer. If the supervisor and apiserver are not colocated an additional port 1 less than this port will also be used for the apiserver client load-balancer. (default: 6444) [$RKE2_LB_SERVER_PORT]
   --kube-apiserver-image value                  (image) Override image to use for kube-apiserver [$RKE2_KUBE_APISERVER_IMAGE]
   --kube-controller-manager-image value         (image) Override image to use for kube-controller-manager [$RKE2_KUBE_CONTROLLER_MANAGER_IMAGE]
   --kube-proxy-image value                      (image) Override image to use for kube-proxy [$RKE2_KUBE_PROXY_IMAGE]
   --kube-scheduler-image value                  (image) Override image to use for kube-scheduler [$RKE2_KUBE_SCHEDULER_IMAGE]
   --pause-image value                           (image) Override image to use for pause [$RKE2_PAUSE_IMAGE]
   --runtime-image value                         (image) Override image to use for runtime binaries (containerd, kubectl, crictl, etc) [$RKE2_RUNTIME_IMAGE]
   --etcd-image value                            (image) Override image to use for etcd [$RKE2_ETCD_IMAGE]
   --kubelet-path value                          (experimental/agent) Override kubelet binary path [$RKE2_KUBELET_PATH]
   --cloud-provider-name value                   (cloud provider) Cloud provider name [$RKE2_CLOUD_PROVIDER_NAME]
   --cloud-provider-config value                 (cloud provider) Cloud provider configuration file path [$RKE2_CLOUD_PROVIDER_CONFIG]
   --profile value                               (security) Validate system configuration against the selected benchmark (valid items: cis-1.6, cis-1.23 ) [$RKE2_CIS_PROFILE]
   --audit-policy-file value                     (security) Path to the file that defines the audit policy configuration [$RKE2_AUDIT_POLICY_FILE]
   --control-plane-resource-requests value       (components) Control Plane resource requests [$RKE2_CONTROL_PLANE_RESOURCE_REQUESTS]
   --control-plane-resource-limits value         (components) Control Plane resource limits [$RKE2_CONTROL_PLANE_RESOURCE_LIMITS]
   --kube-apiserver-extra-mount value            (components) kube-apiserver extra volume mounts [$RKE2_KUBE_APISERVER_EXTRA_MOUNT]
   --kube-scheduler-extra-mount value            (components) kube-scheduler extra volume mounts [$RKE2_KUBE_SCHEDULER_EXTRA_MOUNT]
   --kube-controller-manager-extra-mount value   (components) kube-controller-manager extra volume mounts [$RKE2_KUBE_CONTROLLER_MANAGER_EXTRA_MOUNT]
   --kube-proxy-extra-mount value                (components) kube-proxy extra volume mounts [$RKE2_KUBE_PROXY_EXTRA_MOUNT]
   --etcd-extra-mount value                      (components) etcd extra volume mounts [$RKE2_ETCD_EXTRA_MOUNT]
   --cloud-controller-manager-extra-mount value  (components) cloud-controller-manager extra volume mounts [$RKE2_CLOUD_CONTROLLER_MANAGER_EXTRA_MOUNT]
   --kube-apiserver-extra-env value              (components) kube-apiserver extra environment variables [$RKE2_KUBE_APISERVER_EXTRA_ENV]
   --kube-scheduler-extra-env value              (components) kube-scheduler extra environment variables [$RKE2_KUBE_SCHEDULER_EXTRA_ENV]
   --kube-controller-manager-extra-env value     (components) kube-controller-manager extra environment variables [$RKE2_KUBE_CONTROLLER_MANAGER_EXTRA_ENV]
   --kube-proxy-extra-env value                  (components) kube-proxy extra environment variables [$RKE2_KUBE_PROXY_EXTRA_ENV]
   --etcd-extra-env value                        (components) etcd extra environment variables [$RKE2_ETCD_EXTRA_ENV]
   --cloud-controller-manager-extra-env value    (components) cloud-controller-manager extra environment variables [$RKE2_CLOUD_CONTROLLER_MANAGER_EXTRA_ENV]
   --help, -h                                    show help
```
