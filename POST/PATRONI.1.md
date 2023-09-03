- https://habr.com/ru/companies/otus/articles/755032/
- https://github.com/zalando/patroni/blob/master/docker-compose-citus.yml

Создание масштабируемой и высокодоступной системы Postgres с помощью Patroni 3.0 и Citus
========================================================================================


[Автор оригинала: Alexander Kukushkin](https://www.citusdata.com/blog/2023/03/06/patroni-3-0-and-citus-scalable-ha-postgres/)

Citus — это расширение для PostgreSQL, которое обеспечивает масштабируемость PostgreSQL за счет прозрачного распределения и/или репликации таблиц на одном или нескольких узлах PostgreSQL. Citus можно использовать как на облачной платформе Azure, так и на собственных серверах, поскольку [расширение базы данных Citus](https://github.com/citusdata/citus) имеет полностью открытый исходный код, и вы можете [загрузить](https://www.citusdata.com/download/) его и установить где угодно.

Типичный кластер Citus состоит из специального узла, называемого координатором, и нескольких рабочих узлов (воркеров). Обычно приложения отправляют свои запросы на узел-координатор Citus, который передает их воркерам и накапливает результаты. (Если, конечно, вы не используете фичу Citus "Запрос с любого узла". Это опциональная возможность, появившаяся в Citus 11. В таком случае запросы могут быть направлены на любой из узлов кластера).

Между тем, одним из наиболее часто задаваемых вопросов является: "Как Citus обрабатывает сбои координатора или воркеров? Какова история обеспечения высокой доступности (HA)?"

За исключением случаев, когда вы [работаете с Citus как управляемым сервисом](https://learn.microsoft.com/azure/cosmos-db/postgresql/concepts-high-availability) в облаке, ответ до сих пор был не очень хорош — просто используйте потоковую передачу PostgreSQL для запуска координатора и воркеров c HA, а как обрабатывать аварийные переключения \[во время сбоя\] (failover) — решать вам.

Конкретно для Citus, важно, чтобы координатор и воркеры продолжали работать надежно, даже если один из них перестал отвечать. Это обеспечивает непрерывную доступность и позволяет приложениям продолжать работу без значительных перерывов, даже если произошел сбой. Данные сбои могут возникнуть по разным причинам, таким как аппаратные неисправности, программные ошибки и т. д.

Обеспечение высокой доступности (HA) означает, что система настроена таким образом, чтобы минимизировать простои и перерывы в работе в случае сбоя. Это может включать в себя автоматическое обнаружение сбоев, переключение на резервные компоненты и восстановление работы системы без значительного воздействия на пользователей.

В этой статье вы узнаете, как Patroni 3.0+ можно использовать для деплоя высокодоступного кластера базы данных Citus — всего лишь добавив несколько строк в конфигурационный файл Patroni. Давайте рассмотрим эти темы подробнее: 

* Что такое Patroni?
    
* Представление поддержки Citus в Patroni 3.0
    
* Наш первый распределенный кластер Citus с Patroni
    
* Наше первое контролируемое переключение высокой доступности (HA switchover) с использованием Patroni и Citus
    
* Планы на будущее и возможные улучшения
    
* Заключение: Комбинация Patroni и Citus для обеспечения высокой доступности PostgreSQL в распределенной среде 
    

### Уточнение терминологии: многочисленные конкурирующие значения термина "кластер"

В мире Postgres термин "кластер" имеет множество различных значений и может применяться в разных ситуациях. Это способно вызвать путаницу, так как одно и то же слово употребляется для описания разных концепций. Вот как мы будем использовать этот термин в данной статье, чтобы избежать недоразумений:

1.  **Кластер базы данных** (стандарт SQL называет это `catalog cluster`): совокупность баз данных, управляемая одним экземпляром (инстансом) работающего сервера базы данных.
    
2.  **Кластер PostgreSQL** (или кластер Patroni): несколько экземпляров базы данных, главный (primary) с несколькими резервными узлами (standby nodes), обычно связанными через потоковую репликацию.
    
3.  **Кластер Citus**: распределенный набор узлов базы данных, образующих один или несколько логически связанных кластеров PostgreSQL с использованием расширения Citus для Postgres.
    
4.  **Кластер Kubernetes**: набор узловых машин для запуска контейнеризованных приложений. Kubernetes можно использовать для деплоя кластеров Citus или PostgreSQL в масштабе.
    

В этой статье мы в основном будем говорить о распределенных кластерах Citus и кластерах PostgreSQL, управляемых Patroni (или кластерах Patroni).

### Что такое Patroni? (можете пропустить этот раздел, если уже все знаете)

Patroni - это инструмент с открытым исходным кодом, который помогает деплоить, управлять и мониторить высокодоступные кластеры PostgreSQL с использованием физической потоковой репликации. Демон Patroni запускается на всех узлах кластера PostgreSQL, отслеживает состояние процесса(ов) Postgres и публикует это состояние в распределенное хранилище ключ-значение.

Существует несколько свойств, которые требуются от распределенного хранилища ключ-значение (или хранилища конфигурации) (DCS, Distributed Key-Value):

1.  Оно должно реализовывать алгоритм консенсуса, такой как Raft, Paxos, Zab или подобный
    
2.  Оно должно поддерживать операции Compare-And-Set (CAS) (сравни и установи)
    
3.  Оно должно иметь механизмы для управления сроком действия ключей с помощью сессий (Sessions), аренды (Lease) и времени жизни (TTL - Time To Live)
    
4.  Хорошо, если оно предоставляет API для наблюдения (WATCH API), чтобы подписываться на изменения определенных ключей и получать уведомления о них
    

Последние два свойства иметь желательно, но Patroni все равно может работать, даже если они не поддерживаются/реализованы, в то время как первые два являются обязательными.

Patroni поддерживает следующие DCS: etcd, Consul, ZooKeeper и Kubernetes API:

* Consul и etcd реализуют протокол Raft
    
* ZooKeeper реализует протокол Zab
    
* API Kubernetes поддерживается с использованием etcd
    

Каждый узел кластера Patroni/PostgreSQL поддерживает в DCS ключ `member` (ключ участника) с собственным именем. Значение ключа member содержит адрес узла (хост и порт) и состояние PostgreSQL: роль (primary или standby), текущий Postgres [LSN](https://www.postgresql.org/docs/current/datatype-pg-lsn.html) (log sequence number – уникальный идентификатор каждого изменения, происходящего в базе данных), метки и так далее. Ключи участников позволяют системе автоматически обнаруживать все узлы в данном кластере Patroni/PostgreSQL.

Patroni, работающий рядом с главным (primary) узлом PostgreSQL, также поддерживает ключ `/leader` в распределенном хранилище (Distributed Key-Value Store)

* Ключ `/leader` имеет ограниченное время жизни (TTL), и если не происходит регулярных обновлений (своего рода "heartbeat"), срок действия ключа может закончиться.
    
* Если ключ `/leader` отсутствует, резервные узлы начинают соревноваться за роль лидера, пытаясь создать новый ключ `/leader`.
    
* Patroni на узле, который создал новый ключ `/leader`, повышает статус Postgres до главного (primary). На остальных резервных (standby) узлах Patroni  перенастраивает Postgres для потоковой репликации от нового primary.
    
* Важно отметить, что все операции с ключом `/leader` защищены операцией Compare-And-Set.
    

Patroni на standby узлах использует ключи `/leader` и member для определения, какой из узлов является `primary`, и настраивает управляемый (standby) узел PostgreSQL для репликации данных от primary узла. Кроме автоматического переключения для обеспечения высокой доступности (Automatic Failover for HA), Patroni помогает автоматизировать множество операций управления:

* Инициализация новых узлов с использованием pg_basebackup или сторонних инструментов резервного копирования, таких как pgBackRest, wal-g/wal-e, barman и так далее.
    
* Обеспечивает синхронную репликацию.
    
* При переключении ролей и восстановлении кластера после сбоя (failover), Patroni поддерживает выполнение инструмента [pg_rewind](https://www.postgresql.org/docs/current/app-pgrewind.html), который помогает старому primary узлу присоединиться к кластеру в качестве резервного (standby). 
    
* Поддержка точечного восстановления во времени (PITR): Patroni может помочь с восстановлением данных в конкретный момент времени. Вместо создания нового инстанса с помощью initdb, Patroni может инициализировать новые кластеры PostgreSQL из резервной копии.
    
* И многое другое.
    

![Рисунок 1. Типичное развертывание высокодоступного (HA) кластера PostgreSQL под управлением Patroni с использованием etcd в качестве распределенного хранилища ключ-значение (DCS) и HAProxy для предоставления единой точки подключения клиентов к основному (primary) узлу. ](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/8c36916520d61c6616c561a06571f9b8.png "Рисунок 1. Типичное развертывание высокодоступного (HA) кластера PostgreSQL под управлением Patroni с использованием etcd в качестве распределенного хранилища ключ-значение (DCS) и HAProxy для предоставления единой точки подключения клиентов к основному (primary) узлу. ")

Рисунок 1\. Типичное развертывание высокодоступного (HA) кластера PostgreSQL под управлением Patroni с использованием etcd в качестве распределенного хранилища ключ-значение (DCS) и HAProxy для предоставления единой точки подключения клиентов к основному (primary) узлу. 

### Представление поддержки Citus в Patroni 3.0

Версия Patroni 3.0 вводит официальную поддержку Citus для Patroni. Хотя до выпуска Patroni 3.0 уже была возможность запускать Patroni с Citus (благодаря гибкости и расширяемости Patroni!), версия 3.0 сделала интеграцию с Citus для обеспечения высокой доступности более эффективной и удобной в использовании.

Patroni полагается на распределенное хранилище ключей (DCS) для обнаружения узлов кластера PostgreSQL и настройки потоковой репликации. Как уже объяснено в разделе "Уточнение терминологии", кластер Citus - это всего лишь набор кластеров PostgreSQL, логически связанных между собой с помощью расширения Citus для Postgres. Следовательно, было логичным расширить Patroni так, чтобы он мог обнаруживать не только узлы данного кластера Patroni/PostgreSQL, но также обнаруживать узлы в кластере Citus, например, при добавлении нового рабочего узла (воркера) Citus. По мере обнаружения узлов Citus они добавляются в [метаданные pg\_dist\_node координатора Citus](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*flnwfy*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE1NjMxOC42LjEuMTY5MjE1NjMyNS4wLjAuMA..).

Существует всего несколько простых правил, которые следует соблюдать, чтобы активировать поддержку Citus в Patroni:

1.  **Скоуп (имя кластера)**: [Скоуп](https://patroni.readthedocs.io/en/latest/SETTINGS.html#global-universal) (область действия) должна быть одинаковой для всех узлов Citus. Это означает, что имя кластера должно быть идентичным на всех узлах, чтобы обеспечить правильную работу и обнаружение узлов внутри кластера. Таким образом, скоуп (имя кластера) служит для определения принадлежности узлов к определенному кластеру и обеспечивает корректное взаимодействие и управление между ними.
    
2.  **Имя пользователя/пароль суперпользователя**: Желательно, чтобы имя пользователя и пароль суперпользователя были одинаковыми на узле-координаторе и воркерах. Если это не так, то необходимо настроить [подключения](https://docs.citusdata.com/en/latest/admin_guide/cluster_management.html?_gl=1*xwp5nu*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE1NjMxOC42LjEuMTY5MjE1NjMyNS4wLjAuMA..#connection-management) суперпользователя между узлами с использованием клиентских сертификатов. Разумеется, [pg_hba.conf](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html) должен разрешать соединения с суперпользователем на всех узлах.
    
3.  **Доступ к REST API**: Доступ к [REST API](https://patroni.readthedocs.io/en/latest/SETTINGS.html#rest-api) Patroni означает, что у рабочих узлов (воркеров) должна быть возможность обращаться к REST API, который предоставляется координатору (узлу-координатору) в Patroni. Для того чтобы воркеры могли обращаться к REST API координатора, им необходимо иметь подходящие учетные данные (например, имя пользователя и пароль) или клиентские сертификаты, если таковые используются для аутентификации. Эти данные позволяют идентифицировать и авторизовать воркеров для доступа к API.
    
4.  **Добавление Citus в конфигурационный файл Patroni**: Вам следует добавить определенный раздел в файл patroni.yaml, чтобы указать Patroni о наличии узлов Citus и их параметрах. Данные указания означают, что для успешной интеграции Citus с Patroni необходимо обеспечить согласованность и правильную конфигурацию между узлами. Это включает в себя общий скоуп для всех узлов, правильные учетные данные для суперпользователя и настройки доступа к REST API. Когда все эти шаги выполнены корректно, Patroni и Citus могут совместно обеспечивать высокую доступность и надежность вашего PostgreSQL кластера. Полный пример конфигурационного файла Patroni доступен на [GitHub](https://github.com/zalando/patroni/blob/master/postgres0.yml). 
    

    citus:
      group: X  # 0 for coordinator and 1, 2, 3, etc for workers
      database: citus  # must be the same on all nodes

Вот и всё! Теперь вы можете запустить Patroni и наслаждаться интеграцией с Citus.

**Patroni позаботиться обо всем:**

1.  Расширение Citus будет автоматически добавлено в [shared\_preload\_libraries](https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-SHARED-PRELOAD-LIBRARIES) (на первое место в списке!)
    
2.  Если значение [max\_prepared\_transactions](https://www.postgresql.org/docs/current/runtime-config-resource.html#GUC-MAX-PREPARED-TRANSACTIONS) не задано явно в [глобальной динамической конфигурации](https://patroni.readthedocs.io/en/latest/dynamic_configuration.html), Patroni автоматически установит его равным 2*[max_connections](https://www.postgresql.org/docs/15/runtime-config-connection.html#GUC-MAX-CONNECTIONS). То есть, другими словами, если параметр max\_prepared\_transactions (максимальное количество подготовленных транзакций, которые могут быть активными одновременно) не был установлен вручную в конфигурации PostgreSQL, то Patroni автоматически установит его значение равным удвоенному значению параметра max_connections (максимальное количество одновременных подключений к базе данных PostgreSQL). Это позволяет обеспечить достаточное количество подготовленных транзакций для обработки потенциальных запросов.
    
3.  Сначала будет автоматически создана база данных citus.database, затем последует выполнение команды CREATE EXTENSION citus;.
    
4.  Текущие учетные данные суперпользователя (из файла patroni.yaml) будут добавлены в таблицу [pg\_dist\_authinfo](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*199ycev*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE1NjMxOC42LjEuMTY5MjE1NjMyNS4wLjAuMA..#connection-credentials-table), чтобы разрешить межузловое взаимодействие. Не забудьте обновить их, если впоследствии решите изменить [username/password/sslcert/sslkey](https://patroni.readthedocs.io/en/latest/SETTINGS.html#postgresql) суперпользователя!
    
5.  Главный (primary) узел-координатор автоматически отслеживает доступные главные узлы-воркеры в системе Citus. Как только новый primary воркер обнаруживается, он регистрируется в таблице [pg\_dist\_node](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*1mrjgaq*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE1NjMxOC42LjEuMTY5MjE1NjMyNS4wLjAuMA..#worker-node-table) с использованием функции [citus\_add\_node()](https://docs.citusdata.com/en/latest/develop/api_udf.html?_gl=1*2otc66*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE2MjU4NS43LjAuMTY5MjE2MjYwNS4wLjAuMA..#citus-add-node). Это позволяет системе Citus знать о наличии всех primary воркеров и эффективно координировать распределение и репликацию данных между ними.
    
6.  Patroni также будет поддерживать таблицу [pg\_dist\_node](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*ue76ro*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE2MjU4NS43LjAuMTY5MjE2MjYwNS4wLjAuMA..#worker-node-table) в случае  failover/switchover (автоматическое/плановое переключение) на координаторе или рабочих кластерах. То есть, Patroni обеспечивает корректное обновление и управление информацией в этой таблице при сбоях или изменениях ролей узлов, чтобы все узлы оставались синхронизированными и готовыми к действию.
    
7.  И, наконец, при выполнении управляемого переключения (switchover) в рабочем кластере, Patroni также приостановит клиентские соединения на основном узле координатора. Это делается с целью предотвратить появление видимых ошибок для клиентов системы. 
    

На рисунке ниже приведен пример деплоя Citus в режиме высокой доступности (HA) с использованием Patroni 3.0.0.

![Рисунок 2: Patroni на узле-координаторе автоматически обнаруживает и регистрирует воркеры Citus в метаданных кластера. Все соединения между распределенными узлами Citus работают без промежуточного ПО типа HAProxy, что уменьшает сложность и затраты на обслуживание инфраструктуры. Второй экземпляр HAproxy (справа) предоставляется для сценария, когда ваше приложение использует опциональную фичу "запрос с любого узла" в Citus, иногда применяемую для увеличения параллелизации и пропускной способности.](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/7293e655642a3b9f61da336cb2201278.png "Рисунок 2: Patroni на узле-координаторе автоматически обнаруживает и регистрирует воркеры Citus в метаданных кластера. Все соединения между распределенными узлами Citus работают без промежуточного ПО типа HAProxy, что уменьшает сложность и затраты на обслуживание инфраструктуры. Второй экземпляр HAproxy (справа) предоставляется для сценария, когда ваше приложение использует опциональную фичу "запрос с любого узла" в Citus, иногда применяемую для увеличения параллелизации и пропускной способности.")

Рисунок 2: Patroni на узле-координаторе автоматически обнаруживает и регистрирует воркеры Citus в метаданных кластера. Все соединения между распределенными узлами Citus работают без промежуточного ПО типа HAProxy, что уменьшает сложность и затраты на обслуживание инфраструктуры. Второй экземпляр HAproxy (справа) предоставляется для сценария, когда ваше приложение использует опциональную фичу "запрос с любого узла" в Citus, иногда применяемую для увеличения параллелизации и пропускной способности.

### Наш первый распределенный кластер Citus с Patroni

Для деплоя нашего тестового кластера локально мы будем использовать платформу [docker](https://www.docker.com/) и инструмент [docker-compose](https://pypi.org/project/docker-compose/). Файл [Dockerfile.citus](https://github.com/zalando/patroni/blob/master/Dockerfile.citus) находится в [репозитории Patroni](https://github.com/zalando/patroni).

Сначала нам нужно клонировать репозиторий Patroni и собрать docker-образ `patroni-citus`:

    $ git clone https://github.com/zalando/patroni.git
    $ cd patroni
    $ docker build -t patroni-citus -f Dockerfile.citus .
    Sending build context to Docker daemon  573.6MB
    Step 1/36 : ARG PG_MAJOR=15
    … skip intermediate logs
    Step 36/36 : ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
    ---> Running in 1933967fcb58
    Removing intermediate container 1933967fcb58
    ---> 0eea66f3c4c7
    Successfully built 0eea66f3c4c7
    Successfully tagged patroni-citus:latest

После того как образ готов, мы развернем стек с помощью следующих команд:

    $ docker-compose -f docker-compose-citus.yml up -d
    Creating demo-etcd1   ... done
    Creating demo-work1-2 ... done
    Creating demo-coord2  ... done
    Creating demo-coord3  ... done
    Creating demo-work1-1 ... done
    Creating demo-etcd2   ... done
    Creating demo-work2-2 ... done
    Creating demo-coord1  ... done
    Creating demo-work2-1 ... done
    Creating demo-haproxy ... done
    Creating demo-etcd3   ... done

Затем мы можем проверить, что контейнеры запущены и работают:

    $ docker ps
    CONTAINER ID   IMAGE            COMMAND                  CREATED              STATUS              PORTS                              NAMES
    e7740f00796d   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-etcd2
    8a3903ca40a7   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-etcd3
    3d384bf74315   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute   0.0.0.0:5000-5001->5000-5001/tcp   demo-haproxy
    2f6c9e4c63b8   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-work2-1
    4bd35bfdba58   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-coord1
    8dce43a4f499   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-work1-1
    e76372163464   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-work2-2
    0de7bf5044fd   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-coord3
    633f9700e86f   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-coord2
    f50bb1e1d6e7   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-etcd1
    03bd34403ac2   patroni-citus    "/bin/sh /entrypoint…"   About a minute ago   Up About a minute                                      demo-work1-2
    

Всего у нас есть 11 контейнеров:

* три контейнера с etcd (образуют трехузловой кластер etcd),
    
* семь контейнеров с Patroni+PostgreSQL+Citus (три узла-координатора и два рабочих (воркера) кластера по два узла каждый), и
    
* один контейнер с HAProxy.
    

HAProxy (сервер балансировки нагрузки) работает как посредник между клиентами и серверами базы данных. На порте 5000 он обеспечивает подключение к главному (primary) узлу координатора Citus, который играет роль центральной точки управления. А на порте 5001 HAProxy осуществляет балансировку нагрузки между главными рабочими узлами, распределяя запросы от клиентов между несколькими воркерами, чтобы обеспечить более эффективное использование ресурсов и повысить производительность:

Через несколько секунд наш кластер Citus будет готов к работе. Мы можем проверить это, используя инструмент `patronictl` из контейнера `demo-haproxy`:

    $ docker exec -ti demo-haproxy bash
    postgres@haproxy:~$ patronictl list
    + Citus cluster: demo ---------+--------------+---------+----+-----------+
    | Group | Member  | Host       | Role         | State   | TL | Lag in MB |
    +-------+---------+------------+--------------+---------+----+-----------+
    |     0 | coord1  | 172.19.0.8 | Sync Standby | running |  1 |         0 |
    |     0 | coord2  | 172.19.0.7 | Leader       | running |  1 |           |
    |     0 | coord3  | 172.19.0.6 | Replica      | running |  1 |         0 |
    |     1 | work1-1 | 172.19.0.5 | Sync Standby | running |  1 |         0 |
    |     1 | work1-2 | 172.19.0.2 | Leader       | running |  1 |           |
    |     2 | work2-1 | 172.19.0.9 | Sync Standby | running |  1 |         0 |
    |     2 | work2-2 | 172.19.0.4 | Leader       | running |  1 |           |
    +-------+---------+------------+--------------+---------+----+-----------+

Теперь давайте подключимся к primary узлу координатора через `HAProxy` и убедимся, что расширение Citus создано, а воркеры зарегистрированы в метаданных координатора:

    postgres@haproxy:~$ psql -h localhost -p 5000 -U postgres -d citus
    Password for user postgres: postgres
    psql (15.1 (Debian 15.1-1.pgdg110+1))
    SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
    Type "help" for help.
    
    citus=# \dx
                        List of installed extensions
         Name      | Version |   Schema   |         Description
    ---------------+---------+------------+------------------------------
    citus          | 11.2-1  | pg_catalog | Citus distributed database
    citus_columnar | 11.2-1  | pg_catalog | Citus Columnar extension
    plpgsql        | 1.0     | pg_catalog | PL/pgSQL procedural language
    (3 rows)
    
    citus=# select nodeid, groupid, nodename, nodeport, noderole
    from pg_dist_node order by groupid;
    nodeid | groupid |  nodename  | nodeport | noderole
    -------+---------+------------+----------+----------
         1 |       0 | 172.19.0.7 |     5432 | primary
         3 |       1 | 172.19.0.2 |     5432 | primary
         2 |       2 | 172.19.0.4 |     5432 | primary
    (3 rows)

Пока все хорошо :).

В данном конкретном случае Patroni настроен на использование клиентских сертификатов в дополнение к паролям для суперпользовательских соединений между узлами. Так как Citus активно использует суперпользовательские соединения для общения между узлами, Patroni также позаботился о настройке параметров аутентификации через [pg\_dist\_authinfo](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*1hk5x6w*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE2MjU4NS43LjAuMTY5MjE2MjYwNS4wLjAuMA..#connection-credentials-table):

    citus=# select * from pg_dist_authinfo;
    nodeid | rolename |                                                   authinfo
    -------+----------+--------------------------------------------------------------------------------------------------------------
         0 | postgres | password=postgres sslcert=/etc/ssl/certs/ssl-cert-snakeoil.pem sslkey=/etc/ssl/private/ssl-cert-snakeoil.key
    (1 row)

Не пугайтесь пароля, который вы видите в поле authinfo. Почему? Потому что, во-первых, доступ к [pg\_dist\_authinfo](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*136dns9*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE2MjU4NS43LjAuMTY5MjE2MjYwNS4wLjAuMA..#connection-credentials-table) имеет только суперпользователь. Во-вторых, можно настроить [аутентификацию](https://docs.citusdata.com/en/latest/admin_guide/cluster_management.html?_gl=1*136dns9*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE2MjU4NS43LjAuMTY5MjE2MjYwNS4wLjAuMA..#connection-management), используя только клиентские сертификаты, что, собственно, и рекомендуется.

### Наше первое контролируемое переключение высокой доступности (HA switchover) с использованием Patroni и Citus

В терминологии обеспечение высокой доступности Postgres и терминологии Patroni "переключение" (switchover) - это преднамеренная смена приоритета. То есть, контролируемый процесс смены ролей (смены приоритета) между узлами для обеспечения продолжения работы системы в случае сбоя или планового обслуживания

Прежде чем выполнять переключение с помощью Patroni, давайте сначала создадим распределенную таблицу Citus и начнем записывать в нее данные с помощью команды `\watch` [psql](https://www.postgresql.org/docs/current/app-psql.html):

    citus=# create table my_distributed_table(id bigint not null generated always as identity, value double precision);
    CREATE TABLE
    citus=# select create_distributed_table('my_distributed_table', 'id');
     create_distributed_table
    --------------------------
    
    (1 row)
    
    citus=# with inserted as (
        insert into my_distributed_table(value)
         values(random()) RETURNING id
    ) SELECT now(), id from inserted\watch 0.01

Запрос `\watch 0.01` будет выполняться каждые 10 мс, при этом он вернет вставленный `id` плюс текущее время с микросекундной прецессией. Это позволит наблюдать, как switchover повлияет на выполнение запросов. 

Тем временем, в другом терминале мы инициируем switchover на одном из воркеров:

    $ docker exec -ti demo-haproxy bash
    
    postgres@haproxy:~$ patronictl switchover
    Current cluster topology
    + Citus cluster: demo ---------+--------------+---------+----+-----------+
    | Group | Member  | Host       | Role         | State   | TL | Lag in MB |
    +-------+---------+------------+--------------+---------+----+-----------+
    |     0 | coord1  | 172.19.0.8 | Sync Standby | running |  1 |         0 |
    |     0 | coord2  | 172.19.0.7 | Leader       | running |  1 |           |
    |     0 | coord3  | 172.19.0.6 | Replica      | running |  1 |         0 |
    |     1 | work1-1 | 172.19.0.5 | Sync Standby | running |  1 |           |
    |     1 | work1-2 | 172.19.0.2 | Leader       | running |  1 |         0 |
    |     2 | work2-1 | 172.19.0.9 | Sync Standby | running |  1 |         0 |
    |     2 | work2-2 | 172.19.0.4 | Leader       | running |  1 |           |
    +-------+---------+------------+--------------+---------+----+-----------+
    Citus group: 2
    Primary [work2-2]:
    Candidate ['work2-1'] []:
    When should the switchover take place (e.g. 2023-02-06T14:27 )  [now]:
    Are you sure you want to switchover cluster demo, demoting current leader work2-2? [y/N]: y
    2023-02-06 13:27:56.00644 Successfully switched over to "work2-1"
    + Citus cluster: demo (group: 2, 7197024670041272347) ------+
    | Member  | Host       | Role    | State   | TL | Lag in MB |
    +---------+------------+---------+---------+----+-----------+
    | work2-1 | 172.19.0.9 | Leader  | running |  1 |           |
    | work2-2 | 172.19.0.4 | Replica | stopped |    |   unknown |
    +---------+------------+---------+---------+----+-----------+

Наконец, после завершения switchover давайте проверим логи в первом терминале:

    Mon Feb  6 13:27:54 2023 (every 0.01s)
    
                 now              |  id
    ------------------------------+------
    2023-02-06 13:27:54.441635+00 | 1172
    (1 row)
    
    Mon Feb  6 13:27:54 2023 (every 0.01s)
    
                now              |  id
    -----------------------------+------
    2023-02-06 13:27:54.45187+00 | 1173
    (1 row)
    
    Mon Feb  6 13:27:57 2023 (every 0.01s)
    
                 now              |  id
    ------------------------------+------
    2023-02-06 13:27:57.345054+00 | 1174
    (1 row)
    
    Mon Feb  6 13:27:57 2023 (every 0.01s)
    
                 now              |  id
    ------------------------------+------
    2023-02-06 13:27:57.351412+00 | 1175
    (1 row)

Как видно, перед тем как произошло switchover, запросы регулярно выполнялись каждые 10 миллисекунд. Между идентификаторами `1173` и `1174` вы можете заметить короткий скачок задержки в 2893 миллисекунды (менее 3 секунд). Так проявилось управляемое переключение (switchover), не вызвавшее ни одной клиентской ошибки!

После завершения switchover, мы снова можем проверить [pg\_dist\_node](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*129x1qu*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE4MDY4MS44LjAuMTY5MjE4MDY4MS4wLjAuMA..#worker-node-table):

    citus=# select nodeid, groupid, nodename, nodeport, noderole
    from pg_dist_node order by groupid;
    nodeid | groupid |  nodename  | nodeport | noderole
    -------+---------+------------+----------+----------
         1 |       0 | 172.19.0.7 |     5432 | primary
         3 |       1 | 172.19.0.2 |     5432 | primary
         2 |       2 | 172.19.0.9 |     5432 | primary
    (3 rows)

Как видите, `nodename` для primary в группе 2 было автоматически изменено Patroni с `172.19.0.4` на `172.19.0.9`.

### Планы на будущее и возможные улучшения

Эта статья была бы не полной, если бы мы не рассказали о том, какие дальнейшие работы по интеграции Patroni и Citus возможны. И вариантов действительно много:

1.  **Масштабирование чтения**: Мы можем зарегистрировать резервные (standby) воркеры в [pg\_dist\_node](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*1s2t8wy*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE4MDY4MS44LjAuMTY5MjE4MDY4MS4wLjAuMA..#worker-node-table), чтобы их можно было использовать для масштабирования запросов только на чтение.
    
2.  **Пул соединений**: При обмене данными между узлами Citus имеет возможность использовать механизм пула соединений. Для этого таблица метаданных [pg\_dist\_poolinfo](https://docs.citusdata.com/en/latest/develop/api_metadata.html?_gl=1*1s2t8wy*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE4MDY4MS44LjAuMTY5MjE4MDY4MS4wLjAuMA..#connection-pooling-credentials) должна автоматически заполняться и поддерживаться в актуальном состоянии на случай failover/switchover.
    
3.  **Несколько баз данных**: В настоящее время Patroni поддерживает только кластеры с одной базой данных, включающей Citus. Расширение Citus позволяет превратить стандартную базу данных PostgreSQL в распределенную систему, способную работать с данными на нескольких узлах и параллельно выполнять на них запросы. В таком сценарии каждая распределенная база данных Citus будет считаться отдельным кластером, а Patroni поддерживает только один кластер PostgreSQL с одной Citus-расширенной базой данных. Однако есть пользователи, у которых их несколько.
    

### Вместе Patroni и Citus предоставляют пользователям распределенных систем PostgreSQL хорошее решение для обеспечения высокой доступности

Patroni открывает путь к автоматизированному, полностью декларативному развертыванию кластеров распределенных баз данных Citus с открытым исходным кодом Postgres и высокой доступностью (HA) - на любой возможной платформе. В наших примерах мы использовали docker и docker-compose, но реальный продакшн-деплой не требует использования контейнеров. 

Несмотря на то, что Patroni 3.0 поддерживает Citus начиная с версии 10.0, мы рекомендуем использовать последние версии [Citus](https://www.citusdata.com/download) и [PostgreSQL 15](https://www.postgresql.org/), чтобы полностью воспользоваться преимуществами прозрачных переключений (switchovers) и/или перезапусков воркеров. На [странице обновлений Citus 11.2](https://www.citusdata.com/updates/v11-2/#patroni_support), также известной как страница примечаний к выпуску, можно увидеть следующее:

> Основное улучшение \[для обеспечения высокой доступности в Citus 11.2\] заключается в том, что мы теперь прозрачно переподключаемся, когда обнаруживаем, что кэшированное соединение с воркером было разорвано, пока мы его не использовали.

Для начала работы с Citus и Patroni имеется замечательная документация:

* [Документация по Citus](https://docs.citusdata.com/en?_gl=1*11bbec4*_ga*NzI0Mjc3NjIxLjE2OTAyNTc3MTM.*_ga_DS5S1RKEB7*MTY5MjE4MDY4MS44LjAuMTY5MjE4MDY4MS4wLjAuMA..)
    
* [Документация Patroni](https://patroni.readthedocs.io/)
    
