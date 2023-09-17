#!/usr/bin/bash

set -x
export HELMVERSION="3.12.3"
export platform="amd64"

export HELMFILE="helm-v${HELMVERSION}-linux-${platform}.tar.gz"
curl -o ${HELMFILE} https://get.helm.sh/${HELMFILE}

kustomize_version=( "5.1.1" "5.0.3" "4.5.7" "4.5.5" "4.5.3" "4.4.1" "4.0.5" "3.10.0" "3.9.4" "3.8.10")


for item in ${kustomize_version[*]}
do
    printf "   %s\n" $item
    kustomize_file="kustomize_v${item}_linux_${platform}.tar.gz"
    wget -O ${kustomize_file} https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${item}/${kustomize_file}
done



wget -O jq-linux64-1.6 https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x jq-linux64-1.6

wget -O yq_linux_amd64-4.27.2 https://github.com/mikefarah/yq/releases/download/v4.27.2/yq_linux_amd64
chmod +x yq_linux_amd64-4.27.2


VERSION=0.59.0
ARCH=amd64
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/v0.59.0/virtctl-v0.59.0-linux-amd64


CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
#sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
#sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
#rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}


wget  -O nerdctl-1.5.0-linux-amd64.tar.gz https://github.com/containerd/nerdctl/releases/download/v1.5.0/nerdctl-1.5.0-linux-amd64.tar.gz
