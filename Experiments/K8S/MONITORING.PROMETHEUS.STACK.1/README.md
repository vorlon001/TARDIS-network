```

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
helm search repo prometheus-community

kubectl create namespace monitoring
helm install blackbox-exporter prometheus-community/prometheus-blackbox-exporter -n monitoring -f values.blackbox.yaml
helm install kube-prom-stack prometheus-community/kube-prometheus-stack -n monitoring -f values.full.yaml



pod=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=prometheus" -o jsonpath="{.items[0].metadata.name}") && kubectl port-forward ${pod} 8080:9090 -n monitoring --address 0.0.0.0
kubectl port-forward svc/kube-prom-stack-grafana  8080:80 -n monitoring --address 0.0.0.0

```


```

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

kubectl create namespace redis
helm install redis bitnami/redis -n redis --set replica.replicaCount=3 --set master.persistence.enabled=false --set replica.persistence.enabled=false

kubectl get pods -n redis

cat <<EOF>redis.yaml
##
## Redis Master parameters
##
master:
 persistence:
   enabled: false
 extraFlags:
 - "--maxmemory 256mb"

replica:
 persistence:
   enabled: false
 replicaCount: 3
 extraFlags:
 - "--maxmemory 256mb"
##
## Prometheus Exporter / Metrics
##
metrics:
 enabled: true

## Metrics exporter pod Annotation and Labels
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "9121"

EOF


helm upgrade redis -f redis.yaml bitnami/redis -n redis 

```
