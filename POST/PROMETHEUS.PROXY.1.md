```


cat <<EOF>simple.conf
proxy {
  admin.debugEnabled = true

  admin.enabled: true
  metrics.enabled: true

  http.requestLoggingEnabled: true
}

agent {
  proxy.hostname = localhost
  admin.enabled: true
  metrics.enabled: true
  pathConfigs: [
    {
      name: "Federate metrics"
      path: federate_metrics
      url: "http://192.168.200.140:9090/federate?match[]={job=~'.*'}"
    }
  ]
}
EOF


docker run -it -d --rm --net=host \
 -p 8082:8082 -p 8092:8092 -p 50051:50051 -p 8080:8080  \
 --env ADMIN_ENABLED=true \
 --env METRICS_ENABLED=true \
 pambrose/prometheus-proxy:1.18.0

docker run -it -d --rm --net=host \
 -p 8083:8083 -p 8093:8093 \
 --mount type=bind,source="$(pwd)"/simple.conf,target=/app/prom-agent.conf \
 --env AGENT_CONFIG=prom-agent.conf \
 pambrose/prometheus-agent:1.18.0

```
