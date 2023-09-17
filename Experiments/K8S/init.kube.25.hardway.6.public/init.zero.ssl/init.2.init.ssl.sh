#!/usr/bin/bash

set -x


# https://rob-blackbourn.medium.com/how-to-use-cfssl-to-create-self-signed-certificates-d55f76ba5781

# STEP-1


# wget -q --show-progress --https-only --timestamping https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64 https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64
# chmod +x cfssl_1.6.1_linux_amd64 cfssljson_1.6.1_linux_amd64
# sudo mv cfssl_1.6.1_linux_amd64 /usr/local/bin/cfssl
# sudo mv cfssljson_1.6.1_linux_amd64 /usr/local/bin/cfssljson



# STEP-2

rm -R ./{root-ca,kubernetes,front-proxy-client,front-proxy-ca,ca,apiserver,apiserver-kubelet-client,default-config,scheduler,controller}
mkdir ./{root-ca,kubernetes,front-proxy-client,front-proxy-ca,ca,apiserver,apiserver-kubelet-client,default-config,scheduler,controller}



cat > default-config/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "ca-20-year": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "175200h"
      },
      "ca-15-year": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "131400h"
      },
      "ca-10-year": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "87600h"
      },
      "ca-5-year": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "43800h"
      },
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat <<EOF>default-config/cfssl.json
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "intermediate_ca": {
        "usages": [
            "signing",
            "digital signature",
            "key encipherment",
            "cert sign",
            "crl sign",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h",
        "is_ca": true,
        "ca_constraint": {
            "is_ca": true
        }
      },
      "peer": {
        "usages": [
            "signing",
            "digital signature",
            "key encipherment",
            "client auth",
            "server auth"
        ],
        "expiry": "8760h"
      },
      "server": {
        "usages": [
          "signing",
          "digital signing",
          "key encipherment",
          "server auth"
        ],
        "expiry": "8760h"
      },
      "client": {
        "usages": [
          "signing",
          "digital signature",
          "key encipherment",
          "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF


cat > root-ca/root-ca-csr.json <<EOF
{
  "CN": "iBLOG.PRO ROOT CA",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Yekaterinburg"
    }
  ],
  "ca": {
    "expiry": "262800h"
  }
}
EOF

cfssl gencert -initca root-ca/root-ca-csr.json | cfssljson -bare root-ca/root-ca

echo "------------------------------------"

ls -la

cat > ca/ca-csr.json <<EOF
{
  "CN": "iBLOG.PRO Intermediate CA",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "O": "Kubernetes",
      "OU": "Intermediate CA",
      "ST": "Yekaterinburg"
    }
  ],
  "ca": {
    "expiry": "87600h"
  }
}
EOF



cfssl gencert -initca ca/ca-csr.json | cfssljson -bare ca/ca
cfssl sign -ca root-ca/root-ca.pem -ca-key root-ca/root-ca-key.pem -config default-config/cfssl.json -profile intermediate_ca ca/ca.csr | cfssljson -bare ca/ca


echo "------------------------------------"


cat > kubernetes/kubernetes-csr.json <<EOF
{
  "CN": "Kubernetes Intermediate CA",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Yekaterinburg"
    }
  ],
  "ca": {
    "expiry": "87600h"
  }
}
EOF



cfssl gencert -initca kubernetes/kubernetes-csr.json | cfssljson -bare kubernetes/kubernetes
cfssl sign -ca ca/ca.pem -ca-key ca/ca-key.pem -config default-config/cfssl.json -profile intermediate_ca kubernetes/kubernetes.csr | cfssljson -bare kubernetes/kubernetes


echo "------------------------------------"


cat > front-proxy-ca/front-proxy-ca-csr.json <<EOF
{
  "CN": "front-proxy-ca",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Yekaterinburg"
    }
  ]
}
EOF

cfssl gencert \
  -ca=kubernetes/kubernetes.pem \
  -ca-key=kubernetes/kubernetes-key.pem \
  -config=default-config/ca-config.json \
  -profile=ca-10-year \
  front-proxy-ca/front-proxy-ca-csr.json | cfssljson -bare front-proxy-ca/front-proxy-ca


echo "------------------------------------"


