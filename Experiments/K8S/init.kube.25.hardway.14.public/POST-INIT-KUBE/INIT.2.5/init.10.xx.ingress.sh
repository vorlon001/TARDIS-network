#!/bin/sh

set -x

# helm show values ingress-nginx/ingress-nginx >ingress-nginx.default.values.yaml

echo "./script.sh ingress-nginx-4 controller 12.0.2.100 default"

if [ -z $1 ]; then
    echo "ARGS 1  is unset. example 'ingress-nginx-4'"
    exit
fi

if [ -z $2 ]; then
    echo "ARGS 2  is unset. example 'controller'"
    exit
fi

if [ -z $3 ]; then
    echo "ARGS 3  is unset. example '12.0.2.100'"
    exit
fi

if [ -z $4 ]; then
    echo "ARGS 4  is unset. example 'default'"
    exit
fi

NAMESPACE=$1       # ingress-nginx-4
NAMEINGRESS=$1     # ingress-nginx-4
CONTROLLERNAME=$2  # controller
CONTAINERNAME=$2   # controller
INGRESSIP=$3       # 12.0.2.100
INGRESSPOOL=$4     # default

rm -R INIT.2.5/dump/$NAMEINGRESS
rm -R INIT.2.5/values/$NAMEINGRESS

mkdir -p INIT.2.5/dump/$NAMEINGRESS
mkdir -p INIT.2.5/values/$NAMEINGRESS


kubectl create namespace $NAMESPACE
cat <<EOF > INIT.2.5/values/$NAMEINGRESS/values-ingress-nginx-value-$NAMESPACE.yaml
controller:
  image:
    registry: harbor.iblog.pro/registryk8sio
    image: ingress-nginx/controller
    tag: "v1.9.4"
    digest: ""
    pullPolicy: IfNotPresent
    runAsUser: 101
    allowPrivilegeEscalation: true
  ingressClassByName: true
  ingressClassResource:
    controllerValue: k8s.io/ingress-$NAMEINGRESS
    enabled: true
    name: $NAMEINGRESS
  resources:
    limits:
      cpu: 500m
      memory: 900Mi
    requests:
      cpu: 100m
      memory: 90Mi
  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 4
  service:
    enabled: true
    annotations:
      metallb.universe.tf/ip-allocated-from-pool: $INGRESSPOOL
    loadBalancerIP: $INGRESSIP
    type: LoadBalancer
    ports:
      http: 80
      https: 443
    targetPorts:
      http: http
      https: https
  priorityClassName: cluster-critical-pods
  admissionWebhooks:
    enabled: false
  proxySetHeaders:
    X-Is-From: "$NAMEINGRESS"
  priorityClassName: cluster-critical-pods
  publishService:
    enabled: true
  metrics:
    enabled: true
    serviceMonitor:
      enabled: false
  config:
    client-body-buffer-size: "32k"
    client-header-buffer-size: "256k"
    large-client-header-buffers: "4 256k"
    proxy-buffer-size: "128k"
    log-format-escape-json: "true"
    log-format-upstream: '{"time":"$time_iso8601","proxy_protocol_addr":"$proxy_protocol_addr","remote_addr":"$remote_addr","x-forward-for":"$proxy_add_x_forwarded_for","request_id":"$req_id","request":"$request","remote_user":"$remote_user","bytes_sent":"$bytes_sent","body_bytes_sent":"$body_bytes_sent","request_time":"$request_time","status":"$status","vhost":"$host","request_proto":"$server_protocol","path":"$uri","request_query":"$args","request_length":"$request_length","method":"$request_method","http_referrer":"$http_referer","http_user_agent":"$http_user_agent","upstream":"$proxy_upstream_name","upstream_ip":"$upstream_addr","upstream_latency":"$upstream_response_time","upstream_status":"$upstream_status","tls":"$ssl_protocol/$ssl_cipher"}'
    ssl-ciphers: ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA
    ssl-protocols: TLSv1 TLSv1.1 TLSv1.2 TLSv1.3
    enable-modsecurity: "true"
    modsecurity-snippet: |
      SecAuditLogType Serial
      SecAuditLog /var/log/audit/modsec.log
      SecAuditEngine RelevantOnly
      SecAuditLogRelevantStatus 403
      SecAuditLogFormat JSON
    use-gzip: "true"
    enable-brotli: "true"
    brotli-level: "3"
    http-snippet: "proxy_cache_path /tmp/nginx-cache-mp4 levels=1:2 keys_zone=mp4:50m max_size=256m inactive=30m use_temp_path=off;"
    brotli-types: "application/xml+rss application/atom+xml application/javascript application/x-javascript application/json application/rss+xml application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/svg+xml image/x-icon text/css text/javascript text/plain text/x-component image/png"
    gzip-types: "application/atom+xml application/javascript application/x-javascript application/json application/rss+xml application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/svg+xml image/x-icon text/css text/javascript text/plain text/x-component image/png"
EOF


helm install $NAMEINGRESS ingress-nginx/ingress-nginx --namespace=$NAMEINGRESS  \
  -f INIT.2.5/values/$NAMEINGRESS/values-ingress-nginx-value-$NAMESPACE.yaml


helm get values $NAMEINGRESS -n $NAMESPACE > INIT.2.5/values/$NAMEINGRESS/values-ingress-nginx-value-$NAMESPACE.values.yaml


helm template $NAMEINGRESS ingress-nginx/ingress-nginx --namespace=$NAMEINGRESS  \
  -f INIT.2.5/values/$NAMEINGRESS/values-ingress-nginx-value-$NAMESPACE.yaml \
  --output-dir INIT.2.5/dump/$NAMEINGRESS

helm template $NAMEINGRESS ingress-nginx/ingress-nginx --namespace=$NAMEINGRESS  \
  -f INIT.2.5/values/$NAMEINGRESS/values-ingress-nginx-value-$NAMESPACE.yaml > INIT.2.5/values/$NAMEINGRESS/full.dump.$NAMEINGRESS.yaml

