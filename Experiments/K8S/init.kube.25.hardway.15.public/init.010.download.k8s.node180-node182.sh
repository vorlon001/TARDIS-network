#!/usr/bin/bash

#wget https://storage.googleapis.com/kubernetes-release/release/v1.28.2/kubernetes-server-linux-amd64.tar.gz


cp /root/IMAGES/kubernetes-server-linux-amd64.1.29.3.tar.gz /root
tar -xf kubernetes-server-linux-amd64.1.29.3.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}