cat > apiserver/apiserver-csr.json <<EOF
{
  "CN": "kube-apiserver",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Yekaterinburg"
    }
  ]
}
EOF

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster.local,node180,node181,node182,node180.cloud.local,node181.cloud.local,node182.cloud.local,10.96.128.1,192.168.200.180,192.168.200.181,192.168.200.182,192.168.200.186

cfssl gencert \
  -ca=kubernetes/kubernetes.pem \
  -ca-key=kubernetes/kubernetes-key.pem \
  -config=default-config/ca-config.json \
  -profile=ca-10-year \
  -hostname=${KUBERNETES_HOSTNAMES} \
  apiserver/apiserver-csr.json | cfssljson -bare apiserver/apiserver


echo "------------------------------------"










cat > front-proxy-client/front-proxy-client-csr.json <<EOF
{
  "CN": "front-proxy-client",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Yekaterinburg"
    }
  ]
}
EOF

cfssl gencert \
  -ca=kubernetes/kubernetes.pem \
  -ca-key=kubernetes/kubernetes-key.pem \
  -config=default-config/ca-config.json \
  -profile=ca-10-year \
  front-proxy-client/front-proxy-client-csr.json | cfssljson -bare front-proxy-client/front-proxy-client


echo "------------------------------------"









cat > apiserver-kubelet-client/apiserver-kubelet-client-csr.json <<EOF
{
  "CN": "kube-apiserver-kubelet-client",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Yekaterinburg"
    }
  ]
}
EOF

cfssl gencert \
  -ca=kubernetes/kubernetes.pem \
  -ca-key=kubernetes/kubernetes-key.pem \
  -config=default-config/ca-config.json \
  -profile=ca-10-year \
  apiserver-kubelet-client/apiserver-kubelet-client-csr.json | cfssljson -bare apiserver-kubelet-client/apiserver-kubelet-client


echo "------------------------------------"



cat > scheduler/scheduler-csr.json << EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Yekaterinburg"
    }
  ]
}
EOF

cfssl gencert \
   -ca=kubernetes/kubernetes.pem \
   -ca-key=kubernetes/kubernetes-key.pem \
   -config=default-config/ca-config.json \
   -profile=ca-10-year \
   scheduler/scheduler-csr.json | cfssljson -bare scheduler/scheduler


echo "------------------------------------"


cat >controller/controller-csr.json << EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RU",
      "L": "URAL",
      "L": "Beijing",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Yekaterinburg"
    }
  ]
}
EOF


cfssl gencert \
   -ca=kubernetes/kubernetes.pem \
   -ca-key=kubernetes/kubernetes-key.pem \
   -config=default-config/ca-config.json \
   -profile=ca-10-year \
   controller/controller-csr.json | cfssljson -bare controller/controller


echo "------------------------------------"



root-ca,kubernetes,front-proxy-client,front-proxy-ca,ca,apiserver,apiserver-kubelet-client

openssl x509 -in root-ca/root-ca.pem  -text
openssl x509 -in kubernetes/kubernetes.pem   -text
openssl x509 -in front-proxy-client/front-proxy-client.pem   -text
openssl x509 -in front-proxy-ca/front-proxy-ca.pem   -text
openssl x509 -in ca/ca.pem   -text
openssl x509 -in apiserver/apiserver.pem   -text
openssl x509 -in apiserver-kubelet-client/apiserver-kubelet-client.pem   -text

openssl verify -verbose -CAfile root-ca/root-ca.pem ca/ca.pem
cat root-ca/root-ca.pem ca/ca.pem > root.bundle.iblog.crt
openssl verify -verbose -CAfile root.bundle.iblog.crt kubernetes/kubernetes.pem


cat root-ca/root-ca.pem ca/ca.pem kubernetes/kubernetes.pem > root.bundle.kubernetes.crt
openssl verify -verbose -CAfile root.bundle.kubernetes.crt apiserver/apiserver.pem
openssl verify -verbose -CAfile root.bundle.kubernetes.crt front-proxy-ca/front-proxy-ca.pem
openssl verify -verbose -CAfile root.bundle.kubernetes.crt apiserver-kubelet-client/apiserver-kubelet-client.pem
openssl verify -verbose -CAfile root.bundle.kubernetes.crt front-proxy-client/front-proxy-client.pem

openssl verify -verbose -CAfile root.bundle.kubernetes.crt scheduler/scheduler.pem
openssl verify -verbose -CAfile root.bundle.kubernetes.crt controller/controller.pem


exit
