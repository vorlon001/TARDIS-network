Kafka acl или разграничение доступа RuleBAC
-------------------------------------------
Исходное положение
------------------

Итак мы попали в ситуацию когда нам очень хочется разграничить доступ к ресурсам кафки и на ум приходит RBAC (role-based access control - ролевое управление доступом). 

Для начала обратимся к источнику ([https://docs.confluent.io/platform/current/security/rbac/rbac-predefined-roles.html#role-based-access-control-predefined-roles](https://docs.confluent.io/platform/current/security/rbac/rbac-predefined-roles.html#role-based-access-control-predefined-roles)) 

Варианты использования которые представлены в документации сразу спускают нас с неба на землю и упрощают восприятие обилия ролей. Постараюсь еще немного их упростить. 

Таблица 1.

| **Предопределенная роль** | **Планируемое распеределение ролей** | **Реальность (и чтец и жнец и на дуде игрец)** |
|----|----|----|
|super.user|Сэмэну предоставляется полный доступ ко всем ресурсам и операциям проекта. Он создаст первоначальный набор ролей для проекта.|Сэмэн как безопасник, а по совместительству SRE и #добавитьсвое, не ходит к РП Роману, РП Сереге, РП Диме и РП ..., а самостоятельно определяет кто и как будет ходить по ресурсам. |
|ResourceOwner|Роману будут принадлежать все темы с префиксом finance\_. |Он может предоставить другим разрешение на доступ и использование этого ресурса. В этом случае использования он является ResourceOwner для финансовых разделов.|
|UserAdmin|Юрий будет управлять пользователями и группами проекта.||
|ClusterAdmin|Слава - член центральной команды кластера Kafka.||
|Operator|Оленька будет отвечать за операционное управление и управление работоспособностью платформы и приложений.|Дава и Оленька хорошо представляют как работает их богоспасаемый приклад, но давать им рычаги от всего кластера Сэмэн отказывается, по иделогическим соображениям, тем более что таких Дав и Ольг на этом кластере кафка косой десяток.|
|DeveloperRead, DeveloperWrite, DeveloperManage|Дава будет отвечать за разработку и управление приложением.|Дава и Оленька хорошо представляют как работает их богоспасаемый приклад, но давать им рычаги от всего кластера Сэмэн отказывается, по иделогическим соображениям, тем более что таких Дав и Ольг на этом кластере кафка косой десяток.|

Итак, имеем

·         совмещение ролей представленное в третьем столбце таблицы 1.

·         кластер кафка-зукипер, обмазанный вкруг sslем.  

·         возможность выпускать кастомного вида сертификаты X509 ([https://en.wikipedia.org/wiki/X.509#Certificates](https://en.wikipedia.org/wiki/X.509#Certificates)).

·         априори мы не владеем информацией о топиках и инженерах-разработчиках, которые придут к нам за ресурсами, но в целом доверяем им (инженерам-разработчикам) и хотим облегчить их и свой труд.

·         непреодолимое желание автоматизировать рутину и изолировать инженеров и разработчиков Даву и Оленьку от ресурсов Коли и Толи, Даши, Маши и прочих.

Этап первый - боремся с регулярками. 
-------------------------------------

Попытаемся реализовать RBAC и устранить зуд с использованием механизмов ACL, предоставляемых кафкой.

Подсмотрим документацию:

_Когда клиент подключается к брокеру Kafka с использованием протокола безопасности SSL, основное имя будет иметь форму имени субъекта сертификата SSL:CN=_[_quickstart.confluent.io_](http://quickstart.confluent.io/)_,OU=TEST,O=Sales,L=PaloAlto,ST=Ca,C=US._

_Обратите внимание, что после запятой нет пробелов._

Здесь стоит отметить, что **кафке надо скармливать субъект сертификата именно в приведенной последовательности. То есть CN=xxx,OU=yyy,O=zzz не равно O=zzz,OU=yyy,CN=xxx.**

Вот оно кажется нам! Сейчас отрегулярим CN  при использовании команды kafka-acls и пойдем питьконечно не чай. Но, при попытке засунуть в shell что-то вида 
```
    kafka-acls --bootstrap-server localhost:9092 --command-config adminclient-configs.conf \
    --add --allow-principal User:CN=priklad*fromDAVA.confluent.io,OU=TEST,O=Sales,L=PaloAlto,ST=Ca,C=US\
    --allow-host host-2 --operation read --operation write --topic finance_topic_from_Dava --topic finance_topic_from_Olga
```
нас настигнет разочарование, ибо AclAuthorizer не понимает такую подстановочную конструкцию priklad\*fromDAVA.confluent.io и отсыплет нам ошибок в лог.

Также не получится зарегулярить даже какой-нибудь участок сертификата вроде OU - результат будет таким же.
```
    kafka-acls --bootstrap-server   localhost:9092 --command-config   adminclient-configs.conf \
    --add --allow-principal   User:CN=prikladfromDAVA.confluent.io,OU=*,O=Sales,L=PaloAlto,ST=Ca,C=US\
    --allow-host host-2 --operation read --operation write   --topic finance_topic_from_Dava --topic finance_topic_from_Olga
```
Читаем дальше документацию и на той же странице находим замечательные примеры ssl.principal.mapping.rules значений:
```
    RULE:^CN=(.*?),OU=ServiceUsers.*$/$1/,
    RULE:^CN=(.*?),OU=(.*?),O=(.*?),L=(.*?),ST=(.*?),C=(.*?)$/$1@$2/L,
    RULE:^.*[Cc][Nn]=([a-zA-Z0-9.]*).*$/$1/L,
    DEFAULT
```
Ммм, регулярочка... точка опоры найдена. Как работает регулярное выражение ([https://docs.confluent.io/platform/current/kafka/configure-mds/mutual-tls-auth-rbac.html#how-the-regex-works](https://docs.confluent.io/platform/current/kafka/configure-mds/mutual-tls-auth-rbac.html#how-the-regex-works))? По умолчанию имя пользователя SSL находится в форме CN=writeuser,OU=Unknown,O=Unknown,L=Unknown,ST=Unknown,C=Unknown. Эта конфигурация позволяет использовать список правил для сопоставления отличительного имени X.500 (DN) с коротким именем. 

Теперь важное примечание: **Правила оцениваются по порядку, и первое правило, соответствующее DN, используется для сопоставления его с коротким именем. Все последующие правила в списке игнорируются.** 

Итак,  сделаем собственного несколько урезанного суперпользователя, на всякий случай, который случается с завидной регулярностью, со следующими acl:
```
    Current ACLs for resource   ResourcePattern(resourceType=TOPIC, name=*, patternType=LITERAL):
    (principal=User:this_kafka_superuser,   host=*, operation=WRITE, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=READ, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=DELETE, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=CREATE, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=DESCRIBE, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=ALTER, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=DESCRIBE_CONFIGS, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=ALTER_CONFIGS, permissionType=ALLOW)
    
    Current ACLs for resource   ResourcePattern(resourceType=CLUSTER, name=kafka-cluster,   patternType=LITERAL):
    (principal=User:this_kafka_superuser,   host=*, operation=CLUSTER_ACTION, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=CREATE, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=DESCRIBE, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=ALTER, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=DESCRIBE_CONFIGS, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=ALTER_CONFIGS, permissionType=ALLOW)
    
    Current ACLs for resource   ResourcePattern(resourceType=GROUP, name=*, patternType=LITERAL):
    (principal=User:this_kafka_superuser,   host=*, operation=READ, permissionType=ALLOW)
    (principal=User:this_kafka_superuser,   host=*, operation=DESCRIBE, permissionType=ALLOW)
```
В config/server.properties добавим:
```
ssl.principal.mapping.rules=RULE:^CN=kafka-name\[-3\].\*.my.domain.zone.\*$/this\_kafka\_superuser/,DEFAULT
```
По сути так мы создадим принципала для внутреннего обращения в кластере.

**Внимание!** Создавая такие правила надо помнить о том, что они будут применены только после перезагрузки брокера.

Списки контроля доступа (далее - аклы)  у меня получилось задать только bash-сиблом (приводить его здесь не буду).

Этап второй - Разделяй топики и властвуй.
-----------------------------------------

Далее в попытках реализовать RBAC нам придется создать еще несколько правил, которые позволят только владельцам соответствующих топиков дышать в их сторону. Выглядеть это будет так.

![](https://habrastorage.org/getpro/habr/upload_files/f66/1cd/dc4/f661cddc479a360e64699daccaf4d6e1.png)

Создадим вот такие правила (извините за однообразие и отсутствие фантазии, можно было изменить наименование организации или оргюнита, да и вообще любую часть сертификата):
```
    ssl.principal.mapping.rules=
    RULE:^CN=kafka-name[-3].*.my.domain.zone.*$/this_kafka_superuser/,
    RULE:^CN=.*.kadri.domain.zone.*$/kadri/,
    RULE:^CN=.*.finiki.domain.zone.*$/finiki/,
    RULE:^CN=.*.axo.domain.zone.*$/axo/,
    RULE:^CN=.*.managers.domain.zone.*$/managers/,
    RULE:^CN=.*.reserv1.domain.zone.*$/reserv1/,
    RULE:^CN=.*.reserv2.domain.zone.*$/reserv2/,
    RULE:^CN=.*.my.domain.zone.*$/only_describe_user/,
    DEFAULT
```
Теперь осталось накинуть этим ролям-пользователям соответствующие права на топики и другие ресурсы.  Здесь опять нам помогут регулярные выражения, а вернее префиксы названий ресурсов.   
[Документация](https://docs.confluent.io/platform/current/kafka/authorization.html#prefixed-acls) так и говорит нам: Вы можете указать ресурсы ACL, используя либо значение LITERAL (по умолчанию), тип шаблона PREFIXED, либо подстановочный знак ( \*), который разрешает все. И также приводит замечательные примеры, которые успешно используются для наших целей.
```
    # /opt/Apache/kafka/bin/kafka-acls.sh   --bootstrap-server=$HOSTNAME:9093 --command-config   /opt/Apache/kafka/config/server.properties --add --allow-principal "User:kadri" --topic kadri-   --resource-pattern-type=PREFIXED --producer
    # /opt/Apache/kafka/bin/kafka-acls.sh   --bootstrap-server=$HOSTNAME:9093 --command-config   /opt/Apache/kafka/config/server.properties --add --allow-principal "User:kadri" --topic kadri-   --resource-pattern-type=PREFIXED --operation Read 
    
    Current ACLs for resource   ResourcePattern(resourceType=TOPIC, name=kadri-, patternType=PREFIXED): 
        (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
        (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
        (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
        (principal=User:kadri, host=*, operation=DESCRIBE,   permissionType=ALLOW)
```
То есть команда в общем виде имеет вид для этих целей имеет вид:
```
    # bin/kafka-acls.sh   --bootstrap-server=$HOSTNAME:9093 --command-config   config/server.properties \
    --add --allow-principal "User:{{ username }}" --topic {{ prefix_for_username }} \
    --resource-pattern-type=PREFIXED \
    --operation WRITE --operation READ  --operation CREATE --operation DESCRIBE
```
Еще раз напомню о том как правильно и неправильно создавать aclы:


|**неправильно**|**правильно**|
|name=kadri-vip, patternType=PREFIXED|name=kadri-, patternType=PREFIXED|
|name=kadri-common, patternType=PREFIXED|name=kadri-common, patternType=LITERAL|
|name=kadri-top, patternType=PREFIXED||
|name=kadri-, patternType=LITERAL||
|name=kadri-, patternType=LITERAL||

Этап третий - просто автоматизируй это.
---------------------------------------

Запилим для этих целей роль - чтобы можно было выписывать аклы без хождения по мукам на хост.

Основные таски:
```
    - name: Make operations string
      set_fact:
        operations_composite: "{{ operations_composite }}   --operation={{ item }}"
      loop: "{{ input.operations }}"
    - name: Make hosts string
      set_fact:
        hosts_composite: "{{ hosts_composite }}   --allow-host={{ item }}"
      loop: "{{ input.host.split(',')   }}"
      when: input.host is defined
    - name: Topic permissions
      shell: |
        {{ kafka_install_dir }}/bin/kafka-acls.sh --bootstrap-server={{   ansible_host }}:{{ broker_port_ssl }} --command-config={{ kafka_install_dir   }}/config/server.properties --add --allow-principal "User:{{ input.username }}" {{ operations_composite }} {{ hosts_composite   }} --topic={{ input.topic }}
      when: input.topic is defined
    - name: Cluster permissions
      shell: |
        {{ kafka_install_dir }}/bin/kafka-acls.sh --bootstrap-server={{   ansible_host }}:{{ broker_port_ssl }} --command-config={{ kafka_install_dir   }}/config/server.properties -add --allow-principal "User:{{ input.username }}" {{ operations_composite }} {{   hosts_composite }} --cluster={{ input.cluster }}
      when: input.cluster is defined
    - name: Group permissions
      shell: |
        {{ kafka_install_dir }}/bin/kafka-acls.sh --bootstrap-server={{   ansible_host }}:{{ broker_port_ssl }} --command-config={{ kafka_install_dir   }}/config/server.properties -add --allow-principal "User:{{ input.username }}" {{ operations_composite }} {{   hosts_composite }} --group={{ input.group }}
      when: input.group is defined
```
В переменные надо передавать красивые списки вида:
```
    acls:
     - username: managers
        cluster: '*'
        host: '*'
        operations:
         - IdempotentWrite
     - username: axo
        topic: 'axo_topic1'
        operations:
         - Describe
         - Alter
         - DescribeConfigs
         - AlterConfigs
         - Create
         - Read
         - Write
```
Сложно ли это повторить человеку с техническим бэкграундом - не думаю.

Ура! Мы сможем задавать произвольные права для произвольных пользователей .

Чтобы причинить еще больше пользы - стоит сделать проверку и запрет использования wildcart символов при использовании имен ресурсов.  
```
    - name: Assert wildcart characters in   topic
      assert:
        that:
         - ' "*"   not in input.topic'
        fail_msg: "You are using wildcart   characters in topicname. You must use resource_pattern_type: PREFIXED and   uniq prefix for topic name"
        success_msg: "Topic name is OK"
      when: wildcart_topic_assertion and   input.topic is defined
```
Этап четвертый - правильно удалять aclы.
----------------------------------------

Первый блин комом, а поэтому за собой придется прибраться и удалить неудачно созданные аклы.

### 1 способ - аккуратно и инкрементально.

То есть, либо используя --resource-pattern-type PREFIXED, либо опуская его и использую по умолчанию LITERAL.
```
    /opt/Apache/kafka/bin/kafka-acls.sh --bootstrap-server=$HOSTNAME:9093 \
    --command-config=/opt/Apache/kafka/config/server.properties   --remove\
    --allow-principal "User:CN=*******" --topic name_of_topic --resource-pattern-type PREFIXED \
    --operation WRITE   --operation READ --operation Alter --operation DescribeConfigs \
    --operation   Describe --operation Create --operation Read --operation Delete
```
### 2 способ - грохать все и сразу. как мы любим))

Тут требуется пояснение хелпа по resource-pattern-type. Используя resource-pattern-type=ANY будут удалены аклы на ресурсы, созданные с resource-pattern-type=LITERAL и PREFIXED.  А использование resource-pattern-type=MATCH ДОПОЛНИТЕЛЬНО к ANY удалит еще и аклы, влияющие на упомянутые ресурсы. Пример.

Создадим 3 списка на аклов: 
```
    /opt/Apache/kafka/bin/kafka-acls.sh   --bootstrap-server=$HOSTNAME:9093 --command-config   /opt/Apache/kafka/config/server.properties --add --allow-principal "User:kadri" --topic "kadri-" --resource-pattern-type PREFIXED --operation Create   --operation Describe --operation Write --operation Read --operation Alter
    /opt/Apache/kafka/bin/kafka-acls.sh   --bootstrap-server=$HOSTNAME:9093 --command-config   /opt/Apache/kafka/config/server.properties --add --allow-principal "User:kadri" --topic "kadri-common" --topic "kadri-vip" --operation Create --operation   Describe --operation Write --operation Read
    
    # тут у нас аклы на топики   начинающиеся на kadri-
    Current ACLs for resource   `ResourcePattern(resourceType=TOPIC, name=kadri-, patternType=PREFIXED)`:
              (principal=User:kadri, host=*, operation=ALTER, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=DESCRIBE, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
    
    # здесь аклы на конкретные топики
    Current ACLs for resource   `ResourcePattern(resourceType=TOPIC, name=kadri-vip, patternType=LITERAL)`:
              (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
              (principal=User:kadri,   host=*, operation=DESCRIBE, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
    Current ACLs for resource   `ResourcePattern(resourceType=TOPIC, name=kadri-common,   patternType=LITERAL)`:
              (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
              (principal=User:kadri, host=*, operation=DESCRIBE, permissionType=ALLOW)     
```
Как видим первый список перекрывает второй и третий, то есть разрешает те же действия, только над более мощным множеством топиков.

**Удаляем с использованием ANY**
```
    /opt/Apache/kafka/bin/kafka-acls.sh --bootstrap-server=$HOSTNAME:9093   --command-config   /opt/Apache/kafka/config/server.properties --remove --allow-principal "User:kadri" --topic "kadri-common" --topic "kadri-vip" --operation Create --operation   Describe --operation Write --operation Read --resource-pattern-type Any
    # Видим 2 последовательных предупреждения
    Are you sure you want to remove ACLs:
          (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=DESCRIBE,   permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
     from resource filter   `ResourcePattern(resourceType=TOPIC, name=kadri-common, patternType=ANY)`?   (y/n)
    y
    Are you sure you want to remove ACLs:
          (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=DESCRIBE,   permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
     from resource filter   `ResourcePattern(resourceType=TOPIC, name=kadri-vip, patternType=ANY)`? (y/n)
    y
```
При просмотре всех аклов получим:
```
    Current ACLs for resource   `ResourcePattern(resourceType=TOPIC, name=kadri-, patternType=PREFIXED)`:
          (principal=User:kadri, host=*, operation=ALTER, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=DESCRIBE,   permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
```
**Теперь удалим аклы с использованием MATCH:**

     /opt/Apache/kafka/bin/kafka-acls.sh   --bootstrap-server=$HOSTNAME:9093 --command-config   /opt/Apache/kafka/config/server.properties --remove --allow-principal "User:kadri" --topic "kadri-common" --topic "kadri-vip" --operation Create --operation   Describe --operation Write --operation Read --resource-pattern-type Match
    Are you sure you want to remove ACLs:
          (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=DESCRIBE,   permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
     from resource filter   `ResourcePattern(resourceType=TOPIC, name=kadri-common, patternType=MATCH)`?   (y/n)
    y
    Are you sure you want to remove ACLs:
          (principal=User:kadri, host=*, operation=WRITE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=DESCRIBE,   permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=CREATE, permissionType=ALLOW)
          (principal=User:kadri, host=*, operation=READ, permissionType=ALLOW)
     from resource filter   `ResourcePattern(resourceType=TOPIC, name=kadri-vip, patternType=MATCH)`?   (y/n)
    y
    #Такие же 2 предупреждения и в оконцовке подозрительный вывод
    Current ACLs for resource   `ResourcePattern(resourceType=TOPIC, name=kadri-, patternType=PREFIXED)`:
          (principal=User:kadri, host=*, operation=ALTER, permissionType=ALLOW)

Первое что не настораживает - те же самые предупреждения. Второе что настораживает вывод выполненной команды с упоминанием топиков начинающихся на префикс kadri-. Просмотр всех аклов показывает что умная, но не очень разговорчивая утилита _нашла и без предупреждения грохнула аклы, которыми мы обеспечивали доступ ко всем топикам начинающимся на kadri-_. Теперь становится понятным почему в справке к утилите kafka-acls.sh стоит _warning_ - можно ненароком запретить то, что не хотелось запрещать.

Выводы
------

1.  Регулярить с аклами можно в двух случаях:  
    \- в полный рост при создании правил маппинга  
    \- префиксами при именовании ресурсов
    
2.  Внимательно относиться к содержимому сертификата
    
3.  С особым вниманием использовать resource-pattern-type=MATCH, ибо можно потереть нужные списки
    
4.  Как итог role-based access control у нас не получился, ведь роли всего 2, зато получился RULE-based access control.
    
