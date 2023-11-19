Kuztomize Secret & Configmap Generators \[Practical Examples\]
==============================================================

 ![Kuztomize Secret & Configmap Generators](https://devopscube.com/wp-content/uploads/2023/06/Configmap-Generator.png)](https://devopscube.com/wp-content/uploads/2023/06/Configmap-Generator.png)


In this guide, we will look at how to generate Kubernetes Configmaps and Secrets using Kustomize.

If you are new to Kustomize, please check out the [Kustomize tutorial](https://devopscube.com/kustomize-tutorial/) to learn the basics.

Configmap & Secret Generator Use Case
-------------------------------------

Before looking into how a secret/config generator works, let’s understand what problem it solves.

When you update a configmap attached to a pod as a volume, the configmap data gets propagated to the pod automatically. However, the **pod does not get the latest data** in the configmap in the following scenarios.

1.  If the pod gets environment variables from the configmap.
2.  If the configmap is mounted as a volume using a subpath.

In the above cases, the pod will continue using the old configmap data until we restart the pod. Because the **pod is unaware** of what got changed in configMap.

Essentially, the data from the ConfigMaps (such as properties, environment variables, etc.) is **used by applications during their startup**. So even if the updated configmap data is projected to the pod, if the application running inside the pod doesn’t have any **hot reload mechanism**, you will have to restart the pod for the changes to take place.

What options do we have to solve this issue?

1.  You can use [Reloader](https://github.com/stakater/Reloader) Controller.
2.  Using Kustomize ConfigMap Generator

If you already use Kustomize for [Kubernetes Deployments](https://devopscube.com/kubernetes-deployment-tutorial/) or planning to use it, there is no need for any extra controllers to take care of Configmap rollouts.

Kustomize Configmap & Secret Generator
--------------------------------------

Here is how the Kustoimize Configmap/Secret generator work.

1.  Kustomize generator creates a configMap and Secret with a unique name(hash) at the end. For example, if the name of the configmap is **app-configmap**, the generated one would have the name **app-configmap-7b58b6ct6d**. Here **7b58b6ct6d** is the appended hash.
2.  If you update the configmap/Secret, it will **create a new configMap/Secret** with the same name with a different hash(random sets of characters) at the end.
3.  Kustomize will **automatically update** the Deployment with the new configmap name.
4.  The moment Deployment is updated by Kustomize, a **rollout will be triggered** and the application runs on the pod and gets the updated configmap/secret data. In this way, we don’t need to redeploy or restart the deployment.

The following image shows the Configmap create and update workflow with changes in hash during create and update stages.

![](https://devopscube.com/wp-content/uploads/2023/06/image-36.png)

Following are the important points you should know about the Kustomize generators.

1.  Since Kustomize creates a new configmap every time there is an update, you need to **garbage-collect your old orphaned Configmaps**. If you have resource quota limits set for namespace, orphaned Configmaps could be an issue. Or you should use the **–prune** flag with labels in the **kubectl apply** command. Also, GitOps tools like **ArgoCD** offer Orphaned resource monitoring mechanisms.
2.  You can use the `disableNameSuffixHash: true` flag to disable creating new Configmaps on every update, but it does not trigger a pod rollout. You need to manually trigger a rollout for pods to get the latest configmap data. Or the application running inside the pod should have a hot-reload mechanism.

Now let’s look at practically how to use Configmap and Secret Generators.

Generate Configmap Using Kustomize
----------------------------------

We will look at an Nginx example where it uses a configmap content for its index.html

> Note: The base and overlay YAMLs are part of the [Kustomize Github repo](https://github.com/techiescamp/kustomize). Clone the repo to follow along the tutorial

Here is the file structure of the repository. To understand the generators, we will use the generators overlay folder.

    ├── base
    │   ├── deployment.yaml
    │   ├── kustomization.yaml
    │   └── service.yaml
    └── overlays
        ├── dev
        │   ├── deployment-dev.yaml
        │   ├── kustomization.yaml
        │   └── service-dev.yaml
        ├── generators
        │   ├── deployment.yaml
        │   ├── files
        │   │   └── index.html
        │   ├── kustomization.yaml
        │   └── service.yaml
        └── prod
            ├── deployment-prod.yaml
            ├── kustomization.yaml
            └── service-prod.yaml

**`generators/deployment.yaml`**

Here is the Overlay nginx **`deployment.yaml`** that uses a configmap named `**index-html-configmap**` mounted as a volume and **env variable** derived from a configmap named **`endpoint-configmap`**. I have highlighted the configs in bold.

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: web-deployment
    spec:
      replicas: 3
      template:
        spec:
          containers:
          - name: nginx
            resources:
              limits:
                cpu: "200m"
                memory: "256Mi"
              requests:
                cpu: "100m"
                memory: "128Mi"
            env:
            - name: ENDPOINT
              valueFrom:
                configMapKeyRef:
                  name: endpoint-configmap
                  key: endpoint
            volumeMounts:
            - name: nginx-index-file
              mountPath: /usr/share/nginx/html/
          volumes:
          - name: nginx-index-file
            configMap:
              name: index-html-configmap

**`files/index.html`**

We have the configmap file content in the index.html file under the files directory

    <html>
        <h1>Welcome</h1>
        </br>
        <h1>Hi! This is the Configmap Index file </h1>
        </html

**`generators/kustomization.yaml`**

The configmap generation options should be added to the **`kustomization.yaml`** file under **configMapGenerator** field.

In this example, we are generating two types of Configmaps.

1.  Configmap from a file (index.html) that will be mounted to the nginx **/usr/share/nginx/html/** directory.
2.  Configmap from literals, that will set an environment variable named **ENDPOINTS**

Under **generatorOptions** field, you can add the common labels that needs to be added to the Configmaps.

    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    
    resources:
    - ../../base
    
    patches:
    - path: deployment.yaml
    - path: service.yaml
    
    generatorOptions:
      labels:
        app: web-service
    
    configMapGenerator:
    - name: index-html-configmap
      behavior: create
      files:
      - files/index.html
    - name: endpoint-configmap
      literals:
      - endpoint="api.example.com/users"

Let’s run the deployment using Kustomize.

    kustomize build overlays/generators | k apply  -f -

Now if you list the Configmaps, you can see two Configmaps created with a hash appended to their name as shown below.

    kubectl get cm 

![](https://devopscube.com/wp-content/uploads/2023/06/image-32.png)

As the deployment has a NodePort service, you can access the Nginx webpage that shows the content from the Configmap as shown below.

![](https://devopscube.com/wp-content/uploads/2023/06/image-33.png)

Also, if you login to the pod and echo the **ENDPOINT** environment variable, you will see the data from the configmap as shown below.

![](https://devopscube.com/wp-content/uploads/2023/06/literal-configmap.png)

Now, to test the configmap update through the generator, lets update the **index.html** data to the following.

    <html>
        <h1>Welcome</h1>
        </br>
        <h1>Hi! This is the Updated Configmap Index file </h1>
    </html
    

Let’s update the deployment using the following command.

    kustomize build overlays/generators | k apply  -f -

Now if you list the Configmaps, you will see two index Configmaps as shown below. This is because, for every configmap update, Kustomize will create a new configmap.

![](https://devopscube.com/wp-content/uploads/2023/06/image-34.png)

If you want to prune the orphaned Configmaps, use the **–prune** flag with the configmap label as shown below. The `--prune` flag instructs Kustomize to remove any resources from the final output that is no longer referenced or required.

    kustomize build overlays/generators | kubectl apply --prune -l app=web-service  -f -

Now, due to the new configmap created by Kustomize, the deployment triggers a rollout and nginx will use the updated configmap. If you check the Nginx NodePort service, you will see the updated index page.

![](https://devopscube.com/wp-content/uploads/2023/06/image-35.png)

Next, we will look at how to disable Hashed configmap.

Disabling Hashed ConfigMap
--------------------------

If you don’t want to create hashed Configmaps using the ConfigMap generator, you can disable it by setting the **`disableNameSuffixHash`** flag to true under **`generatorOptions`**. It will disable the hash for all the Configmaps mentioned in the **`kustomization.yaml`** file.

Here is an example.

    generatorOptions:
      labels:
        app: web-service
      disableNameSuffixHash: true

> **Note**: If you disable Configmap hash, you need to manually restart the pods for the configmap data to be consumed by the application.

Generate Secrets Using Kustomize
--------------------------------

You can generate secrets the same way you generate Configmaps.

For generating secrets, you need to use the secretGenerator field.

Here is an example of generating a secret object from a file.

    secretGenerator:
    - name: nginx-secret
      files:
      - files/secret.txt

If you want to generate secrets from literals, use the following format.

    secretGenerator:
    - name: nginx-api-password
      literals:
      - password="myS3cret"

You can mount the secret as a volume or propagate it as an environment variable as per your requirements.

    
