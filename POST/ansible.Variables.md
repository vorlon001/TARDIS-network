Using Variables
===============

Ansible uses variables to manage differences between systems. With Ansible, you can execute tasks and playbooks on multiple different systems with a single command. To represent the variations among those different systems, you can create variables with standard YAML syntax, including lists and dictionaries. You can define these variables in your playbooks, in your [inventory](intro_inventory#intro-inventory), in re-usable [files](playbooks_reuse#playbooks-reuse) or [roles](playbooks_reuse_roles#playbooks-reuse-roles), or at the command line. You can also create variables during a playbook run by registering the return value or values of a task as a new variable.

После того, как вы создадите переменные, либо определив их в файле, передав их в командной строке, либо зарегистрировав возвращаемое значение или значения задачи в качестве новой переменной, вы можете использовать эти переменные в аргументах модуля, в [условных операторах «когда».](playbooks_conditionals#playbooks-conditionals) , в [шаблонах](playbooks_templating#playbooks-templating) и в [циклах](playbooks_loops#playbooks-loops) . Репозиторий [ansible-examples на github](https://github.com/ansible/ansible-examples) содержит множество примеров использования переменных в Ansible.

Как только вы поймете концепции и примеры на этой странице, прочтите о [фактах](playbooks_vars_facts#vars-and-facts) об Ansible , которые представляют собой переменные, которые вы получаете из удаленных систем.

*   [Создание имен действительных переменных](#creating-valid-variable-names)
*   [Simple variables](#simple-variables)
    
    *   [Определение простых переменных](#defining-simple-variables)
    *   [Ссылка на простые переменные](#referencing-simple-variables)
*   [Когда заключать в кавычки переменные (YAML получено)](#when-to-quote-variables-a-yaml-gotcha)
*   [List variables](#list-variables)
    
    *   [Определение переменных как списков](#defining-variables-as-lists)
    *   [Переменные списка ссылок](#referencing-list-variables)
*   [Dictionary variables](#dictionary-variables)
    
    *   [Определение переменных как словари key:value](#defining-variables-as-key-value-dictionaries)
    *   [Ключ ссылки:переменные словаря значений](#referencing-key-value-dictionary-variables)
*   [Registering variables](#registering-variables)
*   [Ссылка на вложенные переменные](#referencing-nested-variables)
*   [Преобразование переменных с помощью фильтров Jinja2](#transforming-variables-with-jinja2-filters)
*   [Где установить переменные](#where-to-set-variables)
    
    *   [Определение переменных в инвентаризации](#defining-variables-in-inventory)
    *   [Определение переменных в пьесе](?page=2#defining-variables-in-a-play)
    *   [Определение переменных в включаемых файлах и ролях](?page=2#defining-variables-in-included-files-and-roles)
    *   [Определение переменных во время выполнения](?page=2#defining-variables-at-runtime)
        
        *   [key=value format](?page=2#key-value-format)
        *   [JSON-строковый формат](?page=2#json-string-format)
        *   [vars из JSON или YAML файла](?page=2#vars-from-a-json-or-yaml-file)
*   [Переменный приоритет:Куда поставить переменную?](?page=2#variable-precedence-where-should-i-put-a-variable)
    
    *   [Понимание приоритета переменных](?page=2#understanding-variable-precedence)
    *   [Scoping variables](?page=2#scoping-variables)
    *   [Советы по установке переменных](?page=2#tips-on-where-to-set-variables)
*   [Использование расширенного синтаксиса переменных](#using-advanced-variable-syntax)

Создание имен действительных переменных
---------------------------------------

Не все строки являются допустимыми именами переменных Ansible. Имя переменной может содержать только буквы, цифры и символы подчеркивания. [Ключевые слова Python](https://docs.python.org/3/reference/lexical_analysis.html#keywords) или [ключевые](../reference_appendices/playbooks_keywords#playbook-keywords) слова playbook не являются допустимыми именами переменных. Имя переменной не может начинаться с цифры.

Имена переменных могут начинаться с подчеркивания.Во многих языках программирования переменные,начинающиеся со знака подчеркивания,являются закрытыми.В Ansible это не так.Переменные,начинающиеся со знака подчеркивания,обрабатываются точно так же,как и любая другая переменная.Не полагайтесь на эту конвенцию для конфиденциальности или безопасности.

В этой таблице приведены примеры правильных и неправильных имен переменных:

Имена достоверных переменных

Not valid

`foo`

`*foo` , [ключевые слова Python,](https://docs.python.org/3/reference/lexical_analysis.html#keywords) такие как `async` и `lambda`

`foo_env`

[ключевые слова плейбука,](../reference_appendices/playbooks_keywords#playbook-keywords) такие как `environment`

`foo_port`

`foo-port`, `foo port`, `foo.port`

`foo5`, `_foo`

`5foo`, `12`

Simple variables
----------------

Простые переменные объединяют имя переменной с одним значением. Вы можете использовать этот синтаксис (а также синтаксис для списков и словарей, показанный ниже) в различных местах. Для получения дополнительных сведений об установке переменных в инвентаре, в playbooks, в повторно используемых файлах, в ролях или в командной строке см. [Раздел «Где устанавливать переменные»](#setting-variables) .

### Определение простых переменных

Вы можете определить простую переменную,используя стандартный синтаксис YAML.Например:
```
remote_install_path: /opt/my_app_config
```
### Ссылка на простые переменные

After you define a variable, use Jinja2 syntax to reference it. Jinja2 variables use double curly braces. For example, the expression `My amp goes to {{ max_amp_value }}` demonstrates the most basic form of variable substitution. You can use Jinja2 syntax in playbooks. For example:
```
ansible.builtin.template:
  src: foo.cfg.j2
  dest: '{{ remote_install_path }}/foo.cfg'
```
В этом примере переменная определяет местоположение файла,которое может варьироваться в зависимости от системы.
```
Note
```
Ansible позволяет использовать циклы и условные выражения Jinja2 в [шаблонах,](playbooks_templating#playbooks-templating) но не в playbooks. Вы не можете создать цикл задач. Плейбуки Ansible - это чистый YAML с машинным анализом.

Когда заключать в кавычки переменные (YAML получено)
----------------------------------------------------

Если вы начинаете значение с `{{ foo }}` , вы должны заключить все выражение в кавычки, чтобы создать допустимый синтаксис YAML. Если вы не цитируете все выражение в кавычках, синтаксический анализатор YAML не сможет интерпретировать синтаксис - это может быть переменная или начало словаря YAML. Инструкции по написанию YAML см. В документации по [синтаксису YAML](../reference_appendices/yamlsyntax#yaml-syntax) .

Если вы используете переменную без кавычек,как эта:
```
- hosts: app_servers
  vars:
      app_path: {{ base_path }}/22
```
Вы увидите: `ERROR! Syntax Error while loading YAML.` Если добавить кавычки, Ansible работает правильно:
```
- hosts: app_servers
  vars:
       app_path: "{{ base_path }}/22"
```
List variables
--------------

Переменная списка объединяет имя переменной с несколькими значениями. Несколько значений могут быть сохранены в виде детализированного списка или в квадратных скобках `[]` , разделенных запятыми.

### Определение переменных как списков

Вы можете определить переменные с несколькими значениями,используя списки YAML.Например:
```
region:
  - northeast
  - southeast
  - midwest
```
### Переменные списка ссылок

Когда вы используете переменные,определенные как список (также называемый массивом),вы можете использовать отдельные,специфические поля из этого списка.Первый элемент списка-это элемент 0,второй-это элемент 1.Например:
```
region: "{{ region[0] }}"
```
Значение этого выражения будет "северо-восток".

Dictionary variables
--------------------

Словарь хранит данные в парах ключ-значение.Обычно словари используются для хранения сопутствующих данных,таких как информация,содержащаяся в идентификаторе или профиле пользователя.

### Определение переменных как словари key:value

Более сложные переменные можно определить с помощью словарей YAML.Словарь YAML сопоставляет ключи к значениям.Например:
```
foo:
  field1: one
  field2: two
```
### Ключ ссылки:переменные словаря значений

Когда вы используете переменные,определяемые как словарь key:value (также называемый хэшем),вы можете использовать отдельные,специфические поля из этого словаря,используя либо нотацию в скобках,либо точечную нотацию:
```
foo['field1']
foo.field1
```
Оба примера ссылаются на одно и то же значение ("один").Скобочная нотация всегда работает.Точечная нотация может вызвать проблемы,потому что некоторые ключи сталкиваются с атрибутами и методами словарей python.Используйте скобочную нотацию,если вы используете ключи,которые начинаются и заканчиваются двумя символами подчеркивания (которые зарезервированы для специальных значений в python)или являются одним из известных публичных атрибутов:

`add` , `append` , `as_integer_ratio` , `bit_length` , `capitalize` , `center` , `clear` , `conjugate` , `copy` , `count` , `decode` , `denominator` , `difference` , `difference_update` , `discard` , `encode` , `endswith` , `expandtabs` , `extend` , `find` , `format` , `fromhex` , `fromkeys` , `get` , `has_key` , `hex` , `imag` , `index` , `insert` , `intersection` , `intersection_update` , `isalnum` , `isalpha` , `isdecimal` , `isdigit` , `isdisjoint` , `is_integer` , `islower` , `isnumeric` , `isspace` , `issubset` , `issuperset` , `istitle` , `isupper` , `items` , `iteritems` , `iterkeys` , `itervalues` , `join` , `keys` , `ljust` , `lower` , `lstrip` , `numerator` , `partition` , `pop` , `popitem` , `real` , `remove` , `replace` , `reverse` , `rfind` , `rindex` , `rjust` , `rpartition` , `rsplit` , `rstrip` , `setdefault` , `sort` , `split` , `splitlines` , `startswith` , `strip` , `swapcase` , `symmetric_difference` , `symmetric_difference_update` , `title` , `translate` , `union` , `update` , `upper` , `values` , `viewitems` , `viewkeys` , значения `viewvalues` , `zfill` .

Registering variables
---------------------

Вы можете создавать переменные из вывода задачи Ansible с помощью `register` ключевого слова задачи . Вы можете использовать зарегистрированные переменные в любых последующих задачах вашей игры. Например:
```
- hosts: web_servers

  tasks:

     - name: Run a shell command and register its output as a variable
       ansible.builtin.shell: /usr/bin/foo
       register: foo_result
       ignore_errors: true

     - name: Run a shell command using output of the previous task
       ansible.builtin.shell: /usr/bin/bar
       when: foo_result.rc == 5
```
For more examples of using registered variables in conditions on later tasks, see [Conditionals](playbooks_conditionals#playbooks-conditionals). Registered variables may be simple variables, list variables, dictionary variables, or complex nested data structures. The documentation for each module includes a `RETURN` section describing the return values for that module. To see the values for a particular task, run your playbook with `-v`.

Зарегистрированные переменные хранятся в памяти.Вы не можете кэшировать зарегистрированные переменные для использования в будущих воспроизведениях.Зарегистрированные переменные действительны только на хосте в течение оставшейся части текущего проигрывания.

Зарегистрированные переменные - это переменные уровня хоста. Когда вы регистрируете переменную в задаче с циклом, зарегистрированная переменная содержит значение для каждого элемента в цикле. Структура данных, помещенная в переменную во время цикла, будет содержать атрибут `results` , то есть список всех ответов от модуля. Более подробный пример того, как это работает, см. В разделе « [Циклы](playbooks_loops#playbooks-loops) » об использовании регистра с циклом.
```
Note
```
Если задача не выполняется или пропускается, Ansible по-прежнему регистрирует переменную с ошибкой или пропущенным статусом, если только задача не пропущена на основе тегов. См. Раздел [Теги](playbooks_tags#tags) для получения информации о добавлении и использовании тегов.

Ссылка на вложенные переменные
------------------------------

Многие зарегистрированные переменные (и [факты](playbooks_vars_facts#vars-and-facts) ) представляют собой вложенные структуры данных YAML или JSON. Вы не можете получить доступ к значениям из этих вложенных структур данных с помощью простого синтаксиса `{{ foo }}` . Вы должны использовать запись в скобках или точку. Например, чтобы ссылаться на IP-адрес из ваших фактов, используя обозначение скобок:
```
{{ ansible_facts["eth0"]["ipv4"]["address"] }}
```
Ссылка на IP-адрес из ваших фактов с помощью точечной нотации:
```
{{ ansible_facts.eth0.ipv4.address }}
```
Преобразование переменных с помощью фильтров Jinja2
---------------------------------------------------

Фильтры Jinja2 позволяют преобразовывать значение переменной в выражении шаблона. Например, фильтр заглавными буквами использует любое переданное ему значение с `capitalize` буквы; в `to_yaml` и `to_json` фильтры изменить формат ваших значений переменных. Jinja2 включает множество [встроенных фильтров,](https://jinja.palletsprojects.com/templates/#builtin-filters) а Ansible предлагает гораздо больше фильтров. Чтобы найти больше примеров фильтров, см. [Использование фильтров для управления данными](playbooks_filters#playbooks-filters) .

Где установить переменные
-------------------------

Вы можете определять переменные в различных местах, например в инвентаре, в книгах воспроизведения, в повторно используемых файлах, в ролях и в командной строке. Ansible загружает каждую возможную переменную, которую находит, а затем выбирает переменную для применения на основе [правил приоритета переменных](?page=2#ansible-variable-precedence) .

### Определение переменных в инвентаризации

Вы можете определить разные переменные для каждого отдельного хоста или установить общие переменные для группы хостов в вашем инвентаре. Например, если все машины в группе `[Boston]` используют «boston.ntp.example.com» в качестве NTP-сервера, вы можете установить групповую переменную. На странице « Как [создать инвентарь»](intro_inventory#intro-inventory) есть подробная информация о настройке [переменных хоста](intro_inventory#host-variables) и [групповых переменных](intro_inventory#group-variables) в инвентаре.
