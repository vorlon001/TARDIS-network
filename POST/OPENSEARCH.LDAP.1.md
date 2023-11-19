https://habr.com/ru/articles/664874/


Настройка в OpenSearch аутентификации и авторизации пользователей через Active Directory по протоколу LDAP
==========================================================================================================

  
В этой статье я расскажу о том, как я настраивал аутентификацию и авторизацию доменных пользователей Active Directory в OpenSearch. В домене я не обладаю правами администратора домена и не могу влиять на структуру каталогов Active Directory. А сценарий настройки Active Directory в OpenSearch, предлагаемый на официальном сайте, применить к домену с разветвленной структурой каталогов оказалось не так просто, как хотелось бы.  
  

 

1\. Предисловие
---------------

  
Эта статья является продолжением статьи [«Установка, настройка и эксплуатация стэка OpenSearch в классической среде»](https://habr.com/ru/post/662527/). Однако, тема этой статьи достаточно узкая и практически не зависит от основной настройки всего стека OpenSearch (материала первой статьи). Поэтому эту статью можно считать самостоятельной.  
  

2\. Введение
------------

  
Сразу отмечу, что в качестве Веб-интерфейса я использую OpenSearch-Dashboards. И в основном именно для OpenSearch-Dashboards мне нужна доменная авторизация.  

Для того, чтобы настроить аутентификацию и авторизацию доменных пользователей Active Directory в OpenSearch по протоколу LDAP необходимо сконфигурировать файл «<основной\_каталог\_opensearch>/plugins/opensearch-security/securityconfig/config.yml» (в моем случае полный путь к этому файлу такой «/opt/opensearch/plugins/opensearch-security/securityconfig/config.yml»).  

В файле конфигурации за аутентификацию и авторизацию отвечают два разных блока: «config.authc.ldap» и «config.authz.roles\_from\_myldap» соответственно. Так как я подключаю OpenSearch к одному единственному домену AD для авторизации и аутентификации пользователей, то частично конфигурация обоих блоков у меня будет совпадать. Если точнее, то вот эти блоки у меня будут совпадать: «config.authc.ldap.authentication\_backend.config.users» и «config.authz.roles\_from\_myldap.authorization\_backend.config.users».  
  

3\. Постановка задачи
---------------------

  
В домене Active Directory имеется три доменные группы: «Department05-Developers», «Department05-Admins», «Department05-Analysts». Необходимо, чтобы все пользователи домена, состоящие хотя бы в одной из этих трех доменных групп, могли войти в OpenSearch-Dashboards под своей доменной учетной записью и получили определенные роли в OpenSearch.  

Для примера будем считать, что в каждой из этих доменных групп будет только по одному пользователю. В группе «Department05-Developers» состоит пользователь: «Пушкин Александр Сергеевич (PushkinAS)». В группе «Department05-Admins» состоит пользователь: «Горький Максим (GorkiiM)». В группе «Department05-Analysts» состоит пользователь: «Толстой Лев Николаевич (TolstoiLN)».  

Договоримся, что FQDN контроллера домена AD будет таким: «server-ad.my.big.domain».  

Договоримся, что учетная запись домена AD, предназначенная для просмотра LDAP будет такая: «user\_for\_LDAP». А пароль у неё будет такой: «Au5dUJ9q!54S». Отмечу, что нет необходимости давать этой учетной записи администраторские права.  

Договоримся о том, что все три пользователя («PushkinAS», «GorkiiM», «TolstoiLN») находятся в разных населенных пунктах, а структура каталогов в AD учитывает населенный пункт при создании учетной записи, то есть учетные записи будут находиться по разным адресам в AD.  
  

4\. Коротко об объектах настройки конфиденциальности в OpenSearch
-----------------------------------------------------------------

В OpenSearch, как и во многих других системах, для распределения привилегий в системе используются учетные записи.  

Каждая учетная запись может иметь набор прав доступов, которые наделяют пользователя полномочиями.  

Определенный набор прав доступов объединяется в роль. Пользователь может иметь как одну, так и несколько ролей. В случае, когда пользователю назначены несколько ролей, права доступов которых противоречат друг другу, преимущество имеют права, дающие пользователю больший доступ.  

Например, если дать права администратора и наблюдателя одновременно, то фактически пользователь будет иметь права администратора.  

А вот «Backend» роль сущность несколько абстрактная. «Обычная» роль может иметь «Backend» роль или даже несколько «Backend» ролей. Пользователь тоже может иметь «Backend» роль или даже несколько «Backend» ролей. Если «Backend» роль есть у пользователя, и эта же «Backend» роль есть у «обычной» роли, то такой пользователь становится обладателем этой «обычной» роли.  

«Backend» роли становятся актуальными для использования при доменной авторизации. Потому как доменные пользователи не доступны для настройки прав или «обычных» ролей, они могут получить только «Backend» роль автоматически, в зависимости от настроенной конфигурации.  
  

5\. Настройка LDAP
------------------
  
Для наглядности я сразу приведу уже сконфигурированный файл «config.yml» целиком (в моем случае это файл «/opt/opensearch/plugins/opensearch-security/securityconfig/config.yml»).  

**/opt/opensearch/plugins/opensearch-security/securityconfig/config.yml**
```
    ---
    # This is the main OpenSearch Security configuration file where authentication
    # and authorization is defined.
    
    _meta:
      type: "config"
      config_version: 2
    
    config:
      dynamic:
        # Set filtered_alias_mode to 'disallow' to forbid more than 2 filtered aliases per index
        # Set filtered_alias_mode to 'warn' to allow more than 2 filtered aliases per index but warns about it (default)
        # Set filtered_alias_mode to 'nowarn' to allow more than 2 filtered aliases per index silently
        #filtered_alias_mode: warn
        #do_not_fail_on_forbidden: false
        #kibana:
        # Kibana multitenancy
        #multitenancy_enabled: true
        #server_username: kibanaserver
        #index: '.kibana'
        http:
          anonymous_auth_enabled: false
          xff:
            enabled: false
            internalProxies: '192\.168\.0\.10|192\.168\.0\.11' # regex pattern
            #internalProxies: '.*' # trust all internal proxies, regex pattern
            #remoteIpHeader:  'x-forwarded-for'
            ###### see https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html for regex help
            ###### more information about XFF https://en.wikipedia.org/wiki/X-Forwarded-For
            ###### and here https://tools.ietf.org/html/rfc7239
            ###### and https://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Remote_IP_Valve
        authc:
          kerberos_auth_domain:
            http_enabled: false
            transport_enabled: false
            order: 6
            http_authenticator:
              type: kerberos
              challenge: true
              config:
                # If true a lot of kerberos/security related debugging output will be logged to standard out
                krb_debug: false
                # If true then the realm will be stripped from the user name
                strip_realm_from_principal: true
            authentication_backend:
              type: noop
          basic_internal_auth_domain:
            description: "Authenticate via HTTP Basic against internal users database"
            http_enabled: true
            transport_enabled: true
            order: 4
            http_authenticator:
              type: basic
              challenge: true
            authentication_backend:
              type: intern
          proxy_auth_domain:
            description: "Authenticate via proxy"
            http_enabled: false
            transport_enabled: false
            order: 3
            http_authenticator:
              type: proxy
              challenge: false
              config:
                user_header: "x-proxy-user"
                roles_header: "x-proxy-roles"
            authentication_backend:
              type: noop
          jwt_auth_domain:
            description: "Authenticate via Json Web Token"
            http_enabled: false
            transport_enabled: false
            order: 0
            http_authenticator:
              type: jwt
              challenge: false
              config:
                signing_key: "base64 encoded HMAC key or public RSA/ECDSA pem key"
                jwt_header: "Authorization"
                jwt_url_parameter: null
                roles_key: null
                subject_key: null
            authentication_backend:
              type: noop
          clientcert_auth_domain:
            description: "Authenticate via SSL client certificates"
            http_enabled: false
            transport_enabled: false
            order: 2
            http_authenticator:
              type: clientcert
              config:
                username_attribute: cn #optional, if omitted DN becomes username
              challenge: false
            authentication_backend:
              type: noop
          ldap:
            description: "Authenticate via LDAP or Active Directory"
            http_enabled: true
            transport_enabled: false
            order: 5
            http_authenticator:
              type: basic
              challenge: false
            authentication_backend:
              # LDAP authentication backend (authenticate users against a LDAP or Active Directory)
              type: ldap
              config:
                # enable ldaps
                enable_ssl: false
                # enable start tls, enable_ssl should be false
                enable_start_tls: false
                # send client certificate
                enable_ssl_client_auth: false
                # verify ldap hostname
                verify_hostnames: true
                hosts:
                - server-ad.my.big.domain:389
                bind_dn: 'cn=user_for_LDAP,ou=Service Accounts,ou=Moscow,dc=MY,dc=BIG,dc=DOMAIN'
                password: 'Au5dUJ9q!54S'
                users:
                  1-userbase:
                    base: 'CN=Пушкин Александр Сергеевич (PushkinAS),OU=Users,OU=Saint_Petersburg,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(sAMAccountName={0})'
                  2-userbase:
                    base: 'CN=Горький Максим (GorkiiM),OU=Users,OU=Nizhny_Novgorod,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(sAMAccountName={0})'
                  3-userbase:
                    base: 'CN=Толстой Лев Николаевич (TolstoiLN),OU=Users,OU=Yasnaya_Polyana,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(sAMAccountName={0})'
                username_attribute: 'cn'
        authz:
          roles_from_myldap:
            description: "Authorize via LDAP or Active Directory"
            http_enabled: true
            transport_enabled: false
            authorization_backend:
              # LDAP authorization backend (gather roles from a LDAP or Active Directory, you have to configure the above LDAP authentication backend settings too)
              type: ldap
              config:
                # enable ldaps
                enable_ssl: false
                # enable start tls, enable_ssl should be false
                enable_start_tls: false
                # send client certificate
                enable_ssl_client_auth: false
                # verify ldap hostname
                verify_hostnames: true
                hosts:
                  - server-ad.my.big.domain:389
                bind_dn: 'cn=user_for_LDAP,ou=Service Accounts,ou=Moscow,dc=MY,dc=BIG,dc=DOMAIN'
                password: 'Au5dUJ9q!54S'
                users:
                  1-userbase:
                    base: 'CN=Пушкин Александр Сергеевич (PushkinAS),OU=Users,OU=Saint_Petersburg,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(sAMAccountName={0})'
                  2-userbase:
                    base: 'CN=Горький Максим (GorkiiM),OU=Users,OU=Nizhny_Novgorod,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(sAMAccountName={0})'
                  3-userbase:
                    base: 'CN=Толстой Лев Николаевич (TolstoiLN),OU=Users,OU=Yasnaya_Polyana,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(sAMAccountName={0})'
                username_attribute: 'cn'
                roles:
                  1-rolebase:
                    base: 'CN=Department05-Developers,OU=Groups,OU=Moscow,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(member={0})'
                  2-rolebase:
                    base: 'CN=Department05-Admins,OU=Groups,OU=Moscow,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(member={0})'
                  3-rolebase:
                    base: 'CN=Department05-Analysts,OU=Groups,OU=Moscow,DC=MY,DC=BIG,DC=DOMAIN'
                    search: '(member={0})'
                userroleattribute: null
                userrolename: memberOf, SamAccountName
                rolename: "cn"
                resolve_nested_roles: false
          roles_from_another_ldap:
            description: "Authorize via another Active Directory"
            http_enabled: false
            transport_enabled: false
            authorization_backend:
              type: ldap
```    

  
Описание всех параметров вы можете посмотреть на официальном сайте OpenSearch ([https://opensearch.org/docs/latest/security-plugin/configuration/ldap/](https://opensearch.org/docs/latest/security-plugin/configuration/ldap/)). Я опишу только некоторые параметры и моменты, которые вызвали у меня затруднения.  
  
В параметре «config.authc.ldap.authentication\_backend.config.users» (и в параметре «config.authz.roles\_from\_myldap.authorization\_backend.config.users») содержится путь в LDAP по которому производится поиск учетных записей, которые смогут аутентифицироваться (и авторизоваться). Можно указать каталог, в котором содержатся учетные записи, и все учетные записи из этого каталога смогут аутентифицироваться (и авторизоваться), но при этом не получится отфильтровать учетные записи, которые не должны иметь возможность аутентификации (и авторизации). Так же вместо каталога можно указать саму учетную запись, которой нужно дать возможность аутентифицироваться (и авторизоваться). Таких каталогов или учетных записей можно указать любое количество.  

В нашем случае, например, учетная запись «PushkinAS» расположена по адресу «OU=Users,OU=Saint\_Petersburg,DC=MY,DC=BIG,DC=DOMAIN». Но в этом же каталоге есть и другие учетные записи, для которых аутентификация (и авторизоваться) должна быть запрещена.  

Одним из вариантов решения этой проблемы, я думаю, будет создание проксирующего LDAP сервера. Однако в моем случае пользователей не очень много и меняются они редко, и я пошел другим путем.  

Простым решением для разграничения прав по аутентификации (и авторизации) будет создание списка из путей в LDAP к каждому пользователю, которым позволено аутентифицироваться (и авторизоваться) на сервере.  

```
    …
    1-userbase:
      base: 'CN=Пушкин Александр Сергеевич (PushkinAS),OU=Users,OU=Saint_Petersburg,DC=MY,DC=BIG,DC=DOMAIN'
      search: '(sAMAccountName={0})'
    2-userbase:
      base: 'CN=Горький Максим (GorkiiM),OU=Users,OU=Nizhny_Novgorod,DC=MY,DC=BIG,DC=DOMAIN'
      search: '(sAMAccountName={0})'
    3-userbase:
      base: 'CN=Толстой Лев Николаевич (TolstoiLN),OU=Users,OU=Yasnaya_Polyana,DC=MY,DC=BIG,DC=DOMAIN'
      search: '(sAMAccountName={0})'
    …
``` 


Так как нужно получить список пользователей AD, состоящих хотя бы в одной из трех доменных групп, получить к каждому из этих пользователей путь в LDAP (AD) и внести эти данные в конфигурацию в параметр «config.authc.ldap.authentication\_backend.config.users» и в параметр «config.authz.roles\_from\_myldap.authorization\_backend.config.users» я составил PowerShell скрипт, который всё это сделает и сгенерирует фрагмент конфигурации для этих параметров.  
Думаю, знатоки PowerShell найдут что можно оптимизировать в этом скрипте, но главное, что он работает. Приведу текст скрипта:  

**Get\_fragment\_of\_config.ps1**
```
    $null=(chcp 1251)
    
    # Список доменных групп
    $List_of_groups =@(
    "Department05-Developers"
    "Department05-Admins"
    "Department05-Analysts"
    )
    
    $List_users_text=""
    
    # Собираем в единый текст список логинов
    Foreach ($groups_n in $List_of_groups) {
      $t=(net group $groups_n /domain)
      for ($i=8; $i -le $t.Count-3; $i++){
       $List_users_text+=$t[$i]
      }
    }
    
    # Удаляем двойные пробелы
    for ($i=1; $i -le 15; $i++){
        $List_users_text=$List_users_text -replace "\s\s", " "
    }
    
    # Разбиваем логины на элементы массива
    $List_users=@()
    $List_users+=$List_users_text.Split(" ")
    
    # Удаляем дубликаты логинов, если один и тот же логин есть в нескольких группах
    $List_users = $List_users | select -uniq
    
    # Сортируем логины по алфавиту
    $List_users = $List_users | sort-object
    
    # Удаляем первый элемент массива (пустая строка)
    $null, $List_users = $List_users
    
    # Получаем список логинов в формате пути LDAP, без префикса "LDAP://"
    $List_users_LDAP=@()
    Foreach ($user_n in $List_users) {
       $user_name="*("+$user_n+")*"
       $List_users_LDAP+=(([adsisearcher]“(&(objectcategory=person)(cn=$user_name))”).Findall()).Path -replace "LDAP://", ""
    }
    
    # Оставим только строки с содержанием (Удаляем пустые строки)
    $List_users_LDAP2=@()
    Foreach ($user_n in $List_users_LDAP) {
       if (($user_n[0] -eq "C") -and ($user_n[1] -eq "N")) {
          $List_users_LDAP2+=$user_n
       } 
    }
    $List_users_LDAP=$List_users_LDAP2
    
    # Формируем конфиг
    [int]$counter=1
    
    # переменная - отступ; пробелы перед каждой строкой, для YAML
    $before="            "
    
    # конечный текст будет в переменной $config
    $config=""
    $config+=$before+'users:'+[System.Environment]::NewLine
    
    Foreach ($user_n in $List_users_LDAP) {
      $config+=$before+"  "+$counter+"-userbase:"+[System.Environment]::NewLine
      $config+=$before+"    "+'base: '''+$user_n+''''+[System.Environment]::NewLine
      $config+=$before+"    "+'search: ''(sAMAccountName={0})'''+[System.Environment]::NewLine
    
      $counter++
    }
    
    # Выводим конфиг
    $config
    
```
  

  
Отмечу переменную «$user\_name». В моем случае, как я показывал в примерах, «CN» учетной записи имеет вид «Пушкин Александр Сергеевич (PushkinAS)», где «(PushkinAS)» является sAMAccountName (логином). Поэтому строка «$user\_name="\*("+$user\_n+")\*"» в моем случае позволит достоверно отфильтровать каждую учетную запись. Если в вашем домене Active Directory «CN» формируется иначе, то эту строку нужно будет скорректировать. В остальном, я надеюсь, скрипт получился универсальным.  
  
Параметр «config.authz.roles\_from\_myldap.authorization\_backend.config.roles» содержит путь в LDAP по которому происходит поиск объектов, которые станут «Backend» ролями, в нашем случае этими объектами будут доменные группы. Таких каталогов можно указать любое количество. Укажем в этом параметре группы: «Department05-Developers», «Department05-Admins», «Department05-Analysts». Позже настроим на эти группы роль «readall», которая позволит просматривать все индексы.  

```
    …
    1-rolebase:
      base: 'CN=Department05-Developers,OU=Groups,OU=Moscow,DC=MY,DC=BIG,DC=DOMAIN'
      search: '(member={0})'
    2-rolebase:
      base: 'CN=Department05-Admins,OU=Groups,OU=Moscow,DC=MY,DC=BIG,DC=DOMAIN'
      search: '(member={0})'
    3-rolebase:
      base: 'CN=Department05-Analysts,OU=Groups,OU=Moscow,DC=MY,DC=BIG,DC=DOMAIN'
      search: '(member={0})'
    …
    
```
  
  
Параметр «config.authz.roles\_from\_myldap.authorization\_backend.config.userrolename». Значение «memberOf» сделает доменные группы доменного пользователя его «Backend» ролями, а значение «SamAccountName» сделает параметр доменной учетной записи «SamAccountName» (логин) «Backend» ролью доменного пользователя. Это позволит выдавать права доменным пользователям и по его группам, и по его логину.  
```
    …
    userrolename: memberOf, SamAccountName
    …
    
```
  

6\. Получаем полный путь к объектам в AD
----------------------------------------

  
Полный путь к группе в AD через PowerShell можно получить так:  
```
    $group = ([adsisearcher]“(&(objectcategory=group)(cn=name_of_group))”).Findall()
    $group
    
```
  
Вместо «name\_of\_group» подставьте название нужной вам группы.  
Полный путь к пользователю в AD через PowerShell можно получить так:  
```
    $what_find="*("+"user_name"+")*"
    $user = ([adsisearcher]“(&(objectcategory=person)(cn=$what_find))”).Findall()
    $user
    
```
  
В переменную «$what\_find» подставьте логин нужного вам пользователя, в формате, который используется в вашем домене AD.  
  

7\. Применение настроек
-----------------------

  
Для применения настроек, сделанных в файле «/opt/opensearch/plugins/opensearch-security/securityconfig/config.yml» (а также всех других файлов конфигураций в «/opt/opensearch/plugins/opensearch-security/securityconfig/») нужно запустить скрипт «/opt/opensearch/plugins/opensearch-security/tools/securityadmin.sh» и заново сгенерировать сертификаты, сделать это можно так:  
```
    cd /opt/opensearch/plugins/opensearch-security/tools
    ./securityadmin.sh -cd ../securityconfig/ -icl -nhnv \
       -cacert ../../../config/root-ca.pem \
       -cert ../../../config/kirk.pem \
       -key ../../../config/kirk-key.pem
    

```
  

8\. Проблема применения настроек
--------------------------------

  
Выполнение команды для применения настроек удаляет все изменения, сделанные в OpenSearch-Dashboards в разделе «Security», то есть все настройки пользователей и ролей. И это является проблемой, так как в конфигурацию со временем будет необходимо добавлять новых пользователей и удалять старых пользователей.  

Видимо разработчики OpenSearch всё же подразумевают, что все пользователи в AD лежат в одном каталоге и «лишних» пользователей там нет. Либо всё-таки подразумевается использование проксирующего LDAP сервера. Другого объяснения я не нашел.  

Для того чтобы обойти эту проблему можно вносить изменения не в Web-интерфейсе (OpenSearch-Dashboards), а через файлы конфигураций.  

Далее опишу настройку конфигурационных файлов.  
  

9\. Добавляем внутренних пользователей
--------------------------------------

  
Добавим двух пользователей: «my\_admin» — с полным доступом ко всему (admin), «guest» — с правами на просмотр всех индексов.  

Для этого отредактируем файл «/opt/opensearch/plugins/opensearch-security/securityconfig/internal\_users.yml»:  

**/opt/opensearch/plugins/opensearch-security/securityconfig/internal\_users.yml**

```
    ...
    # Добавить в конце файла
    my_admin:
      hash: "$2y$12$RYNld1qqXMuCQr7HCU/HnOiOn20smdWUzD4vJan2cdbVrKPtQkVZG"
      reserved: false
      backend_roles:
      - "admin"
      description: "Admin"
      
    guest:
      hash: "$2y$12$n330lm1W/VOV.VYT0xCQm.N/8HDoAqNzV.oQwnRDjLRXV9PfXSWby"
      reserved: false
      backend_roles:
      - "readall"
      description: "Readall"
    
```
  

Хэши паролей можно получить так же как описано [здесь](https://habr.com/ru/post/662527/#section2-5).  

После редактирования конфигурации не забываем [применить настройки](#section7).  
  

10\. Добавляем роли для пользователей AD
----------------------------------------

Добавим две роли: роль «readall\_AD» с аналогичными правами как у роли «readall» — для просмотра всех индексов, роль «admin\_AD» с аналогичными правами как у роли «all\_access» (admin) — с полным доступом ко всему.  

Для этого отредактируем файл «/opt/opensearch/plugins/opensearch-security/securityconfig/roles.yml»:  

**/opt/opensearch/plugins/opensearch-security/securityconfig/roles.yml**
```
    ...
    # Добавить в конце файла
    # Allow AD users read all
    readall_AD:
      reserved: false
      cluster_permissions:
        - "cluster_composite_ops_ro"
      index_permissions:
        - index_patterns:
            - '*'
          allowed_actions:
            - 'read'
    		
    # Allow AD users read all
    admin_AD:
      reserved: false
      cluster_permissions:
        - '*'
      index_permissions:
        - index_patterns:
            - '*'
          allowed_actions:
            - '*'
      tenant_permissions:
        - tenant_patterns:
              - '*'
          allowed_actions:
            - 'kibana_all_read'
            - 'kibana_all_write'
    
```
  

  
После редактирования конфигурации не забываем [применить настройки](#section7).  
  

11\. Добавляем «Backend» роли для пользователей AD
--------------------------------------------------

  
Обладателям «Backend» ролей: «Department05-Developers», «Department05-Admins», «Department05-Analysts»; дадим роль «readall\_AD». Обладателям «Backend» ролей: «GorkiiM»; дадим роль «admin\_AD».  

Для этого отредактируем файл «/opt/opensearch/plugins/opensearch-security/securityconfig/roles\_mapping.yml»:  

**/opt/opensearch/plugins/opensearch-security/securityconfig/roles\_mapping.yml**
```
    ...
    # Добавить в конце файла
    readall_AD:
      reserved: false
      backend_roles:
      - "Department05-Developers"
      - "Department05-Admins"
      - "Department05-Analysts"
      
    admin_AD:
      reserved: false
      backend_roles:
      - "GorkiiM"
    
```
  
После редактирования конфигурации не забываем [применить настройки](#section7).  
  

12\. Послесловие
----------------

  
На этом всё. Всем спасибо за внимание к статье, надеюсь она окажется для кого-то полезной.

