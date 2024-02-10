https://habr.com/ru/companies/kts/articles/723980/#41

Тонкости настройки Grafana Loki
===============================

Привет! Меня зовут Игорь, я управляющий партнёр и системный архитектор в [KTS](https://kts.studio/). Мы занимаемся разными проектами, от создания корпоративных систем до нестандартных спецпроектов, мобильной разработкой и DevOps. Накопленный опыт позволяет помогать нашим клиентам справляться с инфраструктурой и её проблемными местами с помощью разных инструментов. 

В этой статье, подготовленной по мотивам [моего доклада](https://youtu.be/8ZAIwG2ftrE) в «Школе мониторинга» Slurm, хочу поделиться своим набором best practices «Как лучше всего настроить Grafana Loki для сбора логов в инфраструктуре». 

На мой взгляд, порог входа в Loki достаточно низкий, и в Интернете много туториалов. Поэтому я расскажу о более сложных и не совсем очевидных настройках, с которыми не раз сталкивался при работе с Grafana Loki. 

**Что будет в статье:** 

*   [Задача сбора логов](#1)
    
*   [Способы запуска Loki](#2)
    
    *   [Single-binary](#21)
        
    *   [Simple scalable deployment](#22)
        
    *   [Microservices mode](#23)
        
*   [Как устроена архитектура Grafana Loki](#3)
    
*   [Минимальная конфигурация Loki (filesystem)](#4)
    
    *   [S3 в качестве storage](#41)
        
*   [Конфигурация кластерных и High Availability решений](#5)
    
*   [Тайм-ауты](#6)
    
*   [Размеры сообщений](#7)
    
    *   [Чанки](#71)
        
*   [Параллелизм](#9)
    
*   [Оптимизация Write Path](#10)
    
*   [Объемы данных в Grafana Cloud](#11)
    
*   [Что вам с этого?](#12)
    
*   [С чего начинать учить DevOps?](#13)
    

Задача сбора логов
------------------

Четыре основных вопроса, которые нужно себе задать перед тем, как пытаться интегрировать какую-либо систему сбора логов:

1.  Как собрать логи?
    
2.  Как извлечь из них нужные метаданные, чтобы в будущем было легче идентифицировать логи?
    
3.  Как хранить эти данные, чтобы быстрее их записывать и находить? (самый сложный вопрос, пожалуй)
    
4.  Как найти логи?
    

Каждая система, будь то syslog, Elasticsearch, или системы, которые построены на ClickHouse — даже сама Grafana Loki — отвечают на эти вопросы по-разному.

Поэтому когда мы будем обсуждать архитектуру, то вернёмся к тому, чем концептуально отличается Grafana Loki от Elasticsearch, и почему она выигрывает в стоимости хранения логов.

Пайплайн сбора логов обычно выглядит просто и понятно.

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/33b/883/962/33b883962d13051f40192a7b1dfc80e9.png)

Итак, у нас есть большое количество разнообразных источников данных, откуда к нам прилетают логи: Kubernetes-кластеры, виртуальные машины, Docker-контейнеры и другие. Они проходят фазу сбора, процессинга, фильтрации.

Затем сохраняются в определенном виде, в зависимости от того, какое хранилище вы используете. Например, в виде базы данных, если работаете с ClickHouse, или в S3 Bucket в Grafana Loki. Но обратите внимание, что у каждого пользователя, который извлекает данные с другой стороны, могут быть разные сценарии действий. Например: извлечь логи за год или за последние 10 минут, чтобы отфильтровать данные по ним. 

Способы запуска Loki
--------------------

Существуют три способа запуска, которые, по большому счету, отличаются масштабированием. 

### Single-binary

![Этот способ самый простой и используется в основном в первичных туториалах по Loki. Логика такая: мы берем бинарь, запускаем его, подключаем к storage.](https://habrastorage.org/r/w1560/getpro/habr/upload_files/93e/b39/3b5/93eb393b5f7c3ad60458914fabd70369.png "Этот способ самый простой и используется в основном в первичных туториалах по Loki. Логика такая: мы берем бинарь, запускаем его, подключаем к storage.")

Этот способ самый простой и используется в основном в первичных туториалах по Loki. Логика такая: мы берем бинарь, запускаем его, подключаем к storage.  
  
Роль Storage может исполнять как файловая система, на которой запущен наш процесс, так и удалённый S3 Bucket. Здесь это значения не имеет. Такой подход имеет свои плюсы. Например, лёгкость запуска — потребуется минимум конфигурации, которую мы рассмотрим ниже. Минус — плохая отказоустойчивость: если машина выпадает, то логи не пишутся вообще.

Ситуацию можно улучшить так:

*   На двух разных виртуальных машинах запустить один и тот же процесс Loki с одинаковым конфигом
    
*   Объединить их в кластер с помощью секции `memberlist`
    
*   Перед этим поставить любой прокси —например Nginx или Haproxy
    
*   Главное — подключить всё к одному Storage
    

Соответственно, можно масштабировать процесс дальше, то есть запустить три, четыре, пять узлов.

Получится примерно такая схема:

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/ca7/2ec/b71/ca72ecb7171816846a68df6531ab2e5d.png)

Обратите внимание, что Loki занимается как записью, так и чтением. Поэтому нагрузка равномерно распределяется по всем инстансам. Но по факту она совсем неравномерная, потому что в одни моменты времени бывает много чтений, а в другие — много записей.

### SSD - Simple Scalable Deployment

Второй способ следует из первого и позволяет разделить процессы чтения и записи, чтобы мы могли запустить, например, более дискозависимые процессы на одном «железе», а менее дискозависимые на другом.

Для запуска вам необходимо передать флажок `-target=write` или `-target=read`, и в каждом из этих процессов запускаются те сущности, которые отвечают за конкретный путь запроса: write или read. Точно так же нужно поставить прокси перед всеми инстансами, который будет проксировать:

*   запросы на запись → на узлы записи
    
*   остальные запросы →  на узлы с чтением
    

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/818/dc7/b53/818dc7b5370b9e5ed5d0f40e7c5011b2.png)

Этот способ запуска Grafana считает наиболее рекомендуемым в плане работы и Grafana активно развивает именно его.

### Microservices mode

Microservices mode — более развёрнутый путь, когда мы каждый компонент Loki запускаем самостоятельно.

Компонентов очень много, но они легко отделяются друг от друга, и их можно распределить на две группы или даже три.

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/a09/7bb/eda/a097bbeda4a2b2ed8707d3bd5ed0dbbb.png)

1.  **Группа компонентов на запись:** дистрибьюторы и инджесторы, которые пишут в Storage.
    
2.  **Группа компонентов на чтение:** query-frontend, querier, index gateway. Это те компоненты, которые занимаются исполнением запросов.
    
3.  **Все остальные утилитарные компоненты**: например, кеши, compactor и другие.
    

Как устроена архитектура Grafana Loki
-------------------------------------

Остановимся чуть подробнее на архитектуре, чтобы в дальнейшем понимать, что вообще конфигурируется в той или иной секции. 

Для начала — как индексируются данные в блоке. В отличие от Elasticsearch, который по дефолту индексирует все документы полнотекстово и целиком, Grafana Loki идет по другому пути - он индексирует не содержимое логов, а только их метаданные, то есть время и лейблы.

Эти лейблы очень похожи на Prometheus-лейблы. Я думаю, многие из вас с ними знакомы. 

В итоге в Grafana мы храним очень маленький индекс данных, потому что данных в нем очень мало. Здесь хочу заметить, что у Elasticsearch индекс раздувается зачастую больше, чем сами данные.

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/c15/ffd/3fb/c15ffd3fbc04bed1dcb2af5748dab10d.png)

Неиндексируемые данные мы храним как они есть в порядке появления. Если их нужно отфильтровать, пользуемся "grep", своего рода встроенным в Loki. 

**Stream** — уникальный набор лейблов, несмотря на то, что логи могут идти из одного источника.

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/4fa/ce6/906/4face6906ba5a57c14757fce96b67c18.png)

В данном случае лейбл `component="supplier"` порождает новый стрим. Нам это понадобится в дальнейшем, т.к. настройки, которые связаны с рейт-лимитами и ограничениями, зачастую распространяются именно на стрим.

**Чанки** — набор из нескольких строчек логов. Вы взяли строчки лога, поместили их в одну сущность, назвали ее chunk, сжали и положили в Storage.

Теперь вернёмся к архитектуре и подробнее рассмотрим write path и read path и  их различия.

**Write path.** Точкой входа для записи логов в Loki является сущность под названием «Дистрибьютор». Это stateless-компонент. Его задача — распределить запрос на один или несколько инджесторов.

Инджесторы — это уже stateful-компоненты. Они объединены в так называемый [hash ring](https://en.wikipedia.org/wiki/Consistent_hashing) — систему консистентного хеширования. Она позволяет проще добавлять и удалять инджесторы из этого кластера. Все они подключены к одному Storage.

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/9e6/0ea/6b0/9e60ea6b0157124214026991f4ec5d68.png)

**Read path** устроен сложнее, но принцип похожий. Есть stateless-компоненты — query frontend и querier. Query frontend — компонент, который помогает разделить запрос, чтобы быстрее его выполнить. 

Например, нужно запросить данные за месяц. С помощью query frontend делим запрос на более мелкие интервалы и направляем в параллель на несколько querier, а потом объединяем результат.

**Querier** — компонент, который запрашивает логи из Storage. Если есть новые данные из инжесторов, которые в Storage еще не записаны, querier запрашивает их тоже.

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/d59/d40/9b7/d59d409b7c255a95e0a01a50d5367f99.png)

### Минимальная конфигурация Loki (filesystem)

Эта конфигурация нацелена на работу с файловой системой, когда Loki запущен в single instance режиме. Остановлюсь на более важных конфигурационных секциях.

**Loki** — это инструмент, который постоянно развивается, чтобы упростить и улучшить работу с конфигурацией. Пару версий назад появилось одно из самых лучших изменений — секция common. Когда в конфигурации есть несколько повторяющихся элементов, common объединяет их в разных частях конфига. То есть, если раньше приходилось настраивать `ring`, `storage` и другие элементы для инджестора, querier, дистрибьютора отдельно, то сейчас это все можно сделать в одном месте.

    auth_enabled: false
    
    server:
      http_listen_port: 3100
    
    common:
      path_prefix: /tmp/loki
      storage:
        filesystem:
          chunks_directory: /tmp/loki/chunks
          rules_directory: /tmp/loki/rules
      
      replication_factor: 1
    
      ring:
        instance_addr: 127.0.0.1
        kvstore:
          store: inmemory
    
    schema_config:
      configs:
        - from: 2020-09-07
          store: boltdb-shipper
          object_store: filesystem
          schema: v12
          index:
            prefix: loki_index_
            period: 24h

Здесь видно, что `storage` настроен в виде файловой системы, и указано, где хранятся чанки. Там же можно указать, где хранить индекс, правила для алертинга и т.д.

**schema\_config** — это конфиг для указания, как хранятся данные: чанки, индекс. Здесь в целом ничего не меняется с давних времен, но иногда появляются новые версии схемы. Поэтому рекомендую периодически читать чендж-логи, чтобы вовремя обновлять схемы в Loki и иметь последние улучшения.

Как только появляется несколько инстансов, необходимо объединить их в кластер, который работает на протоколе memberlist (также можно использовать сторонние системы, такие как etcd или consul). Это [Gossip](https://en.wikipedia.org/wiki/Gossip_protocol)\-протокол. Он автоматически находит узлы Loki по определенному принципу:

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/dd6/748/381/dd6748381d211e7d32b9e7faa52a1407.png)

    auth_enabled: false
    
    server:
      http_listen_port: 3100
    
    common:
      path_prefix: /tmp/loki
      storage:
        filesystem:
          chunks_directory: /tmp/loki/chunks
          rules_directory: /tmp/loki/rules
      
      replication_factor: 1
    
      ring:
        kvstore:
          store: memberlist
    
    schema_config:
      configs:
        - from: 2020-09-07
          store: boltdb-shipper
          object_store: filesystem
          schema: v12
          index:
            prefix: loki_index_
            period: 24h
    
    memberlist:
      join_members:
        - loki:7946

Есть множество разных способов автоматической конфигурации кластера, которые отлично работают. Например, в секции `memberlist.join_members` можно указать разные настройки:

*   Адрес одного хоста
    
*   Список адресов
    
*   `dns+loki.local:7946` — Loki сделает A/AAAA DNS запрос для получения списка хостов
    
*   `dnssrv+_loki._tcp.loki.local` — Loki сделает SRV DNS запрос для получения не только списка хостов, но и портов
    
*   `dnssrvnoa+_loki._tcp.loki.local` — SRV DNS **—** запрос без A/AAAA запроса
    

**Зачем это нужно?** Внутри Loki есть компоненты, которые должны знать друг о друге. Например, дистрибьюторы должны знать об инджесторах. Поэтому они регистрируются в одном кольце. После этого дистрибьюторы знают, на какие инджесторы отправить запрос на запись. Еще в пример можно привести компакторы, которые должны работать в единственном экземпляре в кластере. 

### S3 в качестве storage

S3 — наиболее рекомендованный способ хранения логов в Loki, особенно, если вы деплоите Loki в Kubernetes. Когда мы используем S3 в качестве storage, немного меняется конфигурация:

    auth_enabled: false
    
    server:
      http_listen_port: 3100
    
    common:
      path_prefix: /tmp/loki
      storage:
        
        s3:  # Секция filesystem меняется на s3
          
          s3: https://storage.yandexcloud.net
          bucketnames: loki-logs
          region: ru-central1
          access_key_id:
          secret_access_key:
      
      replication_factor: 1
    
      ring:
        kvstore:
          store: memberlist
    
    schema_config:
      configs:
        - from: 2020-09-07
          store: boltdb-shipper
          object_store: filesystem
          schema: v12
          index:
            prefix: loki_index_
            period: 24h
    
    memberlist:
      join_members:
        - loki:7946

Несколько советов:

*   Используйте `https://` вместо `s3://` - так вы гарантируете использование шифрованного соединения
    
*   `bucketnames` можно указать несколько для распределения хранения
    
*   Можно использовать `ACCESS_KEY_ID` и `SECRET_ACCESS_KEY` переменные окружения для конфигурации ключей доступа к S3
    

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/23a/011/d0a/23a011d0a23e51055bcdc9b729b3b642.png)

Мы меняем `storage` на S3, указываем `endpoint`, `bucketnames`, и другие конфигурации, которые относятся к S3.

Обратите внимание, что `bucketnames` во множественном числе, а значит, их можно указать сразу несколько. Тогда Loki начнёт равномерно распределять чанки по всем указанным бакетам, чтобы снизить нагрузку на один бакет. Например, это нужно, когда в вашем хостере есть ограничения по RPS на бакет.

### Конфигурация кластерных и High Availability решений

Допустим, мы записали логи в несколько узлов. Один из них отказал и запросить данные из него нельзя, потому что он не успел записать их в storage. 

High Availability в Loki обеспечивается через опцию `replication_factor`. Благодаря этой настройке дистрибьютор отправляет запрос на запись логов не в одну реплику инджестеров, а сразу в несколько.

    auth_enabled: false
    
    server:
      http_listen_port: 3100
    
    common:
      path_prefix: /tmp/loki
      storage:
        s3:
          s3: https://storage.yandexcloud.net
          bucketnames: loki-logs
          region: ru-central1
          access_key_id:
          secret_access_key:
      
      replication_factor: 3  # Обратите внимание на это поле
    
      ring:
        kvstore:
          store: memberlist
    
    schema_config:
      configs:
        - from: 2020-09-07
          store: boltdb-shipper
          object_store: filesystem
          schema: v12
          index:
            prefix: loki_index_
            period: 24h
    
    memberlist:
      join_members:
        - loki:7946

**replication\_factor:**

*   Distributor отправляет чанки в несколько Ingester
    
*   Минимум – 3 для 3х нод
    
*   Позволяет не работать 1 из 3 нод
    
*   maxFailure = (replication\_factor / 2) +1
    

Дистрибьютор отправляет чанки сразу в несколько инджесторов. Для дедупликации данных при использовании boltdb-shipper [применяется](https://grafana.com/docs/loki/latest/operations/storage/boltdb-shipper/#write-deduplication-disabled) секция конфига `chunk_cache_config` для чанков и `write_dedupe_cache_config` для индексов. Кроме этого querier'ы участвуют в дедупликации данных, сравнивая timestamp и сами логи (подробнее про это [тут](https://grafana.com/docs/loki/next/get-started/architecture/#read-path) и [тут](https://github.com/grafana/grafana/issues/26714#issuecomment-704792604)).

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/a2b/a86/5b5/a2ba865b573ecaf774009200b49dcfb2.png)

Тайм-ауты
---------

Достаточно тяжелая тема, потому что очень часто при неправильной настройке Loki можно встретить ошибки типа 502, 504.

![](https://habrastorage.org/r/w1560/getpro/habr/upload_files/319/114/a65/319114a650280ace8e6b2635b7380693.png)

Чтобы лучше разобраться в ошибках, нужно, во-первых, увеличить таймауты до достаточных значений в вашем проекте, а во-вторых — правильно сконфигурировать несколько видов таймаутов. 

1.  Таймауты `http_server_{write,read}_timeout` настраивают базовый таймаут на время ответа веб сервера
    
2.  `querier.query_timeout` и `querier.engine.timeout` настраивают максимальное время работы движка, непосредственно исполняющего запросы на чтение
    
        server:
          http_listen_port: 3100
          http_server_write_timeout: 310s
          http_server_read_timeout: 310s
        
        querier:
          query_timeout: 300s
          engine:
            timeout: 300s
    
3.  В случае использования прокси перед Loki, например NGINX, следует увеличить таймауты и в нём (`proxy_read_timeout` и `proxy_write_timeout`)
    
        server {
          proxy_read_timeout = 310s;
          proxy_send_timeout = 310s;
        }
    
4.  Также необходимо увеличить таймаут на стороне Grafana. Это настраивается в секции `[dataproxy]` в конфиге.
    
        [dataproxy]
        timeout = 310
    

Лучше всего, если вы поставите минимальный из всех 4-х видов таймаутов у querier (в примере – 300s). Так он завершится первым, а все следующие — например НТТР-серверы, Nginx или Grafana — чуть дольше.

Дефолтный тайм-аут очень маленький, поэтому я рекомендую увеличивать эти значения.

Размеры сообщений
-----------------

Тема может показаться сложной, потому что природа происхождения некоторых ошибок неочевидна. 

**Размеры сообщений,** `grpc_server_max_{recv,send}_msg_size` — это ограничения на возможный размер логов. При этом дефолтные значения очень маленькие. Например, если есть большой stack trace и в одной лого-линии отправляются логи размером 20 Мб, то он в принципе не влезет в этот лимит. Значит, его нужно увеличивать.

    server:
      http_listen_port: 3100
      grpc_server_max_recv_msg_size: 104857600  # 100 Mb
      grpc_server_max_send_msg_size: 104857600  # 100 Mb
    
    ingester_client:
      grpc_client_config:
        max_recv_msg_size: 104857600  # 100 Mb
        max_send_msg_size: 104857600  # 100 Mb

*   Дефолт 4Mb
    
*   Непосредственно влияет на размер логов обрабатываемых Loki
    

Энкодинг чанков тоже нельзя обойти стороной. Дефолтное значение — gzip, то есть максимальное сжатие. Grafana рекомендует переключиться на snappy — и я по опыту с ними согласен. Тогда логи может и занимают чуть-чуть больше места в сторадже, но становятся более производительными чтения и записи данных.

    ingester:
      chunk_encoding: snappy

*   Дефолт — gzip
    
    *   Лучшее сжатие
        
    *   Медленнее запросы
        
*   Рекомендуем snappy
    
    *   Сжатие чуть хуже
        
    *   Однако очень быстрое кодирование/декодирование
        

Чанки
-----

С чанками связано много настроек относительно их размеров и периодов времени жизни. Рекомендую их сильно не трогать. Но при этом нужно понимать, что вы делаете, когда меняете значения.

    ingester:
      chunk_idle_period: 2h
      chunk_target_size: 1536000
      max_chunk_age: 2h

Дефолты достаточно хорошие:

*   `chunk_block_size` и `chunk_retain_period` не рекомендуется менять совсем.
    
*   `сhunk_target_size` можно увеличить, если чанки в основном полные. Это даст им больше пространства.
    
*   `сhunk_idle_period` означает, сколько чанк будет жить в памяти инджестора, если в нём нет вообще никаких записей. Так вот, если ваши стримы в основном медленные и полупустые, лучше увеличить период. По дефолту — 30 минут.
    

Параллелизм 
------------

Еще один важный вопрос связан с конкурентностью.

    querier:
      max_concurrent: 8
    
    limits_config:
      max_query_parallelism: 24
      split_queries_by_interval: 15m
    
    frontend_worker:
      match_max_concurrent: true

*   `querier.max_concurrent` показывает, сколько запросов в параллель может обрабатывать один querier. Рекомендовано ставить примерно удвоенное количество CPU, дефолт = 10 (будьте внимательны к этим цифрам).
    
*   `limits_config.max_query_parallelism` показывает, сколько максимум параллельности есть у тенанта. Значения querier.max\_concurrent должны матчится с max query parallelism по формуле:  
    
    `[queriers count] * [max_concurrent] >= [max_query_parallelism]      `В нашем примере должны быть запущены минимум 3 `querier`, чтобы обеспечить параллелизм 24.
    

Оптимизация Write Path
----------------------

Здесь есть несколько настроек, связанных с записью — `ingestion_write_mb, ingestion_burst_size_mb`.

    limits_config:
      ingestion_rate_mb: 20
      ingestion_burst_size_mb: 30

Если здесь стоят достаточно низкие дефолты, рекомендую увеличить их. Это позволит гораздо больше и чаще писать логи.  Остальные значения относятся к tenant, поэтому с ними нужно быть аккуратнее.

Для стримов есть отдельная настройка — `per_stream_rate_limit`.

    limits_config:
      per_stream_rate_limit: "3MB"
      per_stream_rate_limit_burst: "10MB"

На примере показаны более-менее нормальные дефолты. Но если вы начинаете в них упираться, то рекомендую разбить стрим на несколько — добавить лейбл. Это уменьшит rate-limit стрима. В обратной ситуации можно пробовать увеличивать лимиты. 

### Объемы данных в Grafana Cloud

Эти данные я вытащил из одной их презентации.

Grafana Loki обрабатывает:

*   500 МБ логов в секунду
    
*   43 ТВ в день;
    
*   1,25 ПВ в месяц.
    

Они стремятся обеспечивать нагрузку примерно 10 МВ в секунду на инджестор. При этом использование памяти всего лишь около 10 GB.

Эти данные позволяют пользователям примерно представить, какую инфраструктуру им запускать. Для примера: у нас на одном из проектов rate гораздо ниже, около 20 или 30 GB в день. Тем не менее три инджестора справляются с таким потоком данных с большим запасом. 