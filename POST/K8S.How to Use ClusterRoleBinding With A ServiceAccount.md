- https://travis.media/clusterrolebinding-with-service-account-all-namespaces/

How to Use ClusterRoleBinding With A ServiceAccount in All Namespaces (or a few)
================================================================================

ClusterRoleBinding is a powerful feature of Kubernetes RBAC that allows you to grant permissions cluster-wide in all namespaces. Let's learn how to use this with a ServiceAccount.

What is Kubernetes RBAC?
------------------------

RBAC stands for Role-Based Access Control which is a way of regulating users by their role.

What should they have access to? What scope? What actions?

And the Kubernetes RBAC API has four objects. They are

1.  Role
2.  ClusterRole
3.  RoleBinding
4.  ClusterRoleBinding

What are the differences in Role, ClusterRole and Binding?
----------------------------------------------------------

For simplicity sake, we’ll describe them like this:

A **Role** sets permissions within a particular namespace while a **ClusterRole** is a non-namespaced resource.

So one is restricted to a namespace, the other is not. Simple enough.

A **Binding** grants permissions defined in a Role or ClusterRole to a user or set of users.

These are called Subjects and include ServiceAccounts, Users, or Groups.

A **RoleBinding** grants permissions to a role in its namespace while a **ClusterRoleBinding** grants cluster-wide access.

So for example:

* ClusterRole + ClusterRoleBinding = All Namespaces
* ClusterRole + RoleBindings = Particular Namespaces
* Role + RoleBinding = Same Namespace

How to use ClusterRoleBinding with a ServiceAccount in All Namespaces
---------------------------------------------------------------------

### 1\. Create your ServiceAccount

What’s the subject of your ClusterRoleBinding? A group? A user?

Well in our case it’s a ServiceAccount.

A ServiceAccount provides an identity for processes that run in a Pod.

Let’s create that first in the dev namespace.

    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: my-serviceaccount
      namespace: dev

### 2\. Create a ClusterRole

A ClusterRole can grant the same permissions as a Role. However, ClusterRoles are “cluster-scoped” so you can use them, among other things, to grant access to namespaced resources **across all namespaces**.

Let’s create a ClusterRole that grants read access to secrets in all namespaces. (We’ll look at how to restrict namespaces later).

    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      # "namespace" omitted since ClusterRoles are not namespaced
      name: my-secrets-clusterrole
    rules:
    - apiGroups: [""]
      resources: ["secrets"]
      verbs: ["get", "watch", "list"]

### 3\. Create a ClusterRoleBinding

The ClusterRoleBinding simply grants the permissions defined in our ClusterRole above to a User(s), Group(s), or ServiceAccount(s). We want the latter.

    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: read-secrets-global
    subjects:
    - kind: ServiceAccount
      name: my-serviceaccount # name of your service account
      namespace: dev # this is the namespace your service account is in
    roleRef: # referring to your ClusterRole
      kind: ClusterRole
      name: my-secrets-clusterrole
      apiGroup: rbac.authorization.k8s.io

And now your ServiceAccount, which again is your identity for processes that run in a Pod, has access to all namespaces.

And that’s how you grant a ServiceAccount access to all namespaces in a Kubernetes cluster.

But what if you only want to grant access to a couple of namespaces only?

For that, you need to use RoleBindings.

[![](/images/banners/recommended-CKA-course.jpeg)](https://geni.us/KciFOCO)

Restrict a ClusterRole to a couple of namespaces only
-----------------------------------------------------

If you don’t want access to all namespaces and only a few instead, you need to attach your ClusterRole to a RoleBinding.

And you’ll need a RoleBinding for each namespace.

So to do this:

1.  Create your ServiceAccount as we did above.
2.  Create your ClusterRole again as we did above.
3.  Attach RoleBindings (not a ClusterRoleBinding) to your ClusterRole.

So using our ClusterRole above, let’s say I wanted to grant access to read secrets in the `dev` namespace AND the `staging` namespace, but NOT to a `prod` namespace.

I would create two RoleBindings (one for each namespace) and attach them to my ClusterRole. It would look like this:

    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: my-secrets-1
      namespace: dev
    roleRef: # points to my ClusterRole
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: my-secrets-clusterrole
    subjects: # points to my ServiceAccount
    - kind: ServiceAccount
      name: my-serviceaccount
      namespace: dev
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: my-secrets-2
      namespace: staging
    roleRef: # points to my ClusterRole
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: my-secrets-clusterrole
    subjects: # points to my ServiceAccount
    - kind: ServiceAccount
      name: my-serviceaccount
      namespace: dev

And that’s how to grant a ServiceAccount access to a select few namespaces only.

