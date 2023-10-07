```

helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update

helm search repo vm/victoria-metrics-k8s-stack -l

helm show values vm/victoria-metrics-k8s-stack > values.yaml

kubectl create ns metrics
helm install metrics vm/victoria-metrics-k8s-stack -f values.yaml -n metrics 
helm upgrade metrics vm/victoria-metrics-k8s-stack -f values.yaml -n metrics

```
