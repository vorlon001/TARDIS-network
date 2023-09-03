https://yo-yo.fun/victoriametrics/9934c747150d/

[](#一、VictoriaMetrics-简介 "一、VictoriaMetrics 简介")一、VictoriaMetrics 简介
--------------------------------------------------------------------

[VictoriaMetrics](https://docs.victoriametrics.com/Quick-Start.html) 两个角色，1、时序数据库，2、监控解决方案

### [](#1-优缺点 "1. 优缺点")1\. 优缺点

从时序数据库来上来看，它的性能足够优异

* 查询性能：\> InfluxDB、TimescaleDB（据说是 20 倍，仅当参考）
* 内存使用：< InfluxDB、Prometheus、Thanos（少 5 倍以上）
* 空间占用：< InfluxDB、Prometheus、Thanos（少 5 倍以上）

从监控解决方案来上来看，相较于 Prometheus 有以下优点

* 提供全局（多实例）查询视图
* 支持水平扩容、高可用
* 支持多租户

由于 VictoriaMetrics 性能优于 Prometheus，且提供了更为丰富的功能，以及成熟的集群方案，所以现阶段很是火热

VictoriaMetrics 也不全是优点，上手后也发现一些不足

* 图形化很简陋，很多页面直接就是 json 返回
* 告警功能不如 AlertManager 丰富
* 没有 WAL 日志，突然断电可能会丢失部分数据

### [](#2-单机-amp-集群 "2. 单机 & 集群")2\. 单机 & 集群

VictoriaMetrics 主要有两种使用场景

* **单节点版**：采集数据点（data points）低于 100w/s，官方推荐单节点版，单节点方案通常会使用到以下组件
    * **victoria-metrics**：负责提供时序数据的查询、存储
    * **vmalert**：负责从 victoria-metrics 获取数据评估 **告警规则**、**记录规则**，产生的数据一般也会写到 victoria-metrics
    * **alertmanager**：负责处理 vmalert 发过来的告警
    * **grafana**：渲染指标数据，生成监控大盘
* **集群版**：
    * **vmagent**：负责收集指标数据，支持提供 pull、push 获取数据、兼容 prometheus的 scraping target、relabeling 配置
    * **vmselect**：提供查询入口，执行用户输入查询，从各 `vmstorage` 节点获取所需数据
    * **vminsert**：提供 `remote write` 接口，接收 `Prometheus` 或 `vmagent` 刮取的数据，并根据 **指标名称** 及其 **标签** 的 **一致性哈希** 将其分散存储到 `vmstorage` 节点
    * **vmstorage**：存储原始数据，并返回指定标签过滤器在给定时间范围内的查询数据

[](#二、VictoriaMetrics-单节点 "二、VictoriaMetrics 单节点")二、VictoriaMetrics 单节点
-----------------------------------------------------------------------

### [](#单节点常用方案 "单节点常用方案")单节点常用方案

#### [](#方案一：Prometheus-AlertManager-Grafana-Webhook "方案一：Prometheus + AlertManager + Grafana + Webhook")方案一：Prometheus + AlertManager + Grafana + Webhook


#### [](#方案二：Prometheus-VictoriaMetrics-AlertManager-Grafana-Webhook "方案二：Prometheus + VictoriaMetrics + AlertManager + Grafana + Webhook")方案二：Prometheus + VictoriaMetrics + AlertManager + Grafana + Webhook

#### [](#方案三：VictoriaMetrics-AlertManager-Grafana-Webhook "方案三：VictoriaMetrics + AlertManager + Grafana + Webhook")方案三：VictoriaMetrics + AlertManager + Grafana + Webhook


#### [](#手动部署 "手动部署")手动部署

从 方案一 调整为 方案三，在不影响基本功能的同时监控方案的性能与容量，为了加深理解，下面以二进制方式一步步的迁移部署

##### [](#1-安装-VictoriaMetrics、vmalert "1. 安装 VictoriaMetrics、vmalert")1\. 安装 VictoriaMetrics、vmalert

VictoriaMetrics 二进制文件可以从 [Github Release](https://github.com/VictoriaMetrics/VictoriaMetrics/releases) 下载

bash

    $ wget https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.90.0/victoria-metrics-linux-amd64-v1.90.0.tar.gz
    $ tar xf victoria-metrics-linux-amd64-v1.90.0.tar.gz --transform 's/victoria-metrics-prod/victoria-metrics/'

这里除了 victoria-metrics 还会用到 vmalert，不过 [官方文档](https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html) 与 [Github](https://github.com/VictoriaMetrics/VictoriaMetrics) 都没提供下载地址，按照[官方文档](https://docs.victoriametrics.com/vmalert.html#quickstart)执行 make 编译时遇到错误

bash

    $ git clone https://github.com/VictoriaMetrics/VictoriaMetrics
    $ cd VictoriaMetrics
    $ make vmalert

错误信息如下

bash

    APP_NAME=vmalert make app-local
    make[1]: Entering directory `/tmp/VictoriaMetrics'
    CGO_ENABLED=1 go build  -ldflags "-X 'github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version=vmalert-20230411-091838-heads-master-0-g0e1e0b0'" -o bin/vmalert github.com/VictoriaMetrics/VictoriaMetrics/app/vmalert
    app/vmalert/web.go:4:2: cannot find package "." in:
    	/tmp/VictoriaMetrics/vendor/embed
    vendor/github.com/mattn/go-runewidth/runewidth.go:7:2: found packages uniseg (doc.go) and main (gen_breaktest.go) in /tmp/VictoriaMetrics/vendor/github.com/rivo/uniseg
    make[1]: *** [app-local] Error 1
    make[1]: Leaving directory `/tmp/VictoriaMetrics'
    make: *** [vmalert] Error 2

看了下 `go.mod`

go

    $ cat go.mod                             
    module github.com/VictoriaMetrics/VictoriaMetrics
    
    go 1.19
    
    require (
    	cloud.google.com/go/storage v1.30.1
    	github.com/Azure/azure-sdk-for-go/sdk/azcore v1.4.0
    	github.com/Azure/azure-sdk-for-go/sdk/storage/azblob v1.0.0
    	github.com/VictoriaMetrics/fastcache v1.12.1
        # ...

我这边版本太低了，升级 golang 版本

bash

    $ go version
    go version go1.19.8 linux/amd64

切换代码版本，确保与 `victoria-metrics` 保持一致

bash

    ☁  VictoriaMetrics [master]  git tag -l "v1.9*" 
    v1.9.0
    v1.90.0
    v1.90.0-cluster
    ☁  VictoriaMetrics [v1.90.0] make vmalert             
    APP_NAME=vmalert make app-local
    make[1]: Entering directory `/tmp/VictoriaMetrics'
    CGO_ENABLED=1 go build  -ldflags "-X 'github.com/VictoriaMetrics/VictoriaMetrics/lib/buildinfo.Version=vmalert-20230411-093246-v1.90.0-0-gb5d18c0'" -o bin/vmalert github.com/VictoriaMetrics/VictoriaMetrics/app/vmalert
    make[1]: Leaving directory `/tmp/VictoriaMetrics'

编译成功，目标文件在 `bin/` 目录下

bash

    ☁  VictoriaMetrics [v1.90.0] ls bin    
    vmalert
    ☁  VictoriaMetrics [v1.90.0] ./bin/vmalert --version    
    vmalert-20230411-093246-v1.90.0-0-gb5d18c0

顺手把其他的也一并编译出来

bash

    $ for i in vmagent vmauth vmctl vmgateway vmbackup vmrestore
    do
    make $i
    done
    $ ls bin 
    vmagent  vmalert  vmauth  vmbackup  vmctl  vmrestore

编译完成，最后简单调整服务目录规范

bash

    $ tree /usr/local/victoria-metrics
    /usr/local/victoria-metrics
    ├── bin
    │   ├── victoria-metrics
    │   ├── vmagent
    │   ├── vmalert
    │   ├── vmauth
    │   ├── vmbackup
    │   ├── vmctl
    │   └── vmrestore
    ├── config
    │   └── victoria-metrics.yml
    ├── data
    └── rules
    
    4 directories, 8 files

systemd 服务单元脚本，基于源代码目录下 `package/rpm/victoriametrics.service` 稍作修改

none

    $ cat > /etc/systemd/system/vm.service << EOF
    [Unit]
    Description=VictoriaMetrics
    After=network.target
    
    [Service]
    Type=simple
    User=victoria-metrics
    # 服务在单位时间内（StartLimitInterval）最大重启次数 
    StartLimitBurst=5
    StartLimitInterval=10
    # 重启间隔，异常后等待 1 秒再启动
    RestartSec=1
    # 当退出码非 0 时，执行服务重启
    Restart=on-failure
    ExecStart=/usr/local/victoria-metrics/bin/victoria-metrics \
        -promscrape.config=/usr/local/victoria-metrics/config/victoria-metrics.yml \ # victoria-metrics 服务配置，基本兼容 Prometheus 配置
        -storageDataPath=/usr/local/victoria-metrics/data \ # 数据目录
        -promscrape.configCheckInterval=60s \               # 重载配置间隔
        -promscrape.consulSDCheckInterval=60s \             # 各类服务发现机制的检查间隔配置
        -promscrape.dnsSDCheckInterval=60s \
        -promscrape.dockerSDCheckInterval=60s \
        -promscrape.fileSDCheckInterval=60s \
        -promscrape.httpSDCheckInterval=60s \
        -promscrape.kubernetesSDCheckInterval=60s \
        -retentionPeriod=60d \                              # 保留最近 60 天的数据
        --httpListenAddr=:9290                              # 服务监听
    ExecStop=/bin/kill -s SIGTERM $MAINPID
    
    
    # 进程文件描述上限、服务最大可打开进程（线程）上限
    LimitNOFILE=65536
    LimitNPROC=32000
    
    
    [Install]
    WantedBy=multi-user.target
    EOF

victoria-metrics 配置文件

yaml

    $ cat > /usr/local/victoria-metrics/config/victoria-metrics.yml << EOF
    global:
      scrape_interval: 15s
    
    scrape_configs:
      - job_name: "victoria-metrics"
        static_configs:
          - targets: ["127.0.0.1:9290"]
    EOF

特别说明下，victoria-metrics 并非百分百兼容 prometheus 配置，如下面的错误提示，所以还是要自己多留意一下

bash

    Apr 10 17:56:28 bj-tencent-lhins-1 victoria-metrics[15020]: line 4: field evaluation_interval not found in type promscrape.GlobalConfig
    Apr 10 17:56:28 bj-tencent-lhins-1 victoria-metrics[15020]: line 7: field alerting not found in type promscrape.Config
    Apr 10 17:56:28 bj-tencent-lhins-1 victoria-metrics[15020]: line 12: field rule_files not found in type promscrape.Config
    Apr 10 17:56:28 bj-tencent-lhins-1 victoria-metrics[15020]: line 67: field refresh_interval not found in type promscrape.FileSDConfig
    Apr 10 17:56:28 bj-tencent-lhins-1 victoria-metrics[15020]: line 73: field refresh_interval not found in type dns.SDConfig
    Apr 10 17:56:28 bj-tencent-lhins-1 victoria-metrics[15020]: line 79: field refresh_interval not found in type dns.SDConfig; pass -promscrape.config.strictParse=false command-line flag for ignoring unknown fields in yaml config

创建用户 victoria-metrics

bash

    $ useradd victoria-metrics

更改目录属主

bash

    $ chown -R victoria-metrics:victoria-metrics /usr/local/victoria-metrics

设置服务自启

bash

    $ sc enable vm --now

检查服务状态

bash

    $ sc status vm

`victoria-metrics` 配置完毕后，查看 WebUI
![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304111832158.png)

配置 `vmalert` 的 `systemd` 服务单元脚本

bash

    $ cat > /etc/systemd/system/vmalert.service << EOF
    [Unit]
    Description=VictoriaMetrics Alert
    After=network.target
    
    [Service]
    Type=simple
    User=victoria-metrics
    StartLimitBurst=5
    StartLimitInterval=10
    RestartSec=1
    Restart=on-failure
    ExecStart=/usr/local/victoria-metrics/bin/vmalert\
      -evaluationInterval=15s \        # 评估间隔
      -rule=/usr/local/victoria-metrics/rules/*.yml \  # 记录规则、告警规则目录
      -datasource.url=127.0.0.1:9290 \                 # victoria-metrics 服务地址，读取数据评估规则
      -remoteWrite.url=127.0.0.1:9290 \                # victoria-metrics 服务地址，写入记录数据
      -notifier.url=127.0.0.1:9193 \                   # alertmanager 服务地址
      -httpListenAddr=0.0.0.0:9291                     # 服务监听地址
    
    ExecStop=/bin/kill -s SIGTERM $MAINPID
    LimitNOFILE=65536
    LimitNPROC=32000
    
    [Install]
    WantedBy=multi-user.target
    EOF

设置服务自启

bash

    $ sc enable vmalert --now

检查服务状态

bash

    $ sc status vmalert

查看 WebUI

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304111833837.png)

##### [](#2-配置-AlertManager、Promoter "2. 配置 AlertManager、Promoter")2\. 配置 AlertManager、Promoter

这两个服务是已经配置好的，所以不需要修改，vmalert 直接指过来就行，安装也比较简单，这里只是贴下相关配置

AlertManager 服务配置：`alertmanager.yml`

yaml

    global:
      # 当 alertmanager 持续多长时间未接收到告警后标记告警状态为 resolved
      resolve_timeout: 5m
      ##################
      #      SMTP
      ##################
      smtp_smarthost: smtp.163.com:465
      smtp_from: xxx@163.com
      smtp_auth_username: xxxx@163.com
      smtp_auth_identity: xxxx@163.com
      smtp_auth_password: 
      smtp_require_tls: false
    
    
    # 告警路由
    route:
      # 这里的标签列表是接收到报警信息后的重新分组标签
      # 如，接收到的报警信息里有许多具有 instance=A 和 alertname=xx 这样标签的报警信息将会批量被聚合到一个分组里面
      group_by: ['instance', 'alertname']
      group_wait: 1s
      group_interval: 10s
      # 警报重复间隔，每2分钟重复一次警报
      repeat_interval: 2m
      # 警报接收端，这里配置为下面定义的钩子
      # receiver: 'default-mail-receiver'
      # receiver: 'ops_wechat'
      receiver: 'default-mail-receiver'
      routes:
      - match_re:
          # severity: ^(error|critical)$
          severity: ^(critical)$
        receiver: promoter-webhook-dingtalk
        continue: true
      - match:
          severity: warning
        receiver: promoter-webhook-wechat
    
    receivers:
      - name: default-mail-receiver
        email_configs:
          - to: "xxx@163.com"
            send_resolved: true
      - name: 'promoter-webhook-dingtalk'
        webhook_configs:
        - url: "http://127.0.0.1:9195/dingtalk/send"
          send_resolved: true
      - name: 'promoter-webhook-wechat'
        webhook_configs:
        - url: "http://127.0.0.1:9195/wechat/send"
          send_resolved: true

Promoter 服务配置：`promoter.yml`

yaml

    ---
    global:
      # victoria-metrics 服务地址，执行 PromQL 语句，用以渲染图片
      prometheus_url: http://172.17.0.1:9290
      dingtalk_api_token: xxx
      dingtalk_api_secret: xxx
      wechat_api_secret: xxx-DxXFQQVF8Z1eirmD8
      wechat_api_corp_id: xxx
    
    s3:
      # 阿里云 AK、SK，用以上传监控渲染图片
      access_key: "xxx"
      secret_key: "xxx"
      # endpoint: "oss-cn-beijing-internal.aliyuncs.com"
      endpoint: "oss-cn-beijing.aliyuncs.com"
      region: "cn-beijing"
      bucket: "xxxx"
    
    
    receivers:
      - name: dingtalk
        dingtalk_config:
          message_type: markdown
          markdown:
            title: '{{ template "dingtalk.default.title" . }}'
            text: '{{ template "dingtalk.default.content" . }}'
          at:
            atMobiles: [ "135xxx" ]
            isAtAll: true
      - name: wechat
        wechat_config:
          message_type: markdown
          message: '{{ template "wechat.default.message" . }}'
          to_user: "@all"
          agent_id: 1000002

##### [](#3-Grafana-切换数据源 "3. Grafana 切换数据源")3\. Grafana 切换数据源

创建新数据源，使用 victoria-metrics 服务地址端口

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304111835448.png)

切换数据源的方式如下：

1.  Share 分享，导出仪表盘 JSON 文件
2.  import 仪表盘，选择 victoria-metrics 数据源

由于 node_exporter 示例仪表盘，已经发布到 Grafana，直接输入 18435，修改可能存在的重名、UID问题，选择 victoria-metrics 数据源，然后倒入即可

查看新仪表盘的渲染展示情况

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304111842891.gif)

##### [](#4-Promoter-告警测试 "4. Promoter 告警测试")4\. Promoter 告警测试

通过 HostHighTmpfsUsed 指标测试

yaml

    - alert: HostHighTmpfsUsed
      # tmpfs 内存使用超过 1 GiB
      # expr: node:mem:tmpfs_used > 1024
      # 为方便测试调整阈值为 200
      expr: node:mem:tmpfs_used > 200
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "{{ $labels.instance }} 节点 tmpfs 使用率过高 ！"
        description: "最近一分钟内 {{ $labels.instance }} 节点 tmpfs 使用率过高 ！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"

在 `/run` 生成 300M 文件

bash

    $ cd /run; dd if=/dev/urandom of=testfile count=300 bs=1M

访问 vmalert WebUI 查看是否有活跃告警

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304111849748.png)

等片刻，Pending 变为 Firing

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304111850777.png)

企业微信告警

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304111851243.png)

另一个相关指标的钉钉告警

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304111852965.png)

#### [](#ansible-部署 "ansible 部署")ansible 部署

##### [](#环境版本 "环境版本")环境版本

由于只是示例 demo，没做太多兼容性考虑，低版本的 ansible 执行可能会出错，例如缺少 `filter` 之类的，建议使用前确认环境及版本，下面是我个人的环境

bash

    $ cat /etc/redhat-release           
    CentOS Linux release 7.9.2009 (Core)
    
    $ uname -r
    5.4.239-1.el7.elrepo.x86_64
    
    $ pip freeze | grep ansible                        
    ansible==7.4.0
    ansible-core==2.14.4
    
    
    $ ansible --version
    ansible [core 2.14.4]
      config file = None
      configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
      ansible python module location = /root/.pyenv/versions/3.9.16/lib/python3.9/site-packages/ansible
      ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
      executable location = /root/.pyenv/versions/3.9.16/bin/ansible
      python version = 3.9.16 (main, Apr 13 2023, 00:38:03) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)] (/root/.pyenv/versions/3.9.16/bin/python3.9)
      jinja version = 3.1.2
      libyaml = True

##### [](#下载角色 "下载角色")下载角色

bash

    $ ansible-galaxy install git+git@e.coding.net:LotusChing/prometheus/victoria-metrics-role.git

下载路径为配置文件 `/etc/ansible/ansible.cfg` 中 roles_path 参数定义

如果 `roles_path` 配置项未定义，则按照下载至默认 roles 路径列表中的第一个

bash

    $ ansible-config dump |grep DEFAULT_ROLES_PATH
    
    DEFAULT_ROLES_PATH(default) = [u'/root/.ansible/roles', u'/usr/share/ansible/roles', u'/etc/ansible/roles']
    $ cd /root/.ansible/roles
    $ ls
    victoria-metrics-role

##### [](#修改配置 "修改配置")修改配置

* 根据个人环境修改 `inventory` 文件
    
* 按照需求修改各软件参数配置 `roles/single-server/vars/main.yml`
    

##### [](#执行角色 "执行角色")执行角色

1.  全部安装（vm、node_exporter、alertmanager、promoter、grafana）
    
    bash
    
        $ ansible-playbook -i inventory roles/single-server/setup.yml
    
2.  只安装特定的包
    
    bash
    
        $ ansible-playbook -i inventory --tags=node_exporter,vm roles/single-server/setup.yml
    
3.  排除特定的包
    
    bash
    
        $ ansible-playbook -i inventory --skip-tags=node_exporter roles/single-server/setup.yml
    

执行角色安装

bash

    $ ansible-playbook -i inventory roles/single-server/setup.yml
    
    PLAY [localhost] ***********************************************************************************************************************************
    
    TASK [Gathering Facts] *****************************************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : include_tasks] ************************************************************************************************************
    included: /root/.ansible/roles/victoria-metrics-role/roles/single-server/tasks/install_node_exporter.yml for localhost
    
    TASK [../single-server : 获取 node_exporter 二进制包文件状态] **************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 下载 node_exporter 二进制包] **********************************************************************************************
    skipping: [localhost]
    
    TASK [../single-server : 配置 Chrony NTP 开放规则] *************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建 node_exporter 服务目录] **********************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 解压 node_exporter 安装包] ************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 node_exporter 目录属主] **********************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 node_exporter 环境变量] **********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 node_exporter 服务启动脚本] ******************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 重载系统配置 daemon_reload] ***********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 启动 node_exporter 并配置自启] ********************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : include_tasks] ************************************************************************************************************
    included: /root/.ansible/roles/victoria-metrics-role/roles/single-server/tasks/install_promoter.yml for localhost
    
    TASK [../single-server : 获取 promoter 二进制包文件状态] *******************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 下载 promoter 二进制包] ***************************************************************************************************
    skipping: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建 promoter 服务目录] ***************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 解压 promoter 安装包] *****************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 promoter 目录属主] ***************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 promoter 环境变量] ***************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 promoter 服务启动脚本] ***********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 promoter 服务配置] ***************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 修正 promoter 服务配置] ***************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 重载系统配置 daemon_reload] ***********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 启动 promoter 并配置自启] *************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : include_tasks] ************************************************************************************************************
    included: /root/.ansible/roles/victoria-metrics-role/roles/single-server/tasks/install_alertmanager.yml for localhost
    
    TASK [../single-server : 获取 alertmanager 二进制包文件状态] ***************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 下载 alertmanager 二进制包] ***********************************************************************************************
    skipping: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建 alertmanager 服务目录] ***********************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 解压 alertmanager 安装包] *************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 alertmanager 目录属主] ***********************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 alertmanager 环境变量] ***********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 alertmanager 服务启动脚本] *******************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 alertmanager 服务配置] ***********************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 重载系统配置 daemon_reload] ***********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 启动 alertmanager 并配置自启] *********************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : include_tasks] ************************************************************************************************************
    included: /root/.ansible/roles/victoria-metrics-role/roles/single-server/tasks/install_victoriametrics.yml for localhost
    
    TASK [../single-server : 获取 VictoriaMetrics 二进制包文件状态] ************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 下载 victoria-metrics 二进制包] *******************************************************************************************
    skipping: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建 victoria-metrics 服务目录] *******************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 解压 victoria-metrics 安装包] *********************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 victoria-metrics 环境变量] *******************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 victoria-metrics 服务启动脚本] ***************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 vmalert 服务脚本] ****************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 victoria-metrics 服务配置] *******************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 拉取 rules 规则库] ********************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 victoria-metrics 目录属主] *******************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 重载系统配置 daemon_reload] ***********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 启动 victoria-metrics 并配置自启] *****************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 启动 vmalert 并配置自启] **************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : include_tasks] ************************************************************************************************************
    included: /root/.ansible/roles/victoria-metrics-role/roles/single-server/tasks/install_grafana.yml for localhost
    
    TASK [../single-server : 获取 grafana 二进制包文件状态] ********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 下载 grafana 二进制包] ****************************************************************************************************
    skipping: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建服务运行用户组] *******************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 创建 grafana 服务目录] ****************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 解压 grafana 安装包] ******************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 grafana 目录属主] ****************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 设置 grafana 环境变量] ****************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 grafana 服务启动脚本] ************************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 生成 grafana 服务配置] ****************************************************************************************************
    changed: [localhost]
    
    TASK [../single-server : 重载系统配置 daemon_reload] ***********************************************************************************************
    ok: [localhost]
    
    TASK [../single-server : 启动 grafana 并配置自启] **************************************************************************************************
    changed: [localhost]
    
    RUNNING HANDLER [../single-server : print-node-exporter-info] **************************************************************************************
    ok: [localhost] => {
        "msg": [
            "######### Node Exporter #########",
            "HOME: /usr/local/node_exporter",
            "URL: 192.168.0.101:9193",
            "#################################"
        ]
    }
    
    RUNNING HANDLER [../single-server : print-alertmanager-info] ***************************************************************************************
    ok: [localhost] => {
        "msg": [
            "######### AlertManager #########",
            "HOME: /usr/local/alertmanager/",
            "DATA: /usr/local/alertmanager/data",
            "URL: 192.168.0.101:9193",
            "################################"
        ]
    }
    
    RUNNING HANDLER [../single-server : print-grafana-info] ********************************************************************************************
    ok: [localhost] => {
        "msg": [
            "######### Grafana #########",
            "HOME: /usr/local/grafana",
            "Config: /usr/local/grafana/conf/defaults.ini",
            "User: admin",
            "Password: admin123",
            "URL: 192.168.0.101:9300",
            "###########################"
        ]
    }
    
    RUNNING HANDLER [../single-server : print-promoter-info] *******************************************************************************************
    ok: [localhost] => {
        "msg": [
            "######### Promoter #########",
            "HOME: /usr/local/promoter",
            "Config: /usr/local/promoter/config.yml",
            "Listen addr: http://0.0.0.0:9194",
            "Default Media: dingtalk",
            "Enable Media: [dingtalk: True, wechat: False, mail: True]",
            "###########################"
        ]
    }
    
    RUNNING HANDLER [../single-server : print-victoria-metrics-info] ***********************************************************************************
    ok: [localhost] => {
        "msg": [
            "######### VictoriaMetrics #########",
            "HOME: /usr/local/victoria-metrics",
            "DATA: /usr/local/victoria-metrics/data",
            "Config: /usr/local/victoria-metrics/config/victoria-metrics.yml",
            "VictoriaMetrics URL: 192.168.0.101:9290",
            "VMAlert URL: 192.168.0.101:9291",
            "Node_export target: ['127.0.0.1:9110']",
            "###################################"
        ]
    }
    
    PLAY RECAP *****************************************************************************************************************************************
    localhost                  : ok=70   changed=27   unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   

##### [](#检查确认 "检查确认")检查确认

1.  检查服务启动，观察有无 error、failed 输出
    
    bash
    
        $ systemctl status <unit>
    
2.  访问 VictoriaMetrics WebUI，检查 targets、以及 node_exporter 规则、记录规则是否生成等
    
    ![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304130911282.png)
    
    bash
    
        node_load1
        node:cpu:cpu_usage
    
3.  访问 Grafana WebUI，默认用户名/密码 `admin/admin123`，创建数据源、导入 `18434`
    
    ![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304130913988.png)
    
4.  测试 `AlertManager`、 `Promoter` 告警
    
    ![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304130910604.png)
    
    ![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304130917913.png)
    
    AlertManager、Promoter 告警测试，观察 vmalert 有无产生 firing 告警
    
    bash
    
        $ sc stop node_exporter
    

​ OK，钉钉收到告警

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304130948178.png)

[](#三、VictoriaMetrics-集群 "三、VictoriaMetrics 集群")三、VictoriaMetrics 集群
--------------------------------------------------------------------

### [](#集群组件 "集群组件")集群组件

`VictoriaMetrics` 集群模式主要由下面三个核心服务组成：

* **vmagent**：负责收集指标数据，支持提供 pull、push 获取数据、兼容 `prometheus` 的 `scraping target`、`relabeling` 配置
* **vminsert**：提供 `remote write` 接口，接收 `Prometheus` 或 `vmagent` 刮取的数据，并根据 **指标名称** 及其 **标签** 的 **一致性哈希** 将其分散存储到 `vmstorage` 节点
* **vmstorage**：存储原始数据，并返回指定标签过滤器在给定时间范围内的查询数据
    * 当 `-storageDataPath` 数据目录可用空间少于 `-storage.minFreeDiskSpaceBytes`，`vmstorage` 节点进入只读模式，`vminsert` 节点将写请求路由到其他 `vmstorage` 节点
* **vmselect**：执行查询，从各 `vmstorage` 节点获取所需数据

### [](#集群扩容 "集群扩容")集群扩容

上门四个是 VictoriaMetrics 集群最核心的四个个组件，扩容以下组件可以提高集群性能级稳定性，具体如下：

| 组件  | 纵向扩容（CPU、内存） | 横向扩容（添加节点） |
| --- | --- | --- |
| **vmagent** | 提高节点抓取性能 | 提高集群抓取性能及容量，将大量目标的抓取压力分散到多个 `vmagent` 实例 |
| **vmselect** | 提高复杂查询的性能（以及处理大量的时间序列和大量的原始样本） | 提高集群稳定性，提高查询的最大速度，传入的并发请求可能会在更多的 `vmselect` 节点之间进行拆分 |
| **vminsert** | 通常不需要纵向扩容 | 提高集群稳定性，提高数据接收的最大速度，数据写入请求可以在更多的 `vminsert` 节点之间进行拆分 |
| **vmstorage** | 增加集群可以处理的活跃时间序列的数量 | 提高集群稳定性，提高对高流失率的时间序列的查询性能 |

### [](#数据复制 "数据复制")数据复制

默认，VictoriaMetrics 数据复制依赖 `-storageDataPath` 指向的数据目录存储完成

除此外，还可以通过 `-replicationFactor=N` 启用多份写入，通过将每份数据存入 `N` 个不同的节点，实现数据复制。在查询时会同时查询多个节点，去重后返回给客户端

### [](#集群部署 "集群部署")集群部署

#### [](#申请-ecs "申请 ecs")申请 ecs

bash

    # 调动 阿里云 OpenAPI 创建三台抢占式 ECS 实例
    $ python aliyun-ecs-sdk.py apply
    
    Success. Instance creation succeed. InstanceIds: i-hp3dvstf3hxe3zfi5pi3, i-hp3dvstf3hxe3zfi5pi4, i-hp3dvstf3hxe3zfi5pi5
    Instance boot successfully: node00001 39.104.25.70 172.16.0.14
    Instance boot successfully: node00002 39.104.21.230 172.16.0.13
    Instance boot successfully: node00003 39.104.21.216 172.16.0.12

#### [](#初始化-k8s "初始化 k8s")初始化 k8s

使用 ansible 部署并初始化 Kubernetes 集群

bash

    $ ap -i alicloud.py --tags=kubernetes setup.yml

输出信息

bash

    PLAY [系统初始化] **********************************************************************************************************************************
    
    PLAY [部署 Container Runtime] **********************************************************************************************************************
    
    PLAY [部署 Kubernetes 集群] ************************************************************************************************************************
    
    TASK [Gathering Facts] *****************************************************************************************************************************
    ok: [i_hp3dvstf3hxe3zfi5pi5]
    ok: [i_hp3dvstf3hxe3zfi5pi3]
    ok: [i_hp3dvstf3hxe3zfi5pi4]
    
    TASK [kubernetes : include_tasks] ******************************************************************************************************************
    included: /prodata/scripts/ansibleLearn/ansible-k8s-role/roles/kubernetes/tasks/install_kubernetes.yml for i_hp3dvstf3hxe3zfi5pi3, i_hp3dvstf3hxe3zfi5pi4, i_hp3dvstf3hxe3zfi5pi5 => (item=install_kubernetes.yml)
    
    TASK [kubernetes : 启动并设置 kubelet 自启] ********************************************************************************************************
    ok: [i_hp3dvstf3hxe3zfi5pi3]
    ok: [i_hp3dvstf3hxe3zfi5pi5]
    ok: [i_hp3dvstf3hxe3zfi5pi4]
    
    TASK [kubernetes : 生成 kubeadm 集群初始化配置] ****************************************************************************************************
    changed: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi4]
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : 拉取 Kubernetes 集群组件镜像] ***************************************************************************************************
    changed: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    changed: [i_hp3dvstf3hxe3zfi5pi4]
    
    TASK [kubernetes : 执行 Kubernetes 集群初始化] *****************************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi4]
    skipping: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : 获取 join 信息] *****************************************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi4]
    skipping: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : 拉取 join 脚本到主控机] *********************************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi4]
    skipping: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : worker 节点加入集群] ************************************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi3]
    changed: [i_hp3dvstf3hxe3zfi5pi4]
    changed: [i_hp3dvstf3hxe3zfi5pi5]
    
    TASK [kubernetes : Master 节点基础配置] ************************************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi4]
    skipping: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : 下载 flannel 网络插件清单文件] **************************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi4]
    skipping: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : 部署 flannel 网络插件] **********************************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi4]
    skipping: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : 禁用默认 containerd cni 配置] ***************************************************************************************************
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    fatal: [i_hp3dvstf3hxe3zfi5pi5]: FAILED! => {"changed": true, "cmd": "mv /etc/cni/net.d/10-containerd-net.conflist /etc/cni/net.d/10-containerd-net.conflist.bak ;\nifconfig cni0 down ;\nip link delete cni0\n", "delta": "0:00:00.126983", "end": "2023-04-14 15:08:55.157618", "msg": "non-zero return code", "rc": 1, "start": "2023-04-14 15:08:55.030635", "stderr": "cni0: ERROR while getting interface flags: No such device\nCannot find device \"cni0\"", "stderr_lines": ["cni0: ERROR while getting interface flags: No such device", "Cannot find device \"cni0\""], "stdout": "", "stdout_lines": []}
    ...ignoring
    fatal: [i_hp3dvstf3hxe3zfi5pi4]: FAILED! => {"changed": true, "cmd": "mv /etc/cni/net.d/10-containerd-net.conflist /etc/cni/net.d/10-containerd-net.conflist.bak ;\nifconfig cni0 down ;\nip link delete cni0\n", "delta": "0:00:00.130082", "end": "2023-04-14 15:08:55.495147", "msg": "non-zero return code", "rc": 1, "start": "2023-04-14 15:08:55.365065", "stderr": "cni0: ERROR while getting interface flags: No such device\nCannot find device \"cni0\"", "stderr_lines": ["cni0: ERROR while getting interface flags: No such device", "Cannot find device \"cni0\""], "stdout": "", "stdout_lines": []}
    ...ignoring
    
    TASK [kubernetes : Flush handlers] *****************************************************************************************************************
    
    TASK [kubernetes : Flush handlers] *****************************************************************************************************************
    
    TASK [kubernetes : Flush handlers] *****************************************************************************************************************
    
    RUNNING HANDLER [kubernetes : daemon-reload] *******************************************************************************************************
    ok: [i_hp3dvstf3hxe3zfi5pi3]
    
    RUNNING HANDLER [kubernetes : kubelet-restart] *****************************************************************************************************
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    RUNNING HANDLER [kubernetes : containerd-restart] **************************************************************************************************
    
    TASK [kubernetes : containerd-restart] *************************************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi4]
    skipping: [i_hp3dvstf3hxe3zfi5pi5]
    
    RUNNING HANDLER [kubernetes : containerd-restart] **************************************************************************************************
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : 重建 coredns 容器] **************************************************************************************************************
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    TASK [kubernetes : 修复 scheduler control-manager 端口配置问题] ************************************************************************************
    skipping: [i_hp3dvstf3hxe3zfi5pi4] => (item=/etc/kubernetes/manifests/kube-scheduler.yaml) 
    skipping: [i_hp3dvstf3hxe3zfi5pi4] => (item=/etc/kubernetes/manifests/kube-controller-manager.yaml) 
    skipping: [i_hp3dvstf3hxe3zfi5pi4]
    skipping: [i_hp3dvstf3hxe3zfi5pi5] => (item=/etc/kubernetes/manifests/kube-scheduler.yaml) 
    skipping: [i_hp3dvstf3hxe3zfi5pi5] => (item=/etc/kubernetes/manifests/kube-controller-manager.yaml) 
    skipping: [i_hp3dvstf3hxe3zfi5pi5]
    changed: [i_hp3dvstf3hxe3zfi5pi3] => (item=/etc/kubernetes/manifests/kube-scheduler.yaml)
    changed: [i_hp3dvstf3hxe3zfi5pi3] => (item=/etc/kubernetes/manifests/kube-controller-manager.yaml)
    
    RUNNING HANDLER [kubernetes : daemon-reload] *******************************************************************************************************
    ok: [i_hp3dvstf3hxe3zfi5pi3]
    
    RUNNING HANDLER [kubernetes : kubelet-restart] *****************************************************************************************************
    changed: [i_hp3dvstf3hxe3zfi5pi3]
    
    PLAY RECAP *****************************************************************************************************************************************
    i_hp3dvstf3hxe3zfi5pi3     : ok=19   changed=14   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
    i_hp3dvstf3hxe3zfi5pi4     : ok=7    changed=4    unreachable=0    failed=0    skipped=8    rescued=0    ignored=1   
    i_hp3dvstf3hxe3zfi5pi5     : ok=7    changed=4    unreachable=0    failed=0    skipped=8    rescued=0    ignored=1   

从 master 获取 kube-config 到本地

bash

    $ ansible -i alicloud.py 'i-hp3dvstf3hxe3zfi5pi3' -m fetch -a "src=/root/.kube/config dest=/root/.kube/config flat=true";sed -r -
    i "s/server:.*/server: https:\/\/k8s-master001.yo-yo.fun:6443/g" ~/.kube/config

检查集群状态

bash

    $ kc get cs; kc get node; kc get pods -A; kc get --raw='/readyz?verbose'
    Warning: v1 ComponentStatus is deprecated in v1.19+
    NAME                 STATUS    MESSAGE                         ERROR
    scheduler            Healthy   ok                              
    controller-manager   Healthy   ok                              
    etcd-0               Healthy   {"health":"true","reason":""}   
    
    NAME           STATUS   ROLES                  AGE     VERSION
    k8s-master01   Ready    control-plane,master   3m21s   v1.22.2
    k8s-worker02   Ready    <none>                 2m56s   v1.22.2
    k8s-worker03   Ready    <none>                 2m56s   v1.22.2
    
    
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS        AGE
    kube-flannel   kube-flannel-ds-98f7m                  1/1     Running   0               2m52s
    kube-flannel   kube-flannel-ds-bkl5d                  1/1     Running   0               2m52s
    kube-flannel   kube-flannel-ds-k62v6                  1/1     Running   0               2m52s
    kube-system    coredns-6548b55d4b-86ph9               1/1     Running   0               2m45s
    kube-system    coredns-6548b55d4b-p8p7z               1/1     Running   0               2m45s
    kube-system    etcd-k8s-master01                      1/1     Running   0               3m18s
    kube-system    kube-apiserver-k8s-master01            1/1     Running   0               3m13s
    kube-system    kube-controller-manager-k8s-master01   1/1     Running   2 (2m34s ago)   2m30s
    kube-system    kube-proxy-6pg64                       1/1     Running   0               2m56s
    kube-system    kube-proxy-9d796                       1/1     Running   0               3m3s
    kube-system    kube-proxy-k8wv6                       1/1     Running   0               2m56s
    kube-system    kube-scheduler-k8s-master01            1/1     Running   2 (2m34s ago)   2m30s
    
    
    [+]ping ok
    [+]log ok
    [+]etcd ok
    [+]informer-sync ok
    [+]poststarthook/start-kube-apiserver-admission-initializer ok
    [+]poststarthook/generic-apiserver-start-informers ok
    [+]poststarthook/priority-and-fairness-config-consumer ok
    [+]poststarthook/priority-and-fairness-filter ok
    [+]poststarthook/start-apiextensions-informers ok
    [+]poststarthook/start-apiextensions-controllers ok
    [+]poststarthook/crd-informer-synced ok
    [+]poststarthook/bootstrap-controller ok
    [+]poststarthook/rbac/bootstrap-roles ok
    [+]poststarthook/scheduling/bootstrap-system-priority-classes ok
    [+]poststarthook/priority-and-fairness-config-producer ok
    [+]poststarthook/start-cluster-authentication-info-controller ok
    [+]poststarthook/aggregator-reload-proxy-client-cert ok
    [+]poststarthook/start-kube-aggregator-informers ok
    [+]poststarthook/apiservice-registration-controller ok
    [+]poststarthook/apiservice-status-available-controller ok
    [+]poststarthook/kube-apiserver-autoregistration ok
    [+]autoregister-completion ok
    [+]poststarthook/apiservice-openapi-controller ok
    [+]shutdown ok
    readyz check passed

OK，集群初始化完成

下列是接下来会用到的相关镜像，可以提前拉取下，避免后面再等着

bash

    ctr --namespace k8s.io images pull  docker.io/vicoriametrics/vmstorage:v1.77.0-cluster
    ctr --namespace k8s.io images pull  docker.io/prom/prometheus:v2.35.0
    ctr --namespace k8s.io images pull  docker.io/prom/node-exporter:v1.5.0
    ctr --namespace k8s.io images pull  docker.io/grafana/grafana:9.4.7
    ctr --namespace k8s.io images pull  docker.io/victoriametrics/vmselect:v1.77.0-cluster
    ctr --namespace k8s.io images pull  docker.io/victoriametrics/vminsert:v1.77.0-cluster
    ctr --namespace k8s.io images pull  docker.io/victoriametrics/vmagent:v1.77.0
    ctr --namespace k8s.io images pull  docker.io/victoriametrics/vmalert:v1.77.0
    ctr --namespace k8s.io images pull  docker.io/prom/alertmanager:v0.25.0
    ctr --namespace k8s.io images pull  docker.io/lotusching/promoter:latest

#### [](#namespace "namespace")namespace

资源定义

yaml

    # ns.yml
    apiVersion: v1
    kind: Namespace
    metadata:
      # 命名空间名称
      name: kube-vm

创建资源

bash

    $ kc apply -f ns.yml    
    namespace/kube-vm created

#### [](#rbac "rbac")rbac

资源定义

yaml

    # rbac.yml
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: vmagent-sa
      namespace: kube-vm
    
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: vmagent
    rules:
      - apiGroups: ["", "networking.k8s.io", "extensions"]
        resources:
          - nodes
          - nodes/metrics
          - services
          - endpoints
          - endpointslices
          - pods
          - app
          - ingresses
        verbs: ["get", "list", "watch"]
      - apiGroups: [""]
        resources:
          - namespaces
          - configmaps
        verbs: ["get"]
      - nonResourceURLs: ["/metrics", "/metrics/resources"]
        verbs: ["get"]
    
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: vmagent
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: vmagent
    subjects:
      - kind: ServiceAccount
        name: vmagent-sa
        namespace: kube-vm

创建资源，ServiceAccount 用以从 Kubernetes 自动发现监控目标，包括：Node、Pod、Service 等

bash

    $ kc apply -f rbac.yml    
    serviceaccount/vmagent-sa created
    clusterrole.rbac.authorization.k8s.io/vmagent created
    clusterrolebinding.rbac.authorization.k8s.io/vmagent created

#### [](#storageclass "storageclass")storageclass

资源定义

这里为了方面测试使用 LocalPath 作为本地存储

yaml

    # storageclass.yml 
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: local-storage
    provisioner: kubernetes.io/no-provisioner
    # 延迟绑定：等到第一个声明使用该 PVC 的 Pod 开始调度绑定
    volumeBindingMode: WaitForFirstConsumer

创建资源

bash

    $ kc apply -f storageclass.yml    
    storageclass.storage.k8s.io/local-storage created

#### [](#node-exporter "node_exporter")node_exporter

资源定义

yaml

    # node_exporter.yml
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: node-exporter
      namespace: kube-vm
    spec:
      selector:
        matchLabels:
          app: node-exporter
      template:
        metadata:
          labels:
            app: node-exporter
        spec:
          hostPID: true
          hostIPC: true
          hostNetwork: true
          nodeSelector:
            kubernetes.io/os: linux
          containers:
            - name: node-exporter
              image: prom/node-exporter:v1.5.0
              args:
                - --web.listen-address=0.0.0.0:9110
                - --path.procfs=/host/proc
                - --path.sysfs=/host/sys
                - --path.rootfs=/host/root
                - --collector.filesystem.ignored-mount-points=^/(proc|var/lib/containerd/.+|/var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)
                - --collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$
                - --collector.textfile
                - --collector.netdev.device-exclude="^(lo|docker[0-9]|veth.+)$"
                - --collector.systemd
                - --collector.systemd.unit-whitelist="(docker|ssh).service"
                - --collector.conntrack
                - --collector.cpu
                - --collector.diskstats
                - --collector.filefd
                - --collector.filesystem
                - --collector.loadavg
                - --collector.meminfo
                - --collector.netdev
                - --collector.netstat
                - --collector.ntp
                - --collector.sockstat
                - --collector.stat
                - --collector.time
                - --collector.uname
                - --collector.vmstat
                - --collector.tcpstat
                - --collector.xfs
                - --collector.zfs
                - --no-collector.arp
                - --no-collector.bcache
                - --no-collector.bonding
                - --no-collector.buddyinfo
                - --no-collector.drbd
                - --no-collector.edac
                - --no-collector.entropy
                - --no-collector.hwmon
                - --no-collector.infiniband
                - --no-collector.interrupts
                - --no-collector.ipvs
                - --no-collector.ksmd
                - --no-collector.logind
                - --no-collector.mdadm
                - --no-collector.meminfo_numa
                - --no-collector.mountstats
                - --no-collector.nfs
                - --no-collector.nfsd
                - --no-collector.qdisc
                - --no-collector.runit
                - --no-collector.supervisord
                - --no-collector.timex
                - --no-collector.wifi
              ports:
                - containerPort: 9110
              env:
                - name: HOSTIP
                  valueFrom:
                    fieldRef:
                      fieldPath: status.hostIP
              resources:
                requests:
                  cpu: 150m
                  memory: 180Mi
                limits:
                  cpu: 150m
                  memory: 180Mi
              securityContext:
                runAsUser: 65534
                runAsNonRoot: true
              volumeMounts:
                - mountPath: /host/proc
                  name: proc
                - mountPath: /host/sys
                  name: sys
                - mountPath: /host/root
                  name: root
                  readOnly: true
                  mountPropagation: HostToContainer
                - mountPath: /var/run/dbus/system_bus_socket
                  name: system-dbus-socket
                  readOnly: true
    
          tolerations:
            - operator: "Exists"
          volumes:
            - name: proc
              hostPath:
                path: /proc
            - name: dev
              hostPath:
                path: /dev
            - name: sys
              hostPath:
                path: /sys
            - name: root
              hostPath:
                path: /
            - name: system-dbus-socket
              hostPath:
                path: /var/run/dbus/system_bus_socket

创建资源

bash

    $ kc apply -f node-exporter.yml 
    daemonset.apps/node-exporter created
    
    $ kc get ds -n kube-vm 
    NAME    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR    AGE
    node-exporter   3    3    2    3    2    kubernetes.io/os=linux   29s

#### [](#vmstore "vmstore")vmstore

唯一真正有状态的服务，这里使用 LocalPath 类型 PV，节点亲和性选的 `k8s-worker02`，数据目录在 `/data/k8s/vmstore`，各 vmstorage 写入数据时，会写到各自 `vmstore/<POD_NAME>` 下

bash

    $ mkdir -p /data/k8s/vmstore

资源定义

yaml

    # vmstore.yml
    ---
    apiVersion: v1
    kind: Service
    metadata:
      # headless 的 service 名称
      name: cluster-vmstorage
      namespace: kube-vm
      labels:
        app: vmstorage
    spec:
      type: ClusterIP
      # headless 无头 Service
      clusterIP: None
      selector:
        app: vmstorage
      ports:
        - port: 8482
          targetPort: http
          name: http
        - port: 8401
          targetPort: vmselect
          name: vmselect
        - port: 8400
          targetPort: vminsert
          name: vminsert
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: vmstore-local-pv
      namespace: kube-vm
      labels:
        app: vmstorage
    spec:
      accessModes:
        - ReadWriteMany
      capacity:
        storage: 20Gi
      storageClassName: local-storage
      local:
        # 目录需要提前在 k8s-worker02 创建
        path: /data/k8s/vmstore
      persistentVolumeReclaimPolicy: Retain
      nodeAffinity:
        required:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values:
                    # 节点亲和性选择 k8s-worker02
                    - k8s-worker02
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: vmstore-local-pvc
      namespace: kube-vm
      labels:
        app: vmstorage
    spec:
      storageClassName: local-storage
      selector:
        matchLabels:
          app: vmstorage
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 20Gi
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: vmstorage
      namespace: kube-vm
      labels:
        app: vmstorage
    spec:
      serviceName: cluster-vmstorage
      selector:
        matchLabels:
          app: vmstorage
      replicas: 2
      podManagementPolicy: OrderedReady
      template:
        metadata:
          labels:
            app: vmstorage
        spec:
          volumes:
            - name: storage
              persistentVolumeClaim:
                claimName: vmstore-local-pvc
          containers:
            - name: vmstorage
              image: "victoriametrics/vmstorage:v1.77.0-cluster"
              imagePullPolicy: "IfNotPresent"
              env:
                - name: POD_NAME
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.name
              volumeMounts:
                - name: storage
                  mountPath: /storage
              args:
                - "--retentionPeriod=60d"
                # 不同实例接受的数据写入到不同目录
                - "--storageDataPath=/storage/$(POD_NAME)"
                - --envflag.enable=true
                - --envflag.prefix=VM_
                - --loggerFormat=json
                # 清理重复数据，与 scrape_interval 保持一致
                - --dedup.minScrapeInterval=15s
              ports:
                - name: http
                  containerPort: 8482
                - name: vminsert
                  containerPort: 8400
                - name: vmselect
                  containerPort: 8401
              livenessProbe:
                failureThreshold: 10
                initialDelaySeconds: 30
                periodSeconds: 30
                tcpSocket:
                  port: http
                timeoutSeconds: 5
              readinessProbe:
                failureThreshold: 3
                initialDelaySeconds: 5
                periodSeconds: 15
                timeoutSeconds: 5
                httpGet:
                  path: /health
                  port: http

创建资源

bash

    $ kc apply -f vmstore.yml     
    service/cluster-vmstorage created
    persistentvolume/vmstore-local-pv created
    persistentvolumeclaim/vmstore-local-pvc created
    statefulset.apps/vmstorage created

观察状态

bash

    $ kc get sts -n kube-vm 
    NAME    READY   AGE
    vmstorage   2/2     81s
    
    $ kc -n kube-vm logs -l app=vmstorage
    {"ts":"2023-04-14T03:01:50.018Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:832","msg":"nothing to load from \"/storage/vmstorage-0/cache/next_day_metric_ids\""}
    {"ts":"2023-04-14T03:01:50.035Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:259","msg":"opening table \"/storage/vmstorage-0/indexdb/1755ADF679474FBF\"..."}
    {"ts":"2023-04-14T03:01:50.048Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:294","msg":"table \"/storage/vmstorage-0/indexdb/1755ADF679474FBF\" has been opened in 0.012 seconds; partsCount: 0; blocksCount: 0, itemsCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T03:01:50.049Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:259","msg":"opening table \"/storage/vmstorage-0/indexdb/1755ADF679474FBE\"..."}
    {"ts":"2023-04-14T03:01:50.064Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:294","msg":"table \"/storage/vmstorage-0/indexdb/1755ADF679474FBE\" has been opened in 0.016 seconds; partsCount: 0; blocksCount: 0, itemsCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T03:01:50.094Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/main.go:92","msg":"successfully opened storage \"/storage/vmstorage-0\" in 0.093 seconds; partsCount: 0; blocksCount: 0; rowsCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T03:01:50.094Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:152","msg":"accepting vmselect conns at 0.0.0.0:8401"}
    {"ts":"2023-04-14T03:01:50.094Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:85","msg":"accepting vminsert conns at 0.0.0.0:8400"}
    {"ts":"2023-04-14T03:01:50.094Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:88","msg":"starting http server at http://127.0.0.1:8482/"}
    {"ts":"2023-04-14T03:01:50.095Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:89","msg":"pprof handlers are exposed at http://127.0.0.1:8482/debug/pprof/"}
    {"ts":"2023-04-14T03:02:05.011Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:832","msg":"nothing to load from \"/storage/vmstorage-1/cache/next_day_metric_ids\""}
    {"ts":"2023-04-14T03:02:05.030Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:259","msg":"opening table \"/storage/vmstorage-1/indexdb/1755ADF9F68785C1\"..."}
    {"ts":"2023-04-14T03:02:05.043Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:294","msg":"table \"/storage/vmstorage-1/indexdb/1755ADF9F68785C1\" has been opened in 0.013 seconds; partsCount: 0; blocksCount: 0, itemsCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T03:02:05.045Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:259","msg":"opening table \"/storage/vmstorage-1/indexdb/1755ADF9F68785C0\"..."}
    {"ts":"2023-04-14T03:02:05.069Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:294","msg":"table \"/storage/vmstorage-1/indexdb/1755ADF9F68785C0\" has been opened in 0.023 seconds; partsCount: 0; blocksCount: 0, itemsCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T03:02:05.091Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/main.go:92","msg":"successfully opened storage \"/storage/vmstorage-1\" in 0.104 seconds; partsCount: 0; blocksCount: 0; rowsCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T03:02:05.092Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:85","msg":"accepting vminsert conns at 0.0.0.0:8400"}
    {"ts":"2023-04-14T03:02:05.092Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:88","msg":"starting http server at http://127.0.0.1:8482/"}
    {"ts":"2023-04-14T03:02:05.092Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:152","msg":"accepting vmselect conns at 0.0.0.0:8401"}
    {"ts":"2023-04-14T03:02:05.092Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:89","msg":"pprof handlers are exposed at http://127.0.0.1:8482/debug/pprof/"}

#### [](#vmselect "vmselect")vmselect

vmselect 负责提供数据查询接口，例如给 Grafana 查询渲染看板数据

vmselect 基本可以看做是无状态的，不过它本身提供了 cache 功能，这部分是带点状态的，但假如可以接受缓存丢失，数据查询回源的话，那么可以直接 deployment 部署，如果想要保存下来，也可以使用 statufulset 挂个 pv、pvc 进行部署

vmselect 服务最重要的参数：`--storageNode=`，通过该参数指定所有的 vmstorage 节点地址，由于 vmstorage 是用 StatefulSet 部署的，Pod 名称是固定的，所以这里使用的是 FQDN 形式访问 `vmstorage-0.cluster-vmstorage.kube-vm.svc.cluster.local:8401`

资源定义

yaml

    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: vmselect
      namespace: kube-vm
      labels:
        app: vmselect
    spec:
      type: NodePort
      selector:
        app: vmselect
      ports:
        - name: http
          port: 8481
          targetPort: http
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: vmselect
      namespace: kube-vm
      labels:
        app: vmselect
    spec:
      selector:
        matchLabels:
          app: vmselect
      template:
        metadata:
          labels:
            app: vmselect
        spec:
          volumes:
            - name: cache-volume
              emptyDir: {}
          containers:
            - name: vmselect
              image: "victoriametrics/vmselect:v1.77.0-cluster"
              imagePullPolicy: "IfNotPresent"
              volumeMounts:
                - name: cache-volume
                  mountPath: /cache
              args:
                - "--cacheDataPath=/cache"
                # 逐一显式指明 vmstorage 节点地址
                - --storageNode=vmstorage-0.cluster-vmstorage.kube-vm.svc.cluster.local:8401
                - --storageNode=vmstorage-1.cluster-vmstorage.kube-vm.svc.cluster.local:8401
                - --envflag.enable=true
                - --envflag.prefix=VM_
                - --loggerFormat=json
                # 清理重复数据，与 scrape_interval 保持一致
                - --dedup.minScrapeInterval=15s
              ports:
                - name: http
                  containerPort: 8481
              readinessProbe:
                httpGet:
                  path: /health
                  port: http
                initialDelaySeconds: 5
                periodSeconds: 15
                timeoutSeconds: 5
                failureThreshold: 3
              livenessProbe:
                tcpSocket:
                  port: http
                initialDelaySeconds: 5
                periodSeconds: 15
                timeoutSeconds: 5
                failureThreshold: 3

创建资源

bash

    $ kc apply -f vmselect.yml    
    service/vmselect created
    deployment.apps/vmselect created

观察状态

bash

    $ kc get deploy -n kube-vm -l app=vmselect
    NAME    READY   UP-TO-DATE   AVAILABLE   AGE
    vmselect   1/1     1    1    24s
    
    $ kc -n kube-vm logs -l app=vmselect
    {"ts":"2023-04-14T03:04:52.146Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"envflag.prefix\"=\"VM_\""}
    {"ts":"2023-04-14T03:04:52.146Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"loggerFormat\"=\"json\""}
    {"ts":"2023-04-14T03:04:52.146Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"storageNode\"=\"vmstorage-0.cluster-vmstorage.kube-vm.svc.cluster.local:8401,vmstorage-1.cluster-vmstorage.kube-vm.svc.cluster.local:8401\""}
    {"ts":"2023-04-14T03:04:52.146Z","level":"info","caller":"VictoriaMetrics/app/vmselect/main.go:74","msg":"starting netstorage at storageNodes [vmstorage-0.cluster-vmstorage.kube-vm.svc.cluster.local:8401 vmstorage-1.cluster-vmstorage.kube-vm.svc.cluster.local:8401]"}
    {"ts":"2023-04-14T03:04:52.147Z","level":"info","caller":"VictoriaMetrics/app/vmselect/main.go:81","msg":"started netstorage in 0.000 seconds"}
    {"ts":"2023-04-14T03:04:52.151Z","level":"info","caller":"VictoriaMetrics/lib/memory/memory.go:42","msg":"limiting caches to 5010650726 bytes, leaving 3340433818 bytes to the OS according to -memory.allowedPercent=60"}
    {"ts":"2023-04-14T03:04:52.151Z","level":"info","caller":"VictoriaMetrics/app/vmselect/promql/rollup_result_cache.go:63","msg":"loading rollupResult cache from \"/cache/rollupResult\"..."}
    {"ts":"2023-04-14T03:04:52.152Z","level":"info","caller":"VictoriaMetrics/app/vmselect/promql/rollup_result_cache.go:89","msg":"loaded rollupResult cache from \"/cache/rollupResult\" in 0.002 seconds; entriesCount: 0, sizeBytes: 0"}
    {"ts":"2023-04-14T03:04:52.153Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:88","msg":"starting http server at http://127.0.0.1:8481/"}
    {"ts":"2023-04-14T03:04:52.154Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:89","msg":"pprof handlers are exposed at http://127.0.0.1:8481/debug/pprof/"}

#### [](#vminsert "vminsert")vminsert

vminsert 主要负责提供 remote write 接口，接收来自 vmagent、vmalert、prometheus 采集（生成）的数据，根据标签的一致性哈希，将数据分散存储到 `vmstorage` 节点，它是无状态的，所以当我们想要提高数据接收最大速度的时候，可以很简便的进行横向扩容

资源定义

yaml

    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: vminsert
      namespace: kube-vm
      labels:
        app: vminsert
    spec:
      type: ClusterIP
      selector:
        app: vminsert
      ports:
        - name: http
          port: 8480
          targetPort: http
    
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: vminsert
      namespace: kube-vm
      labels:
        app: vminsert
    spec:
      selector:
        matchLabels:
          app: vminsert
      template:
        metadata:
          labels:
            app: vminsert
        spec:
          containers:
            - name: vminsert
              image: "victoriametrics/vminsert:v1.77.0-cluster"
              imagePullPolicy: "IfNotPresent"
              args:
                # 与 vmselect 一样，逐一指明 vmstore Pod 地址
                - --storageNode=vmstorage-0.cluster-vmstorage.kube-vm.svc.cluster.local:8400
                - --storageNode=vmstorage-1.cluster-vmstorage.kube-vm.svc.cluster.local:8400
                - --envflag.enable=true
                - --envflag.prefix=VM_
                - --loggerFormat=json
              ports:
                - name: http
                  containerPort: 8480
              readinessProbe:
                httpGet:
                  path: /health
                  port: http
                initialDelaySeconds: 5
                periodSeconds: 15
                timeoutSeconds: 5
                failureThreshold: 3
              livenessProbe:
                tcpSocket:
                  port: http
                initialDelaySeconds: 5
                periodSeconds: 15
                timeoutSeconds: 5
                failureThreshold: 3

创建资源

bash

    $ kc apply -f vminsert.yml    
    service/vminsert created
    deployment.apps/vminsert created

观察状态

bash

    $ kc get deploy -n kube-vm -l app=vminsert
    NAME    READY   UP-TO-DATE   AVAILABLE   AGE
    vminsert   1/1     1    1    16s
    
    $ kc -n kube-vm logs -l app=vminsert    
    {"ts":"2023-04-14T03:08:26.447Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"envflag.prefix\"=\"VM_\""}
    {"ts":"2023-04-14T03:08:26.447Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"loggerFormat\"=\"json\""}
    {"ts":"2023-04-14T03:08:26.447Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"storageNode\"=\"vmstorage-0.cluster-vmstorage.kube-vm.svc.cluster.local:8400,vmstorage-1.cluster-vmstorage.kube-vm.svc.cluster.local:8400\""}
    {"ts":"2023-04-14T03:08:26.447Z","level":"info","caller":"VictoriaMetrics/app/vminsert/main.go:78","msg":"initializing netstorage for storageNodes [vmstorage-0.cluster-vmstorage.kube-vm.svc.cluster.local:8400 vmstorage-1.cluster-vmstorage.kube-vm.svc.cluster.local:8400]..."}
    {"ts":"2023-04-14T03:08:26.447Z","level":"info","caller":"VictoriaMetrics/lib/memory/memory.go:42","msg":"limiting caches to 5010650726 bytes, leaving 3340433818 bytes to the OS according to -memory.allowedPercent=60"}
    {"ts":"2023-04-14T03:08:26.447Z","level":"info","caller":"VictoriaMetrics/app/vminsert/main.go:91","msg":"successfully initialized netstorage in 0.001 seconds"}
    {"ts":"2023-04-14T03:08:26.448Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:88","msg":"starting http server at http://127.0.0.1:8480/"}
    {"ts":"2023-04-14T03:08:26.448Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:89","msg":"pprof handlers are exposed at http://127.0.0.1:8480/debug/pprof/"}
    {"ts":"2023-04-14T03:08:26.653Z","level":"info","caller":"VictoriaMetrics/app/vminsert/netstorage/netstorage.go:260","msg":"successfully dialed -storageNode=\"vmstorage-0.cluster-vmstorage.kube-vm.svc.cluster.local:8400\""}
    {"ts":"2023-04-14T03:08:26.654Z","level":"info","caller":"VictoriaMetrics/app/vminsert/netstorage/netstorage.go:260","msg":"successfully dialed -storageNode=\"vmstorage-1.cluster-vmstorage.kube-vm.svc.cluster.local:8400\""}

#### [](#vmagent "vmagent")vmagent

vmagent 取代 prometheus，负责自动发现、采集指标数据（不包含 record 持久化指标），vmagent 稍微带一点状态，这是一位 vmagent 提供了一个提高健壮性的参数 `-remoteWrite.tmpDataPath`，参数作用是 当 vminsert 不可用时（无可用实例），暂时先写到本地，待 vminsert 恢复可用后，再逐步将本地同步到 vminsert

所以，这里要用 sts 部署，并挂上一个小点的 pv、pvc

资源定义 configMap，仅包含 vmagent 服务本身配置、自动发现配置，不包含 持久化规则、告警规则

yaml

    # configmap-vmagent-config.yml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      # name: vmagent-config
      name: configmap-vmagent-config
      namespace: kube-vm
    data:
      scrape.yml: |
        global:
          scrape_interval: 15s
          scrape_timeout: 15s
    
        scrape_configs:
        - job_name: nodes
          kubernetes_sd_configs:
            - role: node
          relabel_configs:
          # 修改默认 10250 端口采集为 自定义的 node_exporter 9110 端口
          - source_labels: [__address__]
            regex: "(.*):10250"
            replacement: "${1}:9110"
            target_label: __address__
            action: replace
          # # 映射 Node 的 Label 标签
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
    
        - job_name: apiserver
          scheme: https
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            insecure_skip_verify: true
          kubernetes_sd_configs:
          - role: endpoints
          relabel_configs:
          - action: keep
            # 根据正则过滤出 apiserver 服务组件的 endpoint
            regex: apiserver
            source_labels: [__meta_kubernetes_service_label_component]
    
        - job_name: cadvisor
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          scheme: https
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            # 跳过证书校验
            insecure_skip_verify: true
          kubernetes_sd_configs:
          - role: node
          relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
          - replacement: /metrics/cadvisor
            target_label: __metrics_path__
    
        - job_name: pod
          kubernetes_sd_configs:
          - role: endpoints
          relabel_configs:
          - action: drop
            regex: true
            source_labels:
            - __meta_kubernetes_pod_container_init
          # 用以判断注解提供的端口，是否匹配容器暴露的端口，避免编写时端口不一致，导致采集失败
          - action: keep_if_equal
            source_labels:
            - __meta_kubernetes_service_annotation_prometheus_io_port
            - __meta_kubernetes_pod_container_port_number
          - action: keep
            regex: true
            source_labels:
            - __meta_kubernetes_service_annotation_prometheus_io_scrape
          # 匹配 http、https 格式的协议头，替换到 __scheme__ 标签，用以抓取数据时使用正确的协议
          - action: replace
            regex: (https?)
            source_labels:
            - __meta_kubernetes_service_annotation_prometheus_io_scheme
            target_label: __scheme__
          # 匹配路径，替换到 __scheme__ 标签，用以抓取数据时使用正确的路径
          - action: replace
            regex: (.+)
            source_labels:
            - __meta_kubernetes_service_annotation_prometheus_io_path
            target_label: __metrics_path__
          # 通过注解获取地址、端口
          - action: replace
            # ([^:]+) 非:开头出现一到多次，匹配 IP 地址
            # (?::\d+)? 不保存子组，:\d+，匹配 :port 出现 0 到 1次
            # (\d+) 端口
            regex: ([^:]+)(?::\d+)?;(\d+)
            # 根据匹配分组生成新数据
            replacement: $1:$2
            source_labels:
            - __address__
            - __meta_kubernetes_service_annotation_prometheus_io_port
            # 使用包含新地址数据的 __address__ 标签采集数据
            target_label: __address__
          # 标签映射，将符合规则的多个标签，统一映射出来
          - action: labelmap
            regex: __meta_kubernetes_service_label_(.+)
          # 生成包含 pod 名称的 pod 标签，用以标识数据属于那个 pod
          - source_labels:
            - __meta_kubernetes_pod_name
            target_label: pod
          # 生成包含命名空间名称的 namespace 标签，用以标识数据属于那个 命名空间
          - source_labels:
            - __meta_kubernetes_namespace
            target_label: namespace
          # 生成包含服务名称的 service 标签，用以标识数据属于那个服务
          - source_labels:
            - __meta_kubernetes_service_name
            target_label: service
          - replacement: ${1}
            source_labels:
            - __meta_kubernetes_service_name
            target_label: job
          # 生成包含节点名称的 node 标签，用以标识数据属于那个 宿主机节点
          - action: replace
            source_labels:
            - __meta_kubernetes_pod_node_name
            target_label: node

vmagent 使用的是 LocalPath ，所以这里提前在 `k8s-worker03` 创建目录

bash

    $ mkdir -p /data/k8s/vmagent

资源定义

yaml

    # vmagent.yml
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: vmagent-pv
      namespace: kube-vm
      labels:
        app: vmagent
    spec:
      # 动态存储类名称
      storageClassName: local-storage
      # 删除 PVC 的时候，PV和 不会被删除，需要手动删除
      persistentVolumeReclaimPolicy: Retain
      # 配置 PV 支持的访问模式
      accessModes:
        # 允许多个节点挂载
        - ReadWriteMany
      capacity:
        # 提供的容量
        storage: 2Gi
      # 宿主机路径
      local:
        path: /data/k8s/vmagent
      nodeAffinity:
        required:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values: ["k8s-worker03"]
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: vmagent-pvc
      namespace: kube-vm
      labels:
        app: vmagent
    spec:
      storageClassName: local-storage
      selector:
        matchLabels:
          app: vmagent
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 2Gi
    
    
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: vmagent
      namespace: kube-vm
      annotations:
        # 设置注解，用以自动发现并采集自身指标
        prometheus.io/scrape: "true"
        prometheus.io/port: "8429"
    spec:
      selector:
        app: vmagent
      # 无头服务，用以发现 vmagent 实例
      clusterIP: None
      ports:
        - name: http
          port: 8429
          targetPort: http
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: vmagent
      namespace: kube-vm
      labels:
        app: vmagent
    spec:
      replicas: 2
      serviceName: vmagent
      selector:
        matchLabels:
          app: vmagent
      template:
        metadata:
          labels:
            app: vmagent
        spec:
          serviceAccountName: vmagent-sa
          volumes:
            - name: config
              configMap:
                name: configmap-vmagent-config
            - name: tmpdata
              persistentVolumeClaim:
                claimName: vmagent-pvc
          containers:
            - name: agent
              image: victoriametrics/vmagent:v1.77.0
              imagePullPolicy: IfNotPresent
              env:
                - name: POD_NAME
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.name
              volumeMounts:
                - name: tmpdata
                  mountPath: /tmpData
                - name: config
                  mountPath: /config
              args:
                - -promscrape.config=/config/scrape.yml
                # 当后端 insert 节点不可用时，临时写到该目录，insert 恢复可用后，再继续同步
                # 由于使用的是 LocalPath 所以这里用 $(POD_NAME) 分开一下
                - -remoteWrite.tmpDataPath=/tmpData/$(POD_NAME)
                # vmagent 实例的数量
                - -promscrape.cluster.membersCount=2
                # - -promscrape.cluster.replicationFactor=2 # 可以配置副本数
                # vmagent 实例成员 ID
                - -promscrape.cluster.memberNum=$(POD_NAME)
                - -remoteWrite.url=http://vminsert:8480/insert/0/prometheus
                # 允许提供环境变量设置参数
                - -envflag.enable=true
                # 环境变量前缀设置
                - -envflag.prefix=VM_
                - -loggerFormat=json
              ports:
                - name: http
                  containerPort: 8429

创建资源

bash

    $ kc apply -f configmap-vmagent-config.yml    
    configmap/configmap-vmagent-config created
    
    $ kc apply -f vmagent.yml    
    persistentvolume/vmagent-pv created
    persistentvolumeclaim/vmagent-pvc created
    service/vmagent created
    statefulset.apps/vmagent created

观察状态

bash

    $ kc get sts -n kube-vm -l app=vmagent
    NAME    READY   AGE
    vmagent   2/2     38s
    
    $
    {"ts":"2023-04-14T03:22:12.118Z","level":"info","caller":"VictoriaMetrics/lib/promscrape/discovery/kubernetes/api_watcher.go:589","msg":"reloaded 7 objects from \"https://10.96.0.1:443/api/v1/endpoints\" in 0.015s; updated=0, removed=0, added=7, resourceVersion=\"3339\""}
    {"ts":"2023-04-14T03:22:12.119Z","level":"info","caller":"VictoriaMetrics/lib/promscrape/discovery/kubernetes/api_watcher.go:589","msg":"reloaded 7 objects from \"https://10.96.0.1:443/api/v1/services\" in 0.016s; updated=0, removed=0, added=7, resourceVersion=\"3339\""}
    {"ts":"2023-04-14T03:22:12.120Z","level":"info","caller":"VictoriaMetrics/lib/promscrape/discovery/kubernetes/api_watcher.go:589","msg":"reloaded 3 objects from \"https://10.96.0.1:443/api/v1/nodes\" in 0.016s; updated=0, removed=0, added=3, resourceVersion=\"3339\""}
    {"ts":"2023-04-14T03:22:12.120Z","level":"info","caller":"VictoriaMetrics/lib/promscrape/discovery/kubernetes/api_watcher.go:589","msg":"reloaded 22 objects from \"https://10.96.0.1:443/api/v1/pods\" in 0.017s; updated=0, removed=0, added=22, resourceVersion=\"3339\""}
    {"ts":"2023-04-14T03:22:41.053Z","level":"info","caller":"VictoriaMetrics/lib/promscrape/scraper.go:393","msg":"kubernetes_sd_configs: added targets: 4, removed targets: 0; total targets: 4"}

配置完负责采集指标的 vmagent 后，通过 vmselect 提供 vmui 试着查询下指标数据

获取 vmselect 外部端口

bash

    $ kc get svc -n kube-vm
    
    NAME       TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
    vmselect   NodePort   10.103.106.255   <none>        8481:32515/TCP   21m

访问 WebUI（[http://ip:32515/select/0/vmui），查询数据](http://ip:32515/select/0/vmui%EF%BC%89%EF%BC%8C%E6%9F%A5%E8%AF%A2%E6%95%B0%E6%8D%AE)

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304141125211.png)

同时，也可以到 亲和性节点 k8s-worker03 上查看数据目录

bash

    $ hostname
    k8s-worker03
    
    $ pwd
    /data/k8s
    
    $ tree vmagent 
    vmagent
    ├── vmagent-0
    │   └── persistent-queue
    │       └── 1_F7AB42DA6C66E8E1
    │      ├── 0000000000000000
    │      └── metainfo.json
    └── vmagent-1
        └── persistent-queue
        └── 1_F7AB42DA6C66E8E1
        ├── 0000000000000000
        └── metainfo.json
    
    6 directories, 4 files

除此外，还可以观察下 vmstorage 的数据存储，这部分数据是存在 k8s-worker02 节点

bash

    $ tree vmstore -L 3
    vmstore
    ├── vmstorage-0
    │   ├── data
    │   │   ├── big
    │   │   ├── flock.lock
    │   │   └── small
    │   ├── flock.lock
    │   ├── indexdb
    │   │   ├── 1755ADF679474FBE
    │   │   ├── 1755ADF679474FBF
    │   │   └── snapshots
    │   ├── metadata
    │   │   └── minTimestampForCompositeIndex
    │   └── snapshots
    └── vmstorage-1
        ├── data
        │   ├── big
        │   ├── flock.lock
        │   └── small
        ├── flock.lock
        ├── indexdb
        │   ├── 1755ADF9F68785C0
        │   ├── 1755ADF9F68785C1
        │   └── snapshots
        ├── metadata
        │   └── minTimestampForCompositeIndex
        └── snapshots
    
    20 directories, 6 files

OK，确实数据也过来了，按照 Pod 名称分别写到不同目录去了

#### [](#alertmanager "alertmanager")alertmanager

资源定义 ConfigMap

这里仅做了基本配置，告警媒介走的是 一个开源的 webhook 服务 promoter

yaml

    # configmap-alertmanager-config.yml
    
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: configmap-alertmanager-config
      namespace: kube-vm
    data:
      alertmanager.yml: |
        global:
          # 当 alertmanager 持续多长时间未接收到告警后标记告警状态为 resolved
          resolve_timeout: 5m
        # 告警路由
        route:
          # 这里的标签列表是接收到报警信息后的重新分组标签
          # 如，接收到的报警信息里有许多具有 instance=A 和 alertname=xx 这样标签的报警信息将会批量被聚合到一个分组里面
          group_by: ['instance', 'alertname']
          group_wait: 1s
          group_interval: 10s
          # 警报重复间隔，每2分钟重复一次警报
          repeat_interval: 2m
          # 警报接收端，这里配置为下面定义的钩子
          receiver: 'promoter-webhook-wechat'
          routes:
          - match_re:
              # severity: ^(error|critical)$
              severity: ^(critical)$
            receiver: promoter-webhook-dingtalk
            continue: true
        receivers:
          - name: 'promoter-webhook-dingtalk'
            webhook_configs:
            - url: "http://promoter:9194/dingtalk/send"
              send_resolved: true
          - name: 'promoter-webhook-wechat'
            webhook_configs:
            - url: "http://promoter:9194/wechat/send"
              send_resolved: true

资源定义

yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: alertmanager
      namespace: kube-vm
      labels:
        app: alertmanager
    spec:
      selector:
        app: alertmanager
      type: ClusterIP
      ports:
        - port: 9193
          targetPort: http
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: alertmanager
      namespace: kube-vm
      labels:
        app: alertmanager
    spec:
      selector:
        matchLabels:
          app: alertmanager
      template:
        metadata:
          labels:
            app: alertmanager
        spec:
          volumes:
            - name: alertmanager-config
              configMap:
                name: configmap-alertmanager-config
          containers:
            - name: alertmanager
              image: prom/alertmanager:v0.25.0
              imagePullPolicy: IfNotPresent
              args:
                - "--config.file=/etc/alertmanager/alertmanager.yml"
              ports:
                - containerPort: 9093
                  name: http
              volumeMounts:
                - mountPath: "/etc/alertmanager"
                  name: alertmanager-config
              resources:
                requests:
                  cpu: 100m
                  memory: 256Mi
                limits:
                  cpu: 100m
                  memory: 256Mi

创建资源

bash

    $ kc apply -f configmap-alertmanager-config.yml
    $ kc apply -f alertmanager.yml
    
    $ kc -n kube-vm get deploy -l app=alertmanager
    NAME    READY   UP-TO-DATE   AVAILABLE   AGE
    alertmanager   1/1     1    1    3m48s

#### [](#promoter "promoter")promoter

promoter 配置文件 promoter-config.yml

yaml

    ---
    global:
      dingtalk_api_token: xxx
      dingtalk_api_secret: xxx
      wechat_api_secret: xxx-xxx
      wechat_api_corp_id: xxx
    s3:
      # 阿里云 OSS，用以保存生成的图片
      access_key: "xxx"
      secret_key: "xxx"
      # endpoint: "oss-cn-beijing-internal.aliyuncs.com"
      endpoint: "oss-cn-beijing.aliyuncs.com"
      region: "cn-beijing"
      bucket: "xxx"
    
    receivers:
      - name: dingtalk
        dingtalk_config:
          message_type: markdown
          markdown:
            title: '{{ template "dingtalk.default.title" . }}'
            text: '{{ template "dingtalk.default.content" . }}'
          at:
            atMobiles: [ "138xxxx" ]
            isAtAll: true
      - name: wechat
        wechat_config:
          message_type: markdown
          message: '{{ template "wechat.default.message" . }}'
          to_user: "@all"
          agent_id: 1000002

生成 secret 密文 data

bash

    $ cat promoter-config.yml | base64

资源定义 Secret

yaml

    # secret-promoter-config.yml
    apiVersion: v1
    kind: Secret
    metadata:
      name: secret-promoter-config
      namespace: kube-vm
    data:
      config.yml: |
        # 密文 data

创建 secret 对象

bash

    $ kc apply -f secret-promoter-config.yml

promoter 工作负载定义

yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: promoter
      namespace: kube-vm
      labels:
        app: promoter
    spec:
      type: ClusterIP
      selector:
        app: promoter
      ports:
        - port: 9194
          protocol: TCP
          targetPort: 8080
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: promoter
      namespace: kube-vm
      labels:
        app: promoter
    spec:
      selector:
        matchLabels:
          app: promoter
      template:
        metadata:
          labels:
            app: promoter
        spec:
          volumes:
            - name: promoter-config
              secret:
                secretName: secret-promoter-config
          containers:
            - name: promoter
              image: lotusching/promoter:latest
              imagePullPolicy: IfNotPresent
              command:
                - "/promoter/bin/promoter"
                - "--config.file=/etc/secret/config.yml"
              volumeMounts:
                - mountPath: /etc/secret
                  name: promoter-config
              ports:
                - name: http
                  containerPort: 8080
                  protocol: TCP

创建资源

bash

    $ kc apply -f promoter.yml
    service/promoter created
    deployment.apps/promoter created
    
    $ kc get deploy -n kube-vm -l app=promoter    
    NAME    READY   UP-TO-DATE   AVAILABLE   AGE
    promoter   1/1     1    1    7s
    
    
    $ kc -n kube-vm logs -f -l app=promoter
    ts=2023-04-14T03:39:25.733Z caller=main.go:58 level=info msg="Staring Promoter" version="(version=0.2.3, branch=HEAD, revision=0a9cf8fc9bd55d1d2d47d181867135914927c2fc)"
    ts=2023-04-14T03:39:25.733Z caller=main.go:59 level=info build_context="(go=go1.17.8, user=root@91adc4eacff7, date=20220305-05:40:54)"
    ts=2023-04-14T03:39:25.733Z caller=main.go:127 level=info component=configuration msg="Loading configuration file" file=/etc/secret/config.yml
    ts=2023-04-14T03:39:25.733Z caller=main.go:138 level=info component=configuration msg="Completed loading of configuration file" file=/etc/secret/config.yml
    ts=2023-04-14T03:39:25.735Z caller=main.go:88 level=info msg=Listening address=:8080

#### [](#vmalert "vmalert")vmalert

vmalert 负责从 vmselect 查询数据，根据已载入的规则（记录规则、告警规则）进行数据评估，评估后，持久化记录这部分数据通过 vminsert 存入 vmstorage 组件

告警规则，如哟评估满足告警条件，则将通过 alertmanager 产生告警通知，alertmanager 根据告警策略配置，选择分组、抑制、以及路由到配置定义的媒介，经由 webhook 发送通知到用户

vmalert 组件重要的参数有以下几个

* `-rule`：规则文件路径
* `-datasource.url`：从哪里查询数据，用以生成持久化记录数据，也就是 vmselect 的地址
* `-remoteWrite.url`：生成持久化记录数据后，写到哪，也就是 vminsert 的地址
* `-notifier.url`：告警规则触发后通知谁，也就是 alertmanager 的地址
* `-evaluationInterval=15s`：规则（持久化、告警）多久评估一次

vmalert ConfigMap 配置对象

yaml

    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: configmap-vmalert-rules
      namespace: kube-vm
    data:
      node_records.yml: |+
        groups:
          - name: "node_rules"
            interval: 15s
            rules:
              #################
              #  CPU
              #################
              # 最近 1 分钟节点 CPU 使用率
              - record: node:cpu:cpu_usage
                expr: (1 - sum(irate(node_cpu_seconds_total{mode="idle"}[1m])) by (instance) / sum(irate(node_cpu_seconds_total[1m])) by (instance) )
              # 最近 1 分钟节点各 CPU 核心使用率
              - record: node:cpu:per_cpu_usage
                expr: (1 - sum(irate(node_cpu_seconds_total{mode="idle"}[1m])) by (instance, cpu)  / sum(irate(node_cpu_seconds_total[1m])) by (instance, cpu))
              #################
              #  Memory
              #################
              # 节点 内存 使用率
              - record: node:mem:memory_usage
                expr: (1 - (node_memory_MemFree_bytes + node_memory_Buffers_bytes + node_memory_Cached_bytes) / node_memory_MemTotal_bytes)
              # tmpfs、devtmpfs 内存使用量（单位 MiB）
              - record: node:mem:tmpfs_used
                expr: (node_filesystem_size_bytes{fstype=~".*tmpfs"} - node_filesystem_free_bytes{fstype=~".*tmpfs"}) / 1024 / 1024
              # 最近一分钟内 slab 不可回收内存量的平均值（单位 MiB）
              - record: node:mem:slab_sunreclaim
                expr: avg_over_time(node_memory_SUnreclaim_bytes[1m]) / 1024 / 1024
              # 最近一分钟内 LRU list 中 不可释放内存量的平均值（单位 MiB）
              - record: node:mem:lru_unevictable
                expr: avg_over_time(node_memory_Unevictable_bytes[1m]) / 1024 / 1024
              #################
              #  Disk
              #################
              # 空间 已用百分比
              - record: node:disk:disk_space_usage
                expr: (1 - (node_filesystem_avail_bytes{fstype=~"ext.*|xfs|btrfs",device=~"/dev/vd.*"} / node_filesystem_size_bytes{fstype=~"ext.*|xfs|btrfs",device=~"/dev/vd.*"}))
              # Inode 已用百分比
              - record: node:disk:inode_space_usage
                expr: (1 - (node_filesystem_files_free{fstype="ext4"} / node_filesystem_files{fstype="ext4"}))
              #################
              #  DiskIO
              #################
              # 计算 1 分钟内平均每秒处理磁盘读请求数，对应 iostat -dxk 中的 r/s
              - record: node:disk:read_iops
                expr: sum by (instance) (rate(node_disk_reads_completed_total{device=~"vd.*"}[1m]))
              # 计算 1 分钟内平均每秒处理磁盘写请求数，对应 iostat -dxk 中的 w/s
              - record: node:disk:write_iops
                expr: sum by (instance) (rate(node_disk_writes_completed_total{device=~"vd.*"}[1m]))
              # 计算 1 分钟内平均每秒处理磁盘读带宽，对应 iostat -dxk 中的 rkB/s
              - record: node:disk:read_bandwidth
                expr: sum by (instance) (irate(node_disk_read_bytes_total{device=~"vd.*"}[1m]))
              # 计算 1 分钟内平均每秒处理磁盘写带宽，对应 iostat -dxk 中的 wkB/s
              - record: node:disk:write_bandwidth
                expr: sum by (instance) (irate(node_disk_written_bytes_total{device=~"vd.*"}[1m]))
              # 计算 1 分钟内平均读请求延迟 ms，对应 iostat -dxk 中的 r_await
              - record: node:disk:read_await
                expr: sum by (instance) (rate(node_disk_read_time_seconds_total{device=~"vd.*"}[1m]) / rate(node_disk_reads_completed_total{device=~"vd.*"}[1m]) * 1000)
              # 计算 1 分钟内平均写请求延迟，对应 iostat -dxk 中的 w_await
              - record: node:disk:write_await
                expr: sum by (instance) (rate(node_disk_write_time_seconds_total{device=~"vd.*"}[1m]) / rate(node_disk_writes_completed_total{device=~"vd.*"}[1m]) * 1000)
              #################
              #  File Descriptor
              #################
              # 系统已用文件描述符百分比
              - record: node:proc:os_fd_usage
                expr: (node_filefd_allocated / node_filefd_maximum)
              # 进程已用文件描述符百分比
              - record: node:proc:proc_fd_usage
                expr: (process_open_fds{job="node"} / process_max_fds{job="node"})
              #################
              #  Network
              #################
              # 各实例、各网卡 1 分钟内平均每秒接收字节数
              - record: node:net:network_rx
                expr: sum by(instance, device) (irate(node_network_receive_bytes_total{device=~"eth.*"}[1m]))
              # 各实例、各网卡 1 分钟内平均每秒发送字节数
              - record: node:net:network_tx
                expr: sum by(instance, device) (irate(node_network_transmit_bytes_total{device=~"eth.*"}[1m]))
              #################
              #  TCP
              #################
              # 各实例、各网卡 5 分钟内入向报文错误包占比（平均每秒）
              - record: node:tcp:rx_error_rate5m
                expr: sum by(instance, device) (rate(node_network_receive_errs_total{device=~"eth.*"}[5m]) / rate(node_network_receive_packets_total{device=~"eth.*"}[5m]))
              # 各实例、各网卡 5 分钟内出向报文错误包占比（平均每秒）
              - record: node:tcp:tx_error_rate5m
                expr: sum by(instance, device) (rate(node_network_transmit_errs_total{device=~"eth.*"}[5m]) / rate(node_network_transmit_packets_total{device=~"eth.*"}[5m]))
              # 各实例、各网卡 5 分钟内入向报文丢弃包占比（平均每秒）
              - record: node:tcp:rx_drop_rate5m
                expr: sum by(instance, device) (rate(node_network_receive_drop_total{device=~"eth.*"}[5m]) / rate(node_network_receive_packets_total{device=~"eth.*"}[5m]))
              # 各实例、各网卡 5 分钟内出向报文丢弃包占比（平均每秒）
              - record: node:tcp:tx_drop_rate5m
                expr: sum by(instance, device) (rate(node_network_transmit_drop_total{device=~"eth.*"}[5m]) / rate(node_network_transmit_drop_total{device=~"eth.*"}[5m]))
              # 当前重传报文率 与 30 分钟前对比，涨幅百分比
              - record: node:tcp:retrans_rate5m
                expr: (irate(node_netstat_Tcp_RetransSegs[1m]) / irate(node_netstat_Tcp_OutSegs[1m])) - (irate(node_netstat_Tcp_RetransSegs[1m] offset 30m) / irate(node_netstat_Tcp_OutSegs[1m] offset 30m))
              # 当前重置报文率 与 30 分钟前对比，涨幅百分比
              - record: node:tcp:rst_rate5m
                expr: (irate(node_netstat_Tcp_OutRsts[1m]) / irate(node_netstat_Tcp_OutSegs[1m])) - (irate(node_netstat_Tcp_OutRsts[1m] offset 30m) / irate(node_netstat_Tcp_OutSegs[1m] offset 30m))
              #################
              #  TCP Socket
              #################
              # 半连接队列 syn_backlog 溢出情况
              - record: node:socket:listen_drop
                expr: irate(node_netstat_TcpExt_ListenDrops[1m])
              # 全连接队列 accept 溢出情况
              - record: node:socket:listen_overflow
                expr: irate(node_netstat_TcpExt_ListenOverflows[1m])
              # 连接追踪表使用率
              #################
              #  conntrack table
              #################
              - record: node:net:conntrack_tb_usage
                expr: (node_nf_conntrack_entries / node_nf_conntrack_entries_limit)
      node_alerts.yml: |+
        groups:
          - name: node_alerts
            rules:
            ###### CPU ######
            - alert: HostHighCpuLoad
              # 最近 1m CPU 使用率超过 80%
              expr: node:cpu:cpu_usage > 0.8
              for: 0m
              labels:
                severity: warning
              annotations:
                summary: "{{ $labels.instance }} 节点 CPU 使用率过高"
                description: "最近一分钟内 {{ $labels.instance }} 节点 CPU 使用率超过 80%！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
                console: "URL: http://baidu.com"
            - alert: HostHighCpuCoreLoad
              # 最近 1m CPU 某个核心使用率超过 80%
              expr: node:cpu:per_cpu_usage > 0.8
              for: 1m
              labels:
                severity: warning
              annotations:
                summary: "{{ $labels.instance }} 节点 CPU 核心使用率过高"
                description: "最近一分钟内 {{ $labels.instance }} 节点 CPU 核心 {{ $labels.cpu }} 使用率超过 80%！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
                console: "URL: http://baidu.com"
            ###### Memory ######
            - alert: HostHighTmpfsUsed
              # tmpfs 内存使用超过 1 GiB
              expr: node:mem:tmpfs_used > 200
              for: 1m
              labels:
                severity: warning
              annotations:
                summary: "{{ $labels.instance }} 节点 tmpfs 使用率过高 ！"
                description: "最近一分钟内 {{ $labels.instance }} 节点 tmpfs 使用率过高 ！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostHighMemorySlabUnreclaimUsed
              # slab 不可回收内存量内存量过高
              expr: node:mem:slab_sunreclaim > 1024
              for: 1m
              labels:
                severity: warning
              annotations:
                summary: "{{ $labels.instance }} slab 不可回收内存量内存量过高 "
                description: "最近一分钟内 {{ $labels.instance }} slab 不可回收内存量内存量过高 ！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostHighMemoryLruUnreclaimUsed
              # slab 不可回收内存量内存量过高
              expr: node:mem:lru_unevictable > 2048
              for: 1m
              labels:
                severity: warning
              annotations:
                summary: "{{ $labels.instance }} lru list 不可回收内存量内存量过高"
                description: "最近一分钟内 {{ $labels.instance }} lru list 不可回收内存量内存量过高 ！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            ###### Disk ######
            - alert: HostOutOfDiskSpace
              # 磁盘空间使用率超过 90%
              expr: node:disk:disk_space_usage > 0.9
              for: 1m
              labels:
                severity: warning
              annotations:
                summary: "最近一分钟内 {{ $labels.instance }} 节点 CPU 使用率超过 80%"
                description: "最近一分钟内 {{ $labels.instance }} 节点 CPU 使用率超过 80%！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostDiskWillFillIn24Hour
              # 通过predict_linear函数根据过去1h的数据，推测4小时后磁盘是否会满
              expr: predict_linear(node_filesystem_free_bytes[1h], 24*3600) < 0
              for: 0m
              labels:
                severity: critical
              annotations:
                summary: "预计实例 {{ $labels.instance }} 挂载点将在一天后打满！"
            - alert: HostOutofDiskInodes
              expr: node:disk:inode_space_usage > 0.8
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 磁盘 inode 超过 80%"
                description: "节点 {{ $labels.instance }} 磁盘 inode 超过 80%！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostInodesWillFillIn24Hour
              # 通过predict_linear函数根据过去1h的数据，推测4小时后磁盘 inode是否会满
              expr: predict_linear(node_filesystem_files_free[1h], 24*3600) < 0
              for: 0m
              labels:
                severity: critical
              annotations:
                summary: "预计实例 {{ $labels.instance }} 磁盘 inode 将在一天后打满！"
            ###### DiskIO ######
            - alert: HostUnusualDiskReadLatency
              expr: node:disk:read_await > 100
              for: 2m
              labels:
                severity: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 磁盘 读请求耗时（r_await）异常"
                description: "节点 {{ $labels.instance }} 磁盘 读请求耗时（r_await）异常！\n当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostUnusualDiskWriteLatency
              expr: node:disk:write_await > 100
              for: 2m
              labels:
                severity: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 磁盘 写请求耗时（w_await）异常"
                description: "节点 {{ $labels.instance }} 磁盘 写请求耗时（w_await）异常！\n当前值：{{ $value }}\n LABELS = {{ $labels }}"
            ###### File Descriptor ######
            - alert: HostHighSystemFdUsed
              expr: node:proc:os_fd_usage > 0.8
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 系统文件描述符使用率超过 80%"
                description: "节点 {{ $labels.instance }} 系统文件描述符使用率 80%！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            ###### File Descriptor ######
            - alert: HostHighSystemFdUsed
              expr: node:proc:proc_fd_usage > 0.8
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 进程文件描述符使用率超过 80%"
                description: "节点 {{ $labels.instance }} 进程文件描述符使用率 80%！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            ###### TCP ######
            - alert: HostNetworkReceiveErrRate
              expr: node:tcp:rx_error_rate5m > 0.01
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 接收报文错误占比异常"
                description: "节点 {{ $labels.instance }} 接收报文错误占比异常！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostNetworkTransmitErrRate
              expr: node:tcp:tx_error_rate5m > 0.01
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 发送报文错误占比异常"
                description: "节点 {{ $labels.instance }} 发送报文错误占比异常！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostNetworkReceiveDropRate
              expr: node:tcp:rx_drop_rate5m > 0.01
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 接收报文丢弃占比异常"
                description: "节点 {{ $labels.instance }} 接收报文丢弃占比异常！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostNetworkTransmitDropRate
              expr: node:tcp:rx_drop_rate5m > 0.01
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 发送报文丢弃占比异常"
                description: "节点 {{ $labels.instance }} 发送报文丢弃占比异常！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostUnusualNetworkRetransRate
              expr: node:tcp:retrans_rate5m > 20
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 报文重传率发生异常升高"
                description: "节点 {{ $labels.instance }} 报文重传率发生异常升高！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostUnusualNetworkResetRate
              expr: node:tcp:rst_rate5m > 20
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 报文重置率发生异常升高"
                description: "节点 {{ $labels.instance }} 报文重置率发生异常升高！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            ###### TCP Socket ######
            - alert: HostSynBacklogOverflow
              expr: node:socket:listen_overflow > 10
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 半连接队列存在溢出现象"
                description: "节点 {{ $labels.instance }} 半连接队列存在溢出现象！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostAcceptBacklogverflow
              expr: node:socket:listen_overflow > 10
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 半连接队列存在溢出现象"
                description: "节点 {{ $labels.instance }} 半连接队列存在溢出现象！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"
            - alert: HostHighConntrackTableUsage
              expr: node:net:conntrack_tb_usage > 80
              for: 1m
              labels:
                security: warning
              annotations:
                summary: "节点 {{ $labels.instance }} 连接追踪表使用率过高"
                description: "节点 {{ $labels.instance }} 连接追踪表使用率过高！\n 当前值：{{ $value }}\n LABELS = {{ $labels }}"

vmalert 工作负载定义

yaml

    apiVersion: v1
    kind: Service
    metadata:
      name: vmalert
      namespace: kube-vm
      labels:
        app: vmalert
    spec:
      type: NodePort
      selector:
        app: vmalert
      ports:
        - name: vmalert
          port: 8080
          targetPort: 8080
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: vmalert
      namespace: kube-vm
      labels:
        app: vmalert
    spec:
      selector:
        matchLabels:
          app: vmalert
      template:
        metadata:
          labels:
            app: vmalert
        spec:
          volumes:
            - name: rulus
              configMap:
                name: configmap-vmalert-rules
          containers:
            - name: vmalert
              image: victoriametrics/vmalert:v1.77.0
              imagePullPolicy: IfNotPresent
              volumeMounts:
                - mountPath: /etc/rules/
                  name: rulus
                  readOnly: true
              args:
                - -rule=/etc/rules/*.yml
                - -datasource.url=http://vmselect.kube-vm.svc.cluster.local:8481/select/0/prometheus
                - -notifier.url=http://alertmanager.kube-vm.svc.cluster.local:9193
                - -remoteWrite.url=http://vminsert.kube-vm.svc.cluster.local:8480/insert/0/prometheus
                - -evaluationInterval=15s
                - -httpListenAddr=0.0.0.0:8080

创建资源

bash

    $ kc apply -f configmap-vmalert-rules.yml
    configmap/configmap-vmalert-rules created

观察状态

bash

    $ kc get deploy -n kube-vm -l app=vmalert 
    NAME      READY   UP-TO-DATE   AVAILABLE   AGE
    vmalert   1/1     1    1    10s	
    
    $ kc -n kube-vm logs -f -l app=vmalert   
    2023-04-14T03:53:27.008Z	info	VictoriaMetrics/lib/logger/flag.go:20	flag "evaluationInterval"="15s"
    2023-04-14T03:53:27.008Z	info	VictoriaMetrics/lib/logger/flag.go:20	flag "httpListenAddr"="0.0.0.0:8080"
    2023-04-14T03:53:27.008Z	info	VictoriaMetrics/lib/logger/flag.go:20	flag "notifier.url"="http://alertmanager.kube-vm.svc.cluster.local:9093"
    2023-04-14T03:53:27.008Z	info	VictoriaMetrics/lib/logger/flag.go:20	flag "remoteWrite.url"="http://vminsert.kube-vm.svc.cluster.local:8480/insert/0/prometheus"
    2023-04-14T03:53:27.008Z	info	VictoriaMetrics/lib/logger/flag.go:20	flag "rule"="/etc/rules/*.yml"
    2023-04-14T03:53:27.009Z	info	VictoriaMetrics/app/vmalert/main.go:131	reading rules configuration file from "/etc/rules/*.yml"
    2023-04-14T03:53:27.022Z	info	VictoriaMetrics/lib/httpserver/httpserver.go:92	starting http server at http://0.0.0.0:8080/
    2023-04-14T03:53:27.022Z	info	VictoriaMetrics/lib/httpserver/httpserver.go:93	pprof handlers are exposed at http://0.0.0.0:8080/debug/pprof/
    2023-04-14T03:53:36.123Z	info	VictoriaMetrics/app/vmalert/group.go:262	group "node_alerts" started; interval=15s; concurrency=1
    2023-04-14T03:53:39.681Z	info	VictoriaMetrics/app/vmalert/group.go:262	group "node_rules" started; interval=15s; concurrency=1

访问 WebUI，查询持久化指标

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304141156222.png)

#### [](#grafana "grafana")grafana

Grafana 使用的也是 LocalPath ，所以这里提前在 `k8s-worker03` 创建目录

bash

    $ mkdir -p /data/k8s/grafana

资源定义

yaml

    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: grafana
      namespace: kube-vm
      labels:
        app: grafana
    spec:
      type: NodePort
      ports:
        - port: 3000
          nodePort: 30001
      selector:
        app: grafana
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: grafana
      namespace: kube-vm
      labels:
        app: grafana
    spec:
      selector:
        matchLabels:
          app: grafana
      template:
        metadata:
          labels:
            app: grafana
        spec:
          volumes:
            - name: storage
              persistentVolumeClaim:
                claimName: grafana-data
          initContainers:
            - name: fix-permissions
              image: busybox
              command: [chown, -R, "472:472", "/var/lib/grafana"]
              volumeMounts:
                - mountPath: /var/lib/grafana
                  name: storage
          containers:
            - name: grafana
              image: grafana/grafana:9.4.7
              imagePullPolicy: IfNotPresent
              ports:
                - containerPort: 3000
                  name: grafana
              env:
                - name: GF_SECURITY_ADMIN_USER
                  value: admin
                - name: GF_SECURITY_ADMIN_PASSWORD
                  value: LotusChing
              readinessProbe:
                failureThreshold: 10
                httpGet:
                  path: /api/health
                  port: 3000
                  scheme: HTTP
                initialDelaySeconds: 60
                periodSeconds: 10
                successThreshold: 1
                timeoutSeconds: 30
              livenessProbe:
                failureThreshold: 3
                httpGet:
                  path: /api/health
                  port: 3000
                  scheme: HTTP
                periodSeconds: 10
                successThreshold: 1
                timeoutSeconds: 1
              resources:
                limits:
                  cpu: 150m
                  memory: 512Mi
                requests:
                  cpu: 150m
                  memory: 512Mi
              volumeMounts:
                - mountPath: /var/lib/grafana
                  name: storage
    
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: grafana-local
      namespace: kube-vm
      labels:
        app: grafana
    spec:
      accessModes:
        - ReadWriteOnce
      capacity:
        storage: 1Gi
      storageClassName: local-storage
      local:
        # 需要提前创建该目录
        path: /data/k8s/grafana
      persistentVolumeReclaimPolicy: Retain
      nodeAffinity:
        required:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values:
                    # 亲和性选择节点 k8s-worker03
                    - k8s-worker03
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: grafana-data
      namespace: kube-vm
      labels:
        app: grafana
    spec:
      selector:
        matchLabels:
          app: grafana
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
      storageClassName: local-storage

创建资源，并观察状态

bash

    $ kc apply -f grafana.yml    
    service/grafana created
    deployment.apps/grafana created
    persistentvolume/grafana-local created
    persistentvolumeclaim/grafana-data created
    
    $ kc get deploy -n kube-vm
    NAME    READY   UP-TO-DATE   AVAILABLE   AGE
    grafana   1/1     1    1    99s

#### [](#检查确认：监控大盘数据 "检查确认：监控大盘数据")检查确认：监控大盘数据

等到 grafana 工作负载 Ready，访问 WebUI，创建数据源，这里数据源配置使用 `vmselect`

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304141202217.png)

导入仪表盘 18435，检查监控数据是否正常查询、渲染、展示

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304141201111.png)

#### [](#检查确认：告警流程 "检查确认：告警流程")检查确认：告警流程

通过 dd 命令，快速创建文件，触发告警，测试整个告警通知流程能否正常跑通

bash

    $ dd if=/dev/urandom of=testfile bs=1M count=300
    300+0 records in
    300+0 records out
    314572800 bytes (315 MB) copied, 1.24061 s, 254 MB/s

访问 vmalert WebUI 等待活跃告警

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304141209592.png)

打开钉钉，等待消息通知

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304141209134.png)

#### [](#资源汇总 "资源汇总")资源汇总

贴一下最终 Kubernetes 资源汇总

ConfigMap

bash

    $ kc get cm -n kube-vm
    
    NAME                            DATA   AGE
    configmap-alertmanager-config   1      120m
    configmap-vmagent-config        1      143m
    configmap-vmalert-rules         2      100m
    kube-root-ca.crt                1      154m

Secret

bash

    $ kc get secret -n kube-vm
    
    NAME                     TYPE                                  DATA   AGE
    default-token-ltvtd      kubernetes.io/service-account-token   3      154m
    secret-promoter-config   Opaque                                1      114m
    vmagent-sa-token-jkrnp   kubernetes.io/service-account-token   3      153m

StorageClass

bash

    $ kc get sc -n kube-vm
    
    NAME            PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    local-storage   kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  153m、

PV

bash

    $ kc get pv -n kube-vm
    
    NAME               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS    REASON   AGE
    grafana-local      1Gi        RWO            Retain           Bound    kube-vm/grafana-data        local-storage            152m
    vmagent-pv         2Gi        RWX            Retain           Bound    kube-vm/vmagent-pvc         local-storage            136m
    vmstore-local-pv   20Gi       RWX            Retain           Bound    kube-vm/vmstore-local-pvc   local-storage            151m

PVC

bash

    $ kc get pvc -n kube-vm
    
    grafana-data        Bound    grafana-local      1Gi        RWO            local-storage   152m
    vmagent-pvc         Bound    vmagent-pv         2Gi        RWX            local-storage   136m
    vmstore-local-pvc   Bound    vmstore-local-pv   20Gi       RWX            local-storage   152m

DaemonSet

bash

    $ kc get ds -n kube-vm
    
    NAME            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    node-exporter   3         3         3       3            3           kubernetes.io/os=linux   154m

Deployment

bash

    $ kc get deploy -n kube-vm
    
    NAME           READY   UP-TO-DATE   AVAILABLE   AGE
    alertmanager   1/1     1            1           121m
    grafana        1/1     1            1           152m
    promoter       1/1     1            1           114m
    vmalert        1/1     1            1           100m
    vminsert       1/1     1            1           145m
    vmselect       1/1     1            1           149m

StatefulSet

bash

    $ kc get sts -n kube-vm
    
    NAME        READY   AGE
    vmagent     2/2     136m
    vmstorage   2/2     152m

Service

bash

    $ kc get svc -n kube-vm -o wide 
    
    NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE    SELECTOR
    alertmanager        ClusterIP   10.108.40.17     <none>        9193/TCP                     121m   app=alertmanager
    cluster-vmstorage   ClusterIP   None             <none>        8482/TCP,8401/TCP,8400/TCP   152m   app=vmstorage
    grafana             NodePort    10.109.99.238    <none>        3000:30001/TCP               153m   app=grafana
    promoter            ClusterIP   10.109.5.115     <none>        9194/TCP                     114m   app=promoter
    vmagent             ClusterIP   None             <none>        8429/TCP                     136m   app=vmagent
    vmalert             NodePort    10.105.4.29      <none>        8080:31303/TCP               100m   app=vmalert
    vminsert            ClusterIP   10.97.67.96      <none>        8480/TCP                     145m   app=vminsert
    vmselect            NodePort    10.103.106.255   <none>        8481:32515/TCP               149m   app=vmselect

镜像

bash

    $ ctr --namespace k8s.io images ls -q|grep -v 'sha256'
    
    docker.io/grafana/grafana:9.4.7
    docker.io/lotusching/promoter:latest
    docker.io/prom/alertmanager:v0.25.0
    docker.io/prom/node-exporter:v1.5.0
    docker.io/prom/prometheus:v2.35.0
    docker.io/rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0
    docker.io/rancher/mirrored-flannelcni-flannel:v0.20.1
    docker.io/victoriametrics/vmagent:v1.77.0
    docker.io/victoriametrics/vmalert:v1.77.0
    docker.io/victoriametrics/vminsert:v1.77.0-cluster
    docker.io/victoriametrics/vmselect:v1.77.0-cluster
    docker.io/victoriametrics/vmstorage:v1.77.0-cluster
    registry.aliyuncs.com/google_containers/coredns:v1.8.4
    registry.aliyuncs.com/google_containers/etcd:3.5.0-0
    registry.aliyuncs.com/google_containers/kube-apiserver:v1.22.2
    registry.aliyuncs.com/google_containers/kube-controller-manager:v1.22.2
    registry.aliyuncs.com/google_containers/kube-proxy:v1.22.2
    registry.aliyuncs.com/google_containers/kube-scheduler:v1.22.2
    registry.aliyuncs.com/google_containers/pause:3.5
    registry.aliyuncs.com/google_containers/pause:3.6

#### [](#故障排查 "故障排查")故障排查

贴一下大致的排障思路

1.  检查 Pod 状态，观察 READY、STATUS、RESTART 列
    
    bash
    
        $ kc get pods -o wide -n kube-mon
    
2.  如果状态不正确，检查 Pod 状态详细描述
    
    bash
    
        $ kc -n kube-mon describe -l app=<name> 
    
    * 检查是否正常调度
    * 检查 PV、PVC 是否正确挂载
    * …
3.  如果 Pod 是 PV、PVC 相关问题
    
    * 检查 pv、pvc 是否正确关联绑定，关注 `NAME` 与 `CLAIM`
        
        bash
        
            NAME                             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS    REASON   AGE
            persistentvolume/grafana-local   1Gi        RWO            Retain           Bound    kube-mon/grafana-data   local-storage            3h20m
        
4.  仪表盘 Sytemd 服务单元状态无数据，这是因为 node_exporter 运行在容器中，暂时没去处理，等后续补上处理方式
    
    ![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304101146324.png)
    

### [](#集群备份 "集群备份")集群备份

victoria-metrics 提供了与备份相关的两个二进制程序

* vmbackup：负责从快照从生成备份数据，如果目标目录已有备份，则自动使用增量方式备份
* vmrestore：负责从备份数据还原指标数据

victoria-metrics 备份操作过程主要就是两步

* 通过 http api 创建快照
* 通过 二进制程序生成备份数据

过程比较简单，如下所示

#### [](#1-创建快照 "1. 创建快照")1\. 创建快照

victoria-metrics 提供了 http api，这里需要先获取各 vmstorage pod 的 ip

获取 vmstorage pod 的 IP

bash

    $ kc get pods -o wide -l app=vmstorage -n kube-vm
    NAME          READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
    vmstorage-0   1/1     Running   0          7m39s   10.244.1.9    k8s-worker02   <none>           <none>
    vmstorage-1   1/1     Running   0          7m24s   10.244.1.10   k8s-worker02   <none>           <none>

服务监听端口配置到了 8482，所以这里直接通过 curl 命令创建快照

bash

    $ curl http://10.244.1.3:8482/snapshot/create
    {"status":"ok","snapshot":"20230414055930-1755ADF679466C8F"}

观察日志

bash

    $ kc -n kube-vm logs -f vmstorage-0
    
    # ...
    {"ts":"2023-04-14T05:59:30.170Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:330","msg":"creating Storage snapshot for \"/storage/vmstorage-0\"..."}
    {"ts":"2023-04-14T05:59:30.176Z","level":"info","caller":"VictoriaMetrics/lib/storage/table.go:145","msg":"creating table snapshot of \"/storage/vmstorage-0/data\"..."}
    {"ts":"2023-04-14T05:59:30.181Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1604","msg":"creating partition snapshot of \"/storage/vmstorage-0/data/small/2023_04\" and \"/storage/vmstorage-0/data/big/2023_04\"..."}
    {"ts":"2023-04-14T05:59:30.340Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1625","msg":"created partition snapshot of \"/storage/vmstorage-0/data/small/2023_04\" and \"/storage/vmstorage-0/data/big/2023_04\" at \"/storage/vmstorage-0/data/small/snapshots/20230414055930-1755ADF679466C8F/2023_04\" and \"/storage/vmstorage-0/data/big/snapshots/20230414055930-1755ADF679466C8F/2023_04\" in 0.159 seconds"}
    {"ts":"2023-04-14T05:59:30.340Z","level":"info","caller":"VictoriaMetrics/lib/storage/table.go:173","msg":"created table snapshot for \"/storage/vmstorage-0/data\" at (\"/storage/vmstorage-0/data/small/snapshots/20230414055930-1755ADF679466C8F\", \"/storage/vmstorage-0/data/big/snapshots/20230414055930-1755ADF679466C8F\") in 0.163 seconds"}
    {"ts":"2023-04-14T05:59:30.343Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:1146","msg":"creating Table snapshot of \"/storage/vmstorage-0/indexdb/1755ADF679474FBF\"..."}
    {"ts":"2023-04-14T05:59:30.386Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:1215","msg":"created Table snapshot of \"/storage/vmstorage-0/indexdb/1755ADF679474FBF\" at \"/storage/vmstorage-0/indexdb/snapshots/20230414055930-1755ADF679466C8F/1755ADF679474FBF\" in 0.043 seconds"}
    {"ts":"2023-04-14T05:59:30.386Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:1146","msg":"creating Table snapshot of \"/storage/vmstorage-0/indexdb/1755ADF679474FBE\"..."}
    {"ts":"2023-04-14T05:59:30.393Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:1215","msg":"created Table snapshot of \"/storage/vmstorage-0/indexdb/1755ADF679474FBE\" at \"/storage/vmstorage-0/indexdb/snapshots/20230414055930-1755ADF679466C8F/1755ADF679474FBE\" in 0.006 seconds"}
    {"ts":"2023-04-14T05:59:30.409Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:387","msg":"created Storage snapshot for \"/storage/vmstorage-0\" at \"/storage/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F\" in 0.239 seconds"}

#### [](#2-列出快照 "2. 列出快照")2\. 列出快照

bash

    $ curl http://10.244.1.3:8482/snapshot/list  
    {"status":"ok","snapshots":[
    "20230414055930-1755ADF679466C8F"
    ]}

查看数据目录

bash

    $ ls vmstorage-0/snapshots 
    20230414055930-1755ADF679466C8F
    $ tree vmstorage-0/snapshots 
    vmstorage-0/snapshots
    └── 20230414055930-1755ADF679466C8F
        ├── data
        │   ├── big -> ../../../data/big/snapshots/20230414055930-1755ADF679466C8F
        │   └── small -> ../../../data/small/snapshots/20230414055930-1755ADF679466C8F
        ├── indexdb -> ../../indexdb/snapshots/20230414055930-1755ADF679466C8F
        └── metadata
        └── minTimestampForCompositeIndex
    
    6 directories, 1 file

#### [](#3-全量备份 "3. 全量备份")3\. 全量备份

获取 vmbackup、vmrestore 命令

bash

    $ wget http://download.yo-yo.fun/prometheus/vmbackup
    $ wget http://download.yo-yo.fun/prometheus/vmrestore
    $ chmod +x vmbackup; chmod +x vmrestore
    $ mv vmbackup /usr/bin/; mv vmrestore /usr/bin/

创建备份目录

bash

    $ mkdir /data/backup

执行全备

bash

    $ vmbackup -storageDataPath=/data/k8s/vmstore/vmstorage-0 -snapshotName=20230414055930-1755ADF679466C8F -dst=fs:///data/backup/vmstorage-0/

输出如下

bash

    # 输出命令行参数
    2023-04-14T06:10:48.361Z	info	VictoriaMetrics/lib/logger/flag.go:12	build version: vmbackup-20230407-010908-tags-v1.90.0-0-gb5d18c0d2
    2023-04-14T06:10:48.361Z	info	VictoriaMetrics/lib/logger/flag.go:13	command-line flags
    2023-04-14T06:10:48.361Z	info	VictoriaMetrics/lib/logger/flag.go:20	  -dst="fs:///data/backup/vmstorage-0/"
    2023-04-14T06:10:48.361Z	info	VictoriaMetrics/lib/logger/flag.go:20	  -snapshotName="20230414055930-1755ADF679466C8F"
    2023-04-14T06:10:48.361Z	info	VictoriaMetrics/lib/logger/flag.go:20	  -storageDataPath="/data/k8s/vmstore/vmstorage-0"
    # 开始执行备份
    2023-04-14T06:10:48.361Z	info	VictoriaMetrics/lib/backup/actions/backup.go:78	starting backup from fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to fsremote "/data/backup/vmstorage-0/" using origin fsnil
    # 这里似乎是起了 web server
    2023-04-14T06:10:48.361Z	info	VictoriaMetrics/lib/httpserver/httpserver.go:96	starting http server at http://127.0.0.1:8420/
    2023-04-14T06:10:48.361Z	info	VictoriaMetrics/lib/httpserver/httpserver.go:97	pprof handlers are exposed at http://127.0.0.1:8420/debug/pprof/
    # 发现 128 parts
    2023-04-14T06:10:48.363Z	info	VictoriaMetrics/lib/backup/actions/backup.go:84	obtained 128 parts from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F"
    2023-04-14T06:10:48.363Z	info	VictoriaMetrics/lib/backup/actions/backup.go:90	obtained 0 parts from dst fsremote "/data/backup/vmstorage-0/"
    2023-04-14T06:10:48.363Z	info	VictoriaMetrics/lib/backup/actions/backup.go:96	obtained 0 parts from origin fsnil
    # 上传 parts 到 fsremote "/data/backup/vmstorage-0/"
    2023-04-14T06:10:48.365Z	info	VictoriaMetrics/lib/backup/actions/backup.go:149	uploading 128 parts from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/"
    2023-04-14T06:10:48.365Z	info	VictoriaMetrics/lib/backup/actions/backup.go:152	uploading part{path: "data/small/2023_04/6830_4703_20230414055700.000_20230414055852.749_1755AF19C405E6B3/index.bin", file_size: 84346, offset: 0, size: 84346} from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/"
    2023-04-14T06:10:48.365Z	info	VictoriaMetrics/lib/backup/actions/backup.go:152	uploading part{path: "data/small/2023_04/6830_4703_20230414055700.000_20230414055852.749_1755AF19C405E6B3/min_dedup_interval", file_size: 4, offset: 0, size: 4} from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/"
    2023-04-14T06:10:48.365Z	info	VictoriaMetrics/lib/memory/memory.go:42	limiting caches to 5010650726 bytes, leaving 3340433818 bytes to the OS according to -memory.allowedPercent=60
    2023-04-14T06:10:48.365Z	info	VictoriaMetrics/lib/backup/actions/backup.go:152	uploading part{path: "data/small/2023_04/6830_4703_20230414055700.000_20230414055852.749_1755AF19C405E6B3/timestamps.bin", file_size: 2922, offset: 0, size: 2922} from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/"
    2023-04-14T06:10:48.366Z	info	VictoriaMetrics/lib/backup/actions/backup.go:152	uploading part{path: "data/small/2023_04/6830_4703_20230414055700.000_20230414055852.749_1755AF19C405E6B3/values.bin", file_size: 1147, offset: 0, size: 1147} from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/"
    2023-04-14T06:10:48.366Z	info	VictoriaMetrics/lib/backup/actions/backup.go:152	uploading part{path: "data/small/2023_04/827_827_20230414055830.000_20230414055855.456_1755AF19C405E6B5/min_dedup_interval", file_size: 4, offset: 0, size: 4} from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/"
    2023-04-14T06:10:48.372Z	info	VictoriaMetrics/lib/backup/actions/backup.go:152	uploading part{path: "data/small/2023_04/475572_13378_20230414035345.000_20230414042918.994_1755AF19C405E240/min_dedup_interval", file_size: 4, offset: 0, size: 4} from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/"
    # 省略...
    # 上传完成耗时 167.485473ms
    2023-04-14T06:10:48.532Z	info	VictoriaMetrics/lib/backup/actions/backup.go:170	uploaded 5987563 out of 5987563 bytes from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/" in 167.485473ms
    2023-04-14T06:10:48.533Z	info	VictoriaMetrics/lib/backup/actions/backup.go:179	backup from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414055930-1755ADF679466C8F" to dst fsremote "/data/backup/vmstorage-0/" with origin fsnil is complete; backed up 5987563 bytes in 0.172 seconds; deleted 0 bytes; server-side copied 0 bytes; uploaded 5987563 bytes
    2023-04-14T06:10:48.533Z	info	VictoriaMetrics/app/vmbackup/main.go:108	gracefully shutting down http server for metrics at ":8420"
    # 关闭 web server
    2023-04-14T06:10:48.533Z	info	VictoriaMetrics/app/vmbackup/main.go:112	successfully shut down http server for metrics in 0.000 seconds

查看备份目录

bash

    $ ls /data/backup/vmstorage-0/
    backup_complete.ignore  data  indexdb  metadata

OK，这里有了一份全量

#### [](#4-增量备份 "4. 增量备份")4\. 增量备份

由于数据是持续写入的，所以这段时间肯定也会产生数据，这里再进行一次增量备份

再创建一份创建快照

bash

    $ vmstorage-0  curl http://10.244.1.3:8482/snapshot/create
    {"status":"ok","snapshot":"20230414061750-1755ADF679466C90"}#    
    $ vmstorage-0  curl http://10.244.1.3:8482/snapshot/list  
    {"status":"ok","snapshots":[
    "20230414055930-1755ADF679466C8F",
    "20230414061750-1755ADF679466C90"
    ]}#    

执行增量备份

bash

    $ vmbackup -storageDataPath=/data/k8s/vmstore/vmstorage-0 -snapshotName=20230414061750-1755ADF679466C90 -dst=fs:///data/backup/vmstorage-0/
    
    # ...
    2023-04-14T06:19:17.902Z	info	VictoriaMetrics/lib/backup/actions/backup.go:170	uploaded 1514709 out of 1514709 bytes from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414061750-1755ADF679466C90" to dst fsremote "/data/backup/vmstorage-0/" in 85.711256ms
    2023-04-14T06:19:17.902Z	info	VictoriaMetrics/lib/backup/actions/backup.go:179	backup from src fslocal "/data/k8s/vmstore/vmstorage-0/snapshots/20230414061750-1755ADF679466C90" to dst fsremote "/data/backup/vmstorage-0/" with origin fsnil is complete; backed up 6576917 bytes in 0.106 seconds; deleted 925355 bytes; server-side copied 0 bytes; uploaded 1514709 bytes
    2023-04-14T06:19:17.902Z	info	VictoriaMetrics/app/vmbackup/main.go:108	gracefully shutting down http server for metrics at ":8420"
    2023-04-14T06:19:17.902Z	info	VictoriaMetrics/app/vmbackup/main.go:112	successfully shut down http server for metrics in 0.000 seconds

因为，我们之前全量备份过一次，所以这一次增量备份执行的很快

同理，给另一个实例 vmstorage-1 也备份一下

bash

    $ curl http://10.244.1.4:8482/snapshot/create
    {"status":"ok","snapshot":"20230414062614-1755ADF9F686DD3A"}#                                                                                       
    $ vmbackup -storageDataPath=/data/k8s/vmstore/vmstorage-1 -snapshotName=20230414062614-1755ADF9F686DD3A -dst=fs:///data/backup/vmstorage-1/

#### [](#5-模拟故障 "5. 模拟故障")5\. 模拟故障

删除实例、删除数据，模拟数据丢失场景

bash

    $ rm -rf /data/k8s/vmstore/vmstorage-0/*
    $ rm -rf /data/k8s/vmstore/vmstorage-1/*
    $ tree
    .
    ├── vmstorage-0
    └── vmstorage-1

#### [](#6-数据恢复 "6. 数据恢复")6\. 数据恢复

执行 vmrestore 恢复 vmstorage-0 数据

bash

    $ vmrestore -src=fs:///data/backup/vmstorage-0 -storageDataPath=/data/k8s/vmstore/vmstorage-0

输出如下

bash

    
    2023-04-14T06:32:50.454Z	info	VictoriaMetrics/lib/logger/flag.go:12	build version: vmrestore-20230407-011039-tags-v1.90.0-0-gb5d18c0d2
    2023-04-14T06:32:50.454Z	info	VictoriaMetrics/lib/logger/flag.go:13	command-line flags
    2023-04-14T06:32:50.454Z	info	VictoriaMetrics/lib/logger/flag.go:20	  -src="fs:///data/backup/vmstorage-0"
    2023-04-14T06:32:50.454Z	info	VictoriaMetrics/lib/logger/flag.go:20	  -storageDataPath="/data/k8s/vmstore/vmstorage-0"
    2023-04-14T06:32:50.454Z	info	VictoriaMetrics/lib/backup/actions/restore.go:75	starting restore from fsremote "/data/backup/vmstorage-0" to fslocal "/data/k8s/vmstore/vmstorage-0"
    2023-04-14T06:32:50.454Z	info	VictoriaMetrics/lib/backup/actions/restore.go:77	obtaining list of parts at fsremote "/data/backup/vmstorage-0"
    2023-04-14T06:32:50.455Z	info	VictoriaMetrics/lib/httpserver/httpserver.go:96	starting http server at http://127.0.0.1:8421/
    2023-04-14T06:32:50.455Z	info	VictoriaMetrics/lib/httpserver/httpserver.go:97	pprof handlers are exposed at http://127.0.0.1:8421/debug/pprof/
    2023-04-14T06:32:50.462Z	info	VictoriaMetrics/lib/backup/actions/restore.go:82	obtaining list of parts at fslocal "/data/k8s/vmstore/vmstorage-0"
    2023-04-14T06:32:50.462Z	info	VictoriaMetrics/lib/backup/actions/restore.go:162	downloading 118 parts from fsremote "/data/backup/vmstorage-0" to fslocal "/data/k8s/vmstore/vmstorage-0"
    2023-04-14T06:32:50.462Z	info	VictoriaMetrics/lib/backup/actions/restore.go:169	downloading part{path: "data/small/2023_04/7673_4708_20230414061643.107_20230414061737.749_1755AF19C405E79E/min_dedup_interval", file_size: 4, offset: 0, size: 4} from fsremote "/data/backup/vmstorage-0" to fslocal "/data/k8s/vmstore/vmstorage-0"
    2023-04-14T06:32:50.462Z	info	VictoriaMetrics/lib/backup/actions/restore.go:169	downloading part{path: "data/small/2023_04/475572_13378_20230414035345.000_20230414042918.994_1755AF19C405E240/min_dedup_interval", file_size: 4, offset: 0, size: 4} from fsremote "/data/backup/vmstorage-0" to fslocal "/data/k8s/vmstore/vmstorage-0"
    2023-04-14T06:32:50.463Z	info	VictoriaMetrics/lib/backup/actions/restore.go:169	downloading part{path: "indexdb/1755ADF679474FBF/87659_221_1755ADF67C1883C0/metaindex.bin", file_size: 389, offset: 0, size: 389} from fsremote "/data/backup/vmstorage-0" to fslocal "/data/k8s/vmstore/vmstorage-0"
    2023-04-14T06:32:50.463Z	info	VictoriaMetrics/lib/memory/memory.go:42	limiting caches to 5010650726 bytes, leaving 3340433818 bytes to the OS according to -memory.allowedPercent=60
    2023-04-14T06:32:50.463Z	info	VictoriaMetrics/lib/backup/actions/restore.go:169	downloading part{path: "data/small/2023_04/7673_4708_20230414061643.107_20230414061737.749_1755AF19C405E79E/metaindex.bin", file_size: 291, offset: 0, size: 291} from fsremote "/data/backup/vmstorage-0" to fslocal "/data/k8s/vmstore/vmstorage-0"
    # ...
    2023-04-14T06:32:50.640Z	info	VictoriaMetrics/lib/backup/actions/restore.go:169	downloading part{path: "indexdb/1755ADF679474FBF/98_1_1755ADF67C188460/items.bin", file_size: 1086, offset: 0, size: 1086} from fsremote "/data/backup/vmstorage-0" to fslocal "/data/k8s/vmstore/vmstorage-0"
    2023-04-14T06:32:50.646Z	info	VictoriaMetrics/lib/backup/actions/restore.go:188	downloaded 6576917 out of 6576917 bytes from fsremote "/data/backup/vmstorage-0" to fslocal "/data/k8s/vmstore/vmstorage-0" in 184.189806ms
    2023-04-14T06:32:50.646Z	info	VictoriaMetrics/lib/backup/actions/restore.go:195	restored 6576917 bytes from backup in 0.192 seconds; deleted 0 bytes; downloaded 6576917 bytes
    2023-04-14T06:32:50.647Z	info	VictoriaMetrics/app/vmrestore/main.go:64	gracefully shutting down http server for metrics at ":8421"
    2023-04-14T06:32:50.647Z	info	VictoriaMetrics/app/vmrestore/main.go:68	successfully shut down http server for metrics in 0.000 seconds

执行 vmrestore 恢复 vmstorage-1 数据

bash

    $ vmrestore -src=fs:///data/backup/vmstorage-1 -storageDataPath=/data/k8s/vmstore/vmstorage-1

输出如下

bash

    2023-04-14T06:33:26.875Z	info	VictoriaMetrics/lib/logger/flag.go:12	build version: vmrestore-20230407-011039-tags-v1.90.0-0-gb5d18c0d2
    2023-04-14T06:33:26.875Z	info	VictoriaMetrics/lib/logger/flag.go:13	command-line flags
    2023-04-14T06:33:26.875Z	info	VictoriaMetrics/lib/logger/flag.go:20	  -src="fs:///data/backup/vmstorage-1"
    2023-04-14T06:33:26.875Z	info	VictoriaMetrics/lib/logger/flag.go:20	  -storageDataPath="/data/k8s/vmstore/vmstorage-1"
    2023-04-14T06:33:26.875Z	info	VictoriaMetrics/lib/backup/actions/restore.go:75	starting restore from fsremote "/data/backup/vmstorage-1" to fslocal "/data/k8s/vmstore/vmstorage-1"
    2023-04-14T06:33:26.875Z	info	VictoriaMetrics/lib/backup/actions/restore.go:77	obtaining list of parts at fsremote "/data/backup/vmstorage-1"
    2023-04-14T06:33:26.876Z	info	VictoriaMetrics/lib/httpserver/httpserver.go:96	starting http server at http://127.0.0.1:8421/
    2023-04-14T06:33:26.876Z	info	VictoriaMetrics/lib/httpserver/httpserver.go:97	pprof handlers are exposed at http://127.0.0.1:8421/debug/pprof/
    2023-04-14T06:33:26.880Z	info	VictoriaMetrics/lib/backup/actions/restore.go:82	obtaining list of parts at fslocal "/data/k8s/vmstore/vmstorage-1"
    2023-04-14T06:33:26.881Z	info	VictoriaMetrics/lib/backup/actions/restore.go:162	downloading 78 parts from fsremote "/data/backup/vmstorage-1" to fslocal "/data/k8s/vmstore/vmstorage-1"
    2023-04-14T06:33:26.881Z	info	VictoriaMetrics/lib/backup/actions/restore.go:169	downloading part{path: "data/small/2023_04/56_56_20230414035700.000_20230414035700.000_1755AF19C405A09D/min_dedup_interval", file_size: 4, offset: 0, size: 4} from fsremote "/data/backup/vmstorage-1" to fslocal "/data/k8s/vmstore/vmstorage-1"
    2023-04-14T06:33:26.881Z	info	VictoriaMetrics/lib/backup/actions/restore.go:169	downloading part{path: "indexdb/1755ADF9F68785C1/38_1_1755ADF9F9DC8FC1/metaindex.bin", file_size: 271, offset: 0, size: 271} from fsremote "/data/backup/vmstorage-1" to fslocal "/data/k8s/vmstore/vmstorage-1"
    # ...
    2023-04-14T06:33:26.998Z	info	VictoriaMetrics/lib/backup/actions/restore.go:169	downloading part{path: "data/small/2023_04/56_56_20230414040200.000_20230414040212.000_1755AF19C405A0DE/values.bin", file_size: 0, offset: 0, size: 0} from fsremote "/data/backup/vmstorage-1" to fslocal "/data/k8s/vmstore/vmstorage-1"
    2023-04-14T06:33:27.006Z	info	VictoriaMetrics/lib/backup/actions/restore.go:188	downloaded 4656394 out of 4656394 bytes from fsremote "/data/backup/vmstorage-1" to fslocal "/data/k8s/vmstore/vmstorage-1" in 124.902351ms
    2023-04-14T06:33:27.006Z	info	VictoriaMetrics/lib/backup/actions/restore.go:195	restored 4656394 bytes from backup in 0.131 seconds; deleted 0 bytes; downloaded 4656394 bytes
    2023-04-14T06:33:27.006Z	info	VictoriaMetrics/app/vmrestore/main.go:64	gracefully shutting down http server for metrics at ":8421"
    2023-04-14T06:33:27.006Z	info	VictoriaMetrics/app/vmrestore/main.go:68	successfully shut down http server for metrics in 0.000 seconds

#### [](#7-实例恢复 "7. 实例恢复")7\. 实例恢复

恢复完数据后，恢复创建 sts vmstorage 实例

bash

    $ kc apply -f vmstore.yml    
    service/cluster-vmstorage configured
    persistentvolume/vmstore-local-pv unchanged
    persistentvolumeclaim/vmstore-local-pvc unchanged
    statefulset.apps/vmstorage created
    
    $ kc get sts -n kube-vm -l app=vmstorage 
    NAME    READY   AGE
    vmstorage   2/2     33s

查看启动日志，可以看到有在 loading 数据

bash

    $ kc -n kube-vm logs -f vmstorage-0     
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:12","msg":"build version: vmstorage-20220505-083109-tags-v1.77.0-cluster-0-g2ce1d0913"}
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:13","msg":"command line flags"}
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"dedup.minScrapeInterval\"=\"15s\""}
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"envflag.enable\"=\"true\""}
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"envflag.prefix\"=\"VM_\""}
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"loggerFormat\"=\"json\""}
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"retentionPeriod\"=\"1\""}
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"storageDataPath\"=\"/storage/vmstorage-0\""}
    {"ts":"2023-04-14T06:34:07.680Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/main.go:77","msg":"opening storage at \"/storage/vmstorage-0\" with -retentionPeriod=1"}
    {"ts":"2023-04-14T06:34:07.684Z","level":"info","caller":"VictoriaMetrics/lib/memory/memory.go:42","msg":"limiting caches to 5010650726 bytes, leaving 3340433818 bytes to the OS according to -memory.allowedPercent=60"}
    {"ts":"2023-04-14T06:34:07.684Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1072","msg":"loading MetricName->TSID cache from \"/storage/vmstorage-0/cache/metricName_tsid\"..."}
    {"ts":"2023-04-14T06:34:07.689Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1077","msg":"loaded MetricName->TSID cache from \"/storage/vmstorage-0/cache/metricName_tsid\" in 0.005 seconds; entriesCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T06:34:07.689Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1072","msg":"loading MetricID->TSID cache from \"/storage/vmstorage-0/cache/metricID_tsid\"..."}
    {"ts":"2023-04-14T06:34:07.690Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1077","msg":"loaded MetricID->TSID cache from \"/storage/vmstorage-0/cache/metricID_tsid\" in 0.001 seconds; entriesCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T06:34:07.690Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1072","msg":"loading MetricID->MetricName cache from \"/storage/vmstorage-0/cache/metricID_metricName\"..."}
    {"ts":"2023-04-14T06:34:07.692Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1077","msg":"loaded MetricID->MetricName cache from \"/storage/vmstorage-0/cache/metricID_metricName\" in 0.002 seconds; entriesCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T06:34:07.692Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:873","msg":"loading curr_hour_metric_ids from \"/storage/vmstorage-0/cache/curr_hour_metric_ids\"..."}
    {"ts":"2023-04-14T06:34:07.692Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:876","msg":"nothing to load from \"/storage/vmstorage-0/cache/curr_hour_metric_ids\""}
    {"ts":"2023-04-14T06:34:07.692Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:873","msg":"loading prev_hour_metric_ids from \"/storage/vmstorage-0/cache/prev_hour_metric_ids\"..."}
    {"ts":"2023-04-14T06:34:07.692Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:876","msg":"nothing to load from \"/storage/vmstorage-0/cache/prev_hour_metric_ids\""}
    {"ts":"2023-04-14T06:34:07.692Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:829","msg":"loading next_day_metric_ids from \"/storage/vmstorage-0/cache/next_day_metric_ids\"..."}
    {"ts":"2023-04-14T06:34:07.692Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:832","msg":"nothing to load from \"/storage/vmstorage-0/cache/next_day_metric_ids\""}
    {"ts":"2023-04-14T06:34:07.699Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:259","msg":"opening table \"/storage/vmstorage-0/indexdb/1755ADF679474FBF\"..."}
    {"ts":"2023-04-14T06:34:07.713Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:294","msg":"table \"/storage/vmstorage-0/indexdb/1755ADF679474FBF\" has been opened in 0.014 seconds; partsCount: 6; blocksCount: 232, itemsCount: 92512; sizeBytes: 2409104"}
    {"ts":"2023-04-14T06:34:07.714Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:259","msg":"opening table \"/storage/vmstorage-0/indexdb/1755ADF679474FBE\"..."}
    {"ts":"2023-04-14T06:34:07.723Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:294","msg":"table \"/storage/vmstorage-0/indexdb/1755ADF679474FBE\" has been opened in 0.009 seconds; partsCount: 0; blocksCount: 0, itemsCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T06:34:07.764Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/10368_10368_20230414061700.970_20230414061720.220_1755AF19C405E79B\" in 0.003 seconds"}
    {"ts":"2023-04-14T06:34:07.765Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/475572_13378_20230414035345.000_20230414042918.994_1755AF19C405E240\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.766Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/8678_8678_20230414061732.456_20230414061733.994_1755AF19C405E79F\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.767Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/10754_10754_20230414061728.341_20230414061749.040_1755AF19C405E7A1\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.768Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/830_830_20230414061715.000_20230414061740.456_1755AF19C405E7A0\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.769Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/122524_13384_20230414055700.000_20230414060618.994_1755AF19C405E711\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.770Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/345014_13296_20230414042844.588_20230414045420.220_1755AF19C405E37F\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.770Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/425926_13230_20230414032236.647_20230414035433.994_1755AF19C405E083\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.771Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/7673_4708_20230414061643.107_20230414061737.749_1755AF19C405E79E\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.772Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/10368_10368_20230414061638.247_20230414061705.212_1755AF19C405E798\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.773Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/30566_13386_20230414061442.115_20230414061635.216_1755AF19C405E792\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.779Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/120520_13388_20230414060600.000_20230414061450.218_1755AF19C405E77D\" in 0.006 seconds"}
    {"ts":"2023-04-14T06:34:07.780Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/54_54_20230414040630.000_20230414040630.000_1755AF19C405E125\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.781Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/54_54_20230414035815.000_20230414035815.000_1755AF19C405E0BC\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.781Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/436062_13322_20230414045330.000_20230414052603.994_1755AF19C405E512\" in 0.000 seconds"}
    {"ts":"2023-04-14T06:34:07.782Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/10368_10368_20230414061630.980_20230414061650.220_1755AF19C405E795\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.783Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-0/data/small/2023_04/430134_13383_20230414052500.000_20230414055755.456_1755AF19C405E6A8\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:07.792Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/main.go:92","msg":"successfully opened storage \"/storage/vmstorage-0\" in 0.112 seconds; partsCount: 17; blocksCount: 162949; rowsCount: 2445465; sizeBytes: 4163294"}
    {"ts":"2023-04-14T06:34:07.795Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:152","msg":"accepting vmselect conns at 0.0.0.0:8401"}
    {"ts":"2023-04-14T06:34:07.795Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:85","msg":"accepting vminsert conns at 0.0.0.0:8400"}
    {"ts":"2023-04-14T06:34:07.795Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:88","msg":"starting http server at http://127.0.0.1:8482/"}
    {"ts":"2023-04-14T06:34:07.795Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:89","msg":"pprof handlers are exposed at http://127.0.0.1:8482/debug/pprof/"}
    {"ts":"2023-04-14T06:34:51.247Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:164","msg":"accepted vmselect conn from 10.244.2.4:47268"}
    {"ts":"2023-04-14T06:34:51.248Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:207","msg":"processing vmselect conn from 10.244.2.4:47268"}
    {"ts":"2023-04-14T06:34:51.332Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:97","msg":"accepted vminsert conn from 10.244.1.5:55912"}
    {"ts":"2023-04-14T06:34:51.334Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:133","msg":"processing vminsert conn from 10.244.1.5:55912"}

storage-1 的日志类似

bash

    $ kc -n kube-vm logs -f vmstorage-1
    {"ts":"2023-04-14T06:34:22.662Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:12","msg":"build version: vmstorage-20220505-083109-tags-v1.77.0-cluster-0-g2ce1d0913"}
    {"ts":"2023-04-14T06:34:22.662Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:13","msg":"command line flags"}
    {"ts":"2023-04-14T06:34:22.662Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"dedup.minScrapeInterval\"=\"15s\""}
    {"ts":"2023-04-14T06:34:22.662Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"envflag.enable\"=\"true\""}
    {"ts":"2023-04-14T06:34:22.662Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"envflag.prefix\"=\"VM_\""}
    {"ts":"2023-04-14T06:34:22.662Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"loggerFormat\"=\"json\""}
    {"ts":"2023-04-14T06:34:22.662Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"retentionPeriod\"=\"1\""}
    {"ts":"2023-04-14T06:34:22.662Z","level":"info","caller":"VictoriaMetrics/lib/logger/flag.go:20","msg":"flag \"storageDataPath\"=\"/storage/vmstorage-1\""}
    {"ts":"2023-04-14T06:34:22.663Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/main.go:77","msg":"opening storage at \"/storage/vmstorage-1\" with -retentionPeriod=1"}
    {"ts":"2023-04-14T06:34:22.667Z","level":"info","caller":"VictoriaMetrics/lib/memory/memory.go:42","msg":"limiting caches to 5010650726 bytes, leaving 3340433818 bytes to the OS according to -memory.allowedPercent=60"}
    {"ts":"2023-04-14T06:34:22.667Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1072","msg":"loading MetricName->TSID cache from \"/storage/vmstorage-1/cache/metricName_tsid\"..."}
    {"ts":"2023-04-14T06:34:22.673Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1077","msg":"loaded MetricName->TSID cache from \"/storage/vmstorage-1/cache/metricName_tsid\" in 0.005 seconds; entriesCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T06:34:22.673Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1072","msg":"loading MetricID->TSID cache from \"/storage/vmstorage-1/cache/metricID_tsid\"..."}
    {"ts":"2023-04-14T06:34:22.673Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1077","msg":"loaded MetricID->TSID cache from \"/storage/vmstorage-1/cache/metricID_tsid\" in 0.001 seconds; entriesCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T06:34:22.673Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1072","msg":"loading MetricID->MetricName cache from \"/storage/vmstorage-1/cache/metricID_metricName\"..."}
    {"ts":"2023-04-14T06:34:22.675Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:1077","msg":"loaded MetricID->MetricName cache from \"/storage/vmstorage-1/cache/metricID_metricName\" in 0.001 seconds; entriesCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T06:34:22.675Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:873","msg":"loading curr_hour_metric_ids from \"/storage/vmstorage-1/cache/curr_hour_metric_ids\"..."}
    {"ts":"2023-04-14T06:34:22.675Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:876","msg":"nothing to load from \"/storage/vmstorage-1/cache/curr_hour_metric_ids\""}
    {"ts":"2023-04-14T06:34:22.675Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:873","msg":"loading prev_hour_metric_ids from \"/storage/vmstorage-1/cache/prev_hour_metric_ids\"..."}
    {"ts":"2023-04-14T06:34:22.675Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:876","msg":"nothing to load from \"/storage/vmstorage-1/cache/prev_hour_metric_ids\""}
    {"ts":"2023-04-14T06:34:22.675Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:829","msg":"loading next_day_metric_ids from \"/storage/vmstorage-1/cache/next_day_metric_ids\"..."}
    {"ts":"2023-04-14T06:34:22.675Z","level":"info","caller":"VictoriaMetrics/lib/storage/storage.go:832","msg":"nothing to load from \"/storage/vmstorage-1/cache/next_day_metric_ids\""}
    {"ts":"2023-04-14T06:34:22.681Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:259","msg":"opening table \"/storage/vmstorage-1/indexdb/1755ADF9F68785C1\"..."}
    {"ts":"2023-04-14T06:34:22.696Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:294","msg":"table \"/storage/vmstorage-1/indexdb/1755ADF9F68785C1\" has been opened in 0.015 seconds; partsCount: 6; blocksCount: 239, itemsCount: 95977; sizeBytes: 2461935"}
    {"ts":"2023-04-14T06:34:22.699Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:259","msg":"opening table \"/storage/vmstorage-1/indexdb/1755ADF9F68785C0\"..."}
    {"ts":"2023-04-14T06:34:22.708Z","level":"info","caller":"VictoriaMetrics/lib/mergeset/table.go:294","msg":"table \"/storage/vmstorage-1/indexdb/1755ADF9F68785C0\" has been opened in 0.009 seconds; partsCount: 0; blocksCount: 0, itemsCount: 0; sizeBytes: 0"}
    {"ts":"2023-04-14T06:34:22.745Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/56_56_20230414040330.000_20230414040330.000_1755AF19C405A0F2\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.745Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/2169_2169_20230414062545.000_20230414062613.760_1755AF19C405A806\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.747Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/31091_13609_20230414062041.348_20230414062235.210_1755AF19C405A7D9\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.748Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/2406706_13699_20230414032236.647_20230414062050.207_1755AF19C405A7C2\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.749Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/56_56_20230414040030.000_20230414040030.000_1755AF19C405A0CA\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.749Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/56_56_20230414035700.000_20230414035700.000_1755AF19C405A09D\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.750Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/56_56_20230414040200.000_20230414040212.000_1755AF19C405A0DE\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.751Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/40704_13611_20230414062229.384_20230414062420.209_1755AF19C405A7EE\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.752Z","level":"info","caller":"VictoriaMetrics/lib/storage/partition.go:1578","msg":"opened part \"/storage/vmstorage-1/data/small/2023_04/36877_13613_20230414062400.000_20230414062605.214_1755AF19C405A805\" in 0.001 seconds"}
    {"ts":"2023-04-14T06:34:22.768Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/main.go:92","msg":"successfully opened storage \"/storage/vmstorage-1\" in 0.106 seconds; partsCount: 9; blocksCount: 56925; rowsCount: 2517771; sizeBytes: 2189940"}
    {"ts":"2023-04-14T06:34:22.770Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:85","msg":"accepting vminsert conns at 0.0.0.0:8400"}
    {"ts":"2023-04-14T06:34:22.770Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:88","msg":"starting http server at http://127.0.0.1:8482/"}
    {"ts":"2023-04-14T06:34:22.770Z","level":"info","caller":"VictoriaMetrics/lib/httpserver/httpserver.go:89","msg":"pprof handlers are exposed at http://127.0.0.1:8482/debug/pprof/"}
    {"ts":"2023-04-14T06:34:22.771Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:152","msg":"accepting vmselect conns at 0.0.0.0:8401"}
    {"ts":"2023-04-14T06:34:51.220Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:164","msg":"accepted vmselect conn from 10.244.2.4:41638"}
    {"ts":"2023-04-14T06:34:51.220Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:207","msg":"processing vmselect conn from 10.244.2.4:41638"}
    {"ts":"2023-04-14T06:34:51.332Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:97","msg":"accepted vminsert conn from 10.244.1.5:40532"}
    {"ts":"2023-04-14T06:34:51.333Z","level":"info","caller":"VictoriaMetrics/app/vmstorage/transport/server.go:133","msg":"processing vminsert conn from 10.244.1.5:40532"}

#### [](#8-检查确认 "8. 检查确认")8\. 检查确认

##### [](#vmui "vmui")vmui

访问 vmui 查看指标数据，缺失了一部分，这是最后一次备份后产生的数据，符合正常预期

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304141437060.png)

##### [](#Grafana "Grafana")Grafana

Grafana 仪表盘查看，也有一个小缺口，同样符合预期

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/202304141438120.png)

* * *

_文章作者:_ [Da](/about)

_文章链接:_ [http://yo-yo.fun/victoriametrics/9934c747150d/](http://yo-yo.fun/victoriametrics/9934c747150d/)

_版权声明:_ 本博客所有文章除特別声明外，均采用 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.zh) 许可协议。转载请注明来源 [Da](/about) !

document.addEventListener("copy", function (e) { let toastHTML = '&lt;span&gt;复制成功，请遵循本文的转载规则&lt;/span&gt;&lt;button class="btn-flat toast-action" onclick="navToReprintStatement()" style="font-size: smaller"&gt;查看&lt;/a&gt;'; M.toast({html: toastHTML}) }); function navToReprintStatement() { $("html, body").animate({scrollTop: $("#reprint-statement").offset().top - 80}, 800); }

[Prometheus](/tags/Prometheus/) [监控](/tags/%E7%9B%91%E6%8E%A7/) [VictoriaMetrics](/tags/VictoriaMetrics/)

[](https://twitter.com/intent/tweet?text=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&url=https%3A%2F%2Fyo-yo.fun%2Fvictoriametrics%2F9934c747150d%2F&via=https%3A%2F%2Fyo-yo.fun)[](https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fyo-yo.fun%2Fvictoriametrics%2F9934c747150d%2F)[](https://plus.google.com/share?url=https%3A%2F%2Fyo-yo.fun%2Fvictoriametrics%2F9934c747150d%2F)[](http://connect.qq.com/widget/shareqq/index.html?url=https%3A%2F%2Fyo-yo.fun%2Fvictoriametrics%2F9934c747150d%2F&title=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&source=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&desc=%E5%B9%B3%E9%93%BA%E7%9B%B4%E5%8F%99%E7%9A%84%E6%8F%8F%E8%BF%B0.&pics=https%3A%2F%2Fyo-yo.fun%2Fmedias%2Flogo.png&summary="%E5%B9%B3%E9%93%BA%E7%9B%B4%E5%8F%99%E7%9A%84%E6%8F%8F%E8%BF%B0.")[](http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=https%3A%2F%2Fyo-yo.fun%2Fvictoriametrics%2F9934c747150d%2F&title=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&desc=%E5%B9%B3%E9%93%BA%E7%9B%B4%E5%8F%99%E7%9A%84%E6%8F%8F%E8%BF%B0.&summary=%E5%B9%B3%E9%93%BA%E7%9B%B4%E5%8F%99%E7%9A%84%E6%8F%8F%E8%BF%B0.&site=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&pics=https%3A%2F%2Fyo-yo.fun%2Fmedias%2Flogo.png)#### 微信扫一扫：分享<br>![Scan me!](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAAAXNSR0IArs4c6QAABv1JREFUeF7tndF22zAMQ9P//+jspGk6W6WAS0pp0417jSNLBAESdOa+XS6X62Xx3/W6vMTnDt7e3tBuHveMrj/uZ/w82uvxGvW5Oifdtzvc7fTL0WxALpftgGSDGmWV2pTKWpc1ERtcpj/WrJ6L7pfuTZ3xGLdPhlQ3fruRko8oMNlsood28uWAv33+WONlAHHBosF5HH4Ha1buSWqNO7NKKrU3t2703S8MqSxSLXbPykIqp4TZR1ZF+21APiJEk6AZMgi10nXHRqX51ZrnWEnlcaw1lJUR42RRd0GiG1Y1JCsVETANyCAVykxVjFa2uyGF9tg1kQ5rdg0B/6UZ0oDcvXZFbZ7SZTUgGwGh1KYUpTWHmDp3zXfK3ihjLglfxqk3ID7Fwy7Lf21+xRh0ZaDceGLFfBGT9h17W4nl1mmvkowdgXAy2YBMWuEdwY+Y9F8AciVNNuQgdeXZsUdkMmltyhrUrGndGL57q9yAnP3CrwDEGZzRNVNpiYi3YwJAZ2BRzVNspK1rNEVQZz1JPGFIA+KfcjuPlAaksuAsY9xaK93YmMFUw6lpjNajTFJKoVhz8iEPhrggwro+neHs6rwakAwSH9c6cJsh56CGDKGtJSmYtOZEa6kHSE6estLi7p8t4qS5cY3Ml7bXdUgNyD0CKulWPJL0IU56iJqtFNNxfce8HaOTrFKQex7P4R4hNyCH35UdA0eVogERtCTBcd3ejzPk8dteVzCjjc6KmDt0duZFryf1bcaC6ndp3Ii8v9emBsSHKmsW/YrzK1ANcVnwrI6DDPpUsG7HJpPlyvnGvbliTeT0nSFqlqX6ekr9lRawARmY1IDMPcfTGKJqCPUQoyI6GVEOWY3fK9o8yimVFueoCXvVOWcKI4t6A3IOKfUm1Y4t7LJ2ZKjbuMou1TK7vRGJdXvLstA1BKNdsJZglCx3aLJhd+gG5FybTiA1IP43uFkJUvXHMmR8QOWKHinI7qZqPBEVO+IlZkGjkhLtiTQrK8EPv9uAzAv3jwJCs5ZmRLaYuTbz9vkK8+jDK2pk3aMAwthoDfSAyhVyclgazFl//t8Bkn3OTWrJGMTxO64be1xPuzLFcpI0s/0SP+YSjt7/kyENyB1OOtklEwAHUpRADcjwfPzHAcm+fIa0oK7VfNazelfrZpLp9ksaHncmrEANiH5mMmsyRhC3AaJ8iMq4att3XJNqLDFtlXXJ7Et1fbN7qv26M8sa0oCcI0CejDoAG5CPN9TRYl1NQvoMKA2Io6Fy1CuHJkXP6fQOH6IAIQ2Ni5/zXl8kyy3YgMSQ7UiW28ppH0IKbKWNHF25Aj7T3o4u30lLluXExc8M5xZj2IDEhd49tqBy1wwpOvUxMbcDQgrijHrEk1CpUEWvcmgyc4rqpqsJo1S5Yo1lfPyhXGXhBsT/12oMCBmduMwkRRZvKHizNR2/7zRuJMlcsY5MoosleteJW6QB8RGg3Vh6dEIMnMuMar3aIaeullFjSNjo9hu29tnhYgNyD2MDMmlPoyyMGKqMZ6VePA2QsajvqBdOUaMiTQo3bUVVG+vOp/ZGpVhJskqWd+Y1IOf0+XFAyA/l3MhYMWLlIdBYgCsMGffmGOLYPfvcxUjF4Xiu9OikGuCKD2lAwK8DG5CYI9/CEDLZdXMgOuWMjpn9LvEYTrJoDSGxcaoQWgjiQ7JtoWtFyWHcWMLVk9k9Xh4QNctSGUey0QXVtZGkELosHJnnkoWOOLK+hsZLzrIaEO7Knb9oQCb96cszpPriAHWwylBNFfVqvThKJu0O6axu3JNjAJ1OlN/k0ICc/yLp0wCh2e02oBxv9rvZWhbdm2a+6gCz+6DyeKo/2Ue42e6C+gsyPXVdWXaEQ7q4yGfRfTQgApFfwxAy7aVmig7mskYzayQp2+g+6LnIdXbE0oCQMO67xgJC3v1Ot0NbS5rxY71yDUe2WaD1jTYJaipA2/qn/LkKOs6gkkF7+H8CEPK7LMeQKGCqG4sYotaI1lJmcbdHIudz7MUMaUD8y2cakAklabf3TzCE6j6Rm+xaThJpE5DNZCojSjLVWd0MLvRG2ff2NiD3CJCOcgsgrvMhHQ9lCB0tVNYjTcUuZpJ1aAe49Y8Tk6w5br4BOU+M35mnXvFHNXZkTSWjs5NUZdaOn9G9qCx3qvGyDCH1ZRas6vCPSoGSMBfwbLKsKMVWhjQgvODPpPvbAIk2QH0FkYRZ56MetVK3TyYFThodCz+TeWcNUQxpQL4W8LAONiDnsBBzeWQjba/LDMnKw+36Fbc6skrJWEUWyNCSnjl7XWW/6b+wQ2Upuo50Og3I5eL/8q5JjTET6MhA+ZwVWaCgqlbbeRkqQYRVp/3uHL9TVlSfeVMJaECuZ5I1Qwgv/l5zTKA/wj4Dc6KsbvMAAAAASUVORK5CYII=)<br>微信扫一扫即可分享！[](https://service.weibo.com/share/share.php?url=https%3A%2F%2Fyo-yo.fun%2Fvictoriametrics%2F9934c747150d%2F&title=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&pic=https%3A%2F%2Fyo-yo.fun%2Fmedias%2Flogo.png&appkey=)[](http://shuo.douban.com/!service/share?href=https%3A%2F%2Fyo-yo.fun%2Fvictoriametrics%2F9934c747150d%2F&name=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&text=%E5%B9%B3%E9%93%BA%E7%9B%B4%E5%8F%99%E7%9A%84%E6%8F%8F%E8%BF%B0.&image=https%3A%2F%2Fyo-yo.fun%2Fmedias%2Flogo.png&starid=0&aid=0&style=11)[](http://www.linkedin.com/shareArticle?mini=true&ro=true&title=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&url=https%3A%2F%2Fyo-yo.fun%2Fvictoriametrics%2F9934c747150d%2F&summary=%E5%B9%B3%E9%93%BA%E7%9B%B4%E5%8F%99%E7%9A%84%E6%8F%8F%E8%BF%B0.&source=Prometheus%20VictoriaMetrics%20%E5%8D%95%E6%9C%BA%E4%B8%8E%E9%9B%86%E7%BE%A4%E6%96%B9%E6%A1%88%20%7C%20LotusChing%20%E5%8D%9A%E5%AE%A2&armin=armin)
