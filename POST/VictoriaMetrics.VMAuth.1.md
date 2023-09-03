https://www.cnblogs.com/rongfengliang/p/12937022.html

VictoriaMetrics vmauth 


docker-compose:
```yaml
version:  "3"
services: 
  prometheus:
    image: prom/prometheus
    ports:
      - 9090:9090
    volumes:
      - ./promdata:/prometheus
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
  vmstorage:
    image: victoriametrics/vmstorage
    ports:
      - 8482:8482
      - 8400:8482
      - 8401:8482
    volumes:
      - ./strgdata:/storage
    command:
      - '--storageDataPath=/storage'
  vmauth:
    image: victoriametrics/vmauth
    volumes: 
    - "./config.yaml:/etc/victoriametrics/config.yaml"
    command:
      - '-auth.config=/etc/victoriametrics/config.yaml'
    ports:
      - 8427:8427
  vminsert:
    image: victoriametrics/vminsert
    command:
      - '--storageNode=vmstorage:8400'
    ports:
      - 8480:8480
  vmselect:
    image: victoriametrics/vmselect
    command:
      - '--storageNode=vmstorage:8401'
    ports:
      - 8481:8481
  grafana:
    image: grafana/grafana
    ports:
      - 3000:3000
```

vmauth config.yaml:
```yaml
users:
- username: "dalong-select-account-1"
  password: "dalong"
  url_prefix: "http://vmselect:8481/select/1/prometheus"
- username: "dalong-insert-account-1"
  password: "dalong"
  url_prefix: "http://vminsert:8480/insert/1/prometheus"
```

prometheus.yml:
```yaml
global:
  scrape_interval:     1s
  evaluation_interval: 1s
remote_write:
  - url: "http://vmauth:8427"
    basic_auth:
      username: dalong-insert-account-1
      password: dalong
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']
  - job_name: 'vminsert'
    static_configs:
      - targets: ['vminsert:8480']
  - job_name: 'vmselect'
    static_configs:
      - targets: ['vmselect:8481']
  - job_name: 'vmstorage'
    static_configs:
      - targets: ['vmstorage:8482']
```yaml

```shell
docker-compose up -d
```