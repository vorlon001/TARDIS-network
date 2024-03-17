```

wget https://get.helm.sh/chartmuseum-v0.16.1-linux-amd64.tar.gz
mkdir chartmuseum-v0.16.1-linux-amd64
tar -xvzf chartmuseum-v0.16.1-linux-amd64.tar.gz -C chartmuseum-v0.16.1-linux-amd64

cat <<EOF>Dockerfile
FROM harbor.iblog.pro/test/alpine:main.scratch.3.19.stage.4

# TARGETARCH is predefined by Docker
# See https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

RUN apk add --no-cache cifs-utils ca-certificates

COPY ./chartmuseum-v0.16.1-linux-amd64/linux-amd64/chartmuseum /chartmuseum

USER 1000:1000

ENTRYPOINT ["/chartmuseum"]
EOF

docker build -t harbor.iblog.pro/test/chartmuseum:0.16.1 .
docker push harbor.iblog.pro/test/chartmuseum:0.16.1


mkdir -p chown 1000:1000 -R ./chartstorage
chown 1000:1000 -R ./chartstorage

docker run -it -p 8080:8080 -d  -v ./chartstorage:/chartstorage harbor.iblog.pro/test/chartmuseum:0.16.1  --debug --port=8080   --storage="local"   --storage-local-rootdir="/chartstorage"


wget https://helm.cilium.io/cilium-1.14.5.tgz
wget https://helm.cilium.io/cilium-1.14.6.tgz
wget https://helm.cilium.io/cilium-1.14.7.tgz
wget https://helm.cilium.io/cilium-1.14.8.tgz
wget https://helm.cilium.io/cilium-1.15.1.tgz
wget https://helm.cilium.io/cilium-1.15.2.tgz

curl --data-binary "@cilium-1.14.6.tgz" http://localhost:8080/api/charts
curl --data-binary "@cilium-1.14.7.tgz" http://localhost:8080/api/charts
curl --data-binary "@cilium-1.14.8.tgz" http://localhost:8080/api/charts
curl --data-binary "@cilium-1.15.1.tgz" http://localhost:8080/api/charts
curl --data-binary "@cilium-1.15.2.tgz" http://localhost:8080/api/charts


wget https://github.com/metallb/metallb/releases/download/metallb-chart-0.14.3/metallb-0.14.3.tgz
wget https://github.com/metallb/metallb/releases/download/metallb-chart-0.13.11/metallb-0.13.11.tgz

curl --data-binary "@metallb-0.14.3.tgz" http://localhost:8080/api/charts
curl --data-binary "@metallb-0.13.11.tgz" http://localhost:8080/api/charts


wget https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.10.0/ingress-nginx-4.10.0.tgz
wget https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.9.1/ingress-nginx-4.9.1.tgz

curl --data-binary "@ingress-nginx-4.10.0.tgz" http://localhost:8080/api/charts
curl --data-binary "@ingress-nginx-4.9.1.tgz" http://localhost:8080/api/charts


chartmuseum --debug --port=8080   --storage="local"   --storage-local-rootdir="./chartstorage"

```
