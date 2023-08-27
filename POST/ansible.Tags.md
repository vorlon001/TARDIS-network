Tags
====

Если у вас большая книга воспроизведения,может быть полезно запустить только определенные его части,вместо того,чтобы запускать всю книгу воспроизведения.Это можно сделать с помощью тэгов "Допустимо".Использование тегов для выполнения или пропуска выбранных задач является двухэтапным процессом:

1.  Добавляйте теги к своим задачам,как по отдельности,так и с наследованием тегов от блока,игры,роли или импорта.
2.  Выберите или пропустите теги при запуске плейбога.

*   [Добавление тегов с ключевым словом tags](#adding-tags-with-the-tags-keyword)
    
    *   [Добавление тегов к отдельным задачам](#adding-tags-to-individual-tasks)
    *   [Добавление тегов для включения](#adding-tags-to-includes)
    *   [Наследование тегов:добавление тегов к нескольким задачам](#tag-inheritance-adding-tags-to-multiple-tasks)
        
        *   [Добавление тегов к блокам](#adding-tags-to-blocks)
        *   [Добавление тегов в игры](#adding-tags-to-plays)
        *   [Добавление тегов к ролям](#adding-tags-to-roles)
        *   [Добавление тегов к импорту](#adding-tags-to-imports)
        *   [Наследование тегов для includes: блоков и ключевого слова `apply`](#tag-inheritance-for-includes-blocks-and-the-apply-keyword)
*   [Специальные теги:всегда и никогда](#special-tags-always-and-never)
*   [Выбор или пропуск тегов при запуске плейбога.](#selecting-or-skipping-tags-when-you-run-a-playbook)
    
    *   [Предварительный просмотр результатов использования тегов](#previewing-the-results-of-using-tags)
    *   [Выборочный запуск задач с метками в повторно используемых файлах](#selectively-running-tagged-tasks-in-re-usable-files)
    *   [Глобальная настройка тегов](#configuring-tags-globally)

Добавление тегов с ключевым словом tags
---------------------------------------

Вы можете добавить теги к отдельной задаче или включить. Вы также можете добавлять теги к нескольким задачам, определяя их на уровне блока, игры, роли или импорта. `tags` ключевых слов предназначены для всех этих случаев использования. В `tags` ключевого слово всегда определяют тег и добавляют их к задачам; он не выбирает и не пропускает задачи для выполнения. Вы можете выбирать или пропускать задачи только на основе тегов в командной строке при запуске playbook. Дополнительные сведения см. В разделе [Выбор или пропуск тегов при запуске playbook](#using-tags) .

### Добавление тегов к отдельным задачам

На самом простом уровне,вы можете применить один или несколько тегов к индивидуальной задаче.Вы можете добавлять теги к задачам в плейбуках,в файлах задач или в ролях.Приведем пример,когда две задачи имеют разные теги:
```
tasks:
- name: Install the servers
  ansible.builtin.yum:
    name:
    - httpd
    - memcached
    state: present
  tags:
  - packages
  - webservers

- name: Configure the service
  ansible.builtin.template:
    src: templates/src.j2
    dest: /etc/foo.conf
  tags:
  - configuration
```
Вы можете применить один и тот же тег к нескольким отдельным задачам.В этом примере несколько задач помечены одним и тем же тегом "ntp":
```
---
# файл: роли / общие / задачи / main.yml

- name: Install ntp
  ansible.builtin.yum:
    name: ntp
    state: present
  tags: ntp

- name: Configure ntp
  ansible.builtin.template:
    src: ntp.conf.j2
    dest: /etc/ntp.conf
  notify:
  - restart ntpd
  tags: ntp

- name: Enable and run ntpd
  ansible.builtin.service:
    name: ntpd
    state: started
    enabled: yes
  tags: ntp

- name: Install NFS utils
  ansible.builtin.yum:
    name:
    - nfs-utils
    - nfs-util-lib
    state: present
  tags: filesharing
```
Если вы запустите эти четыре задачи в playbook с `--tags ntp` , Ansible запустит три задачи с тегом `ntp` и пропустит одну задачу, у которой нет этого тега.

### Добавление тегов для включения

Вы можете применять теги к динамическим включениям в playbook. Как и теги в отдельной задаче, теги в задаче `include_*` применяются только к самому включению, а не к каким-либо задачам во включенном файле или роли. Если вы добавляете `mytag` к динамическому включению, затем запускаете этот playbook с помощью `--tags mytag` , Ansible запускает само включение, выполняет любые задачи во включенном файле или роли, помеченные `mytag` , и пропускает любые задачи в включенном файле или роли без этого. тег. Дополнительные сведения см. В разделе « [Выборочный запуск задач с тегами в повторно используемых файлах»](#selective-reuse) .

Вы добавляете теги так же,как добавляете теги к любой другой задаче:
```
---
# файл: роли / общие / задачи / main.yml

- name: Dynamic re-use of database tasks
  include_tasks: db.yml
  tags: db
```
Вы можете добавить тег только к динамическому включению роли. В этом примере тег `foo` `not` будет применяться к задачам внутри роли `bar` :
```
---
- hosts: webservers
  tasks:
    - name: Include the bar role
      include_role:
        name: bar
      tags:
        - foo
```
С играми, блоками, ключевым словом `role` и статическим импортом Ansible применяет наследование тегов, добавляя теги, которые вы определяете, к каждой задаче внутри play, блока, роли или импортированного файла. Однако наследование тегов _не_ применяется к динамическому повторному использованию с `include_role` и `include_tasks` . При динамическом повторном использовании (включает) определенные вами теги применяются только к самому включению. Если вам нужно наследование тегов, используйте статический импорт. Если вы не можете использовать импорт, потому что остальная часть вашего учебника использует include, см. [Наследование тегов для include: blocks и ключевое слово apply](#apply-keyword) , чтобы узнать, как обойти это поведение.

### Наследование тегов:добавление тегов к нескольким задачам

Если вы хотите применить один и тот же тег или теги к нескольким задачам без добавления строки `tags` к каждой задаче, вы можете определить теги на уровне вашей игры или блока, или когда вы добавляете роль или импортируете файл. Ansible применяет теги вниз по цепочке зависимостей ко всем дочерним задачам. С помощью ролей и импорта Ansible добавляет теги, установленные в разделе `roles` или импорте, к любым тегам, установленным для отдельных задач или блоков в роли или импортированном файле. Это называется наследованием тегов. Наследование тегов удобно, потому что вам не нужно тегировать каждую задачу. Однако теги по-прежнему применяются к задачам индивидуально.

#### Добавление тегов к блокам

Если вы хотите применить тег ко многим, но не ко всем задачам в вашей игре, используйте [блок](playbooks_blocks#playbooks-blocks) и определите теги на этом уровне. Например, мы могли бы отредактировать показанный выше пример NTP, чтобы использовать блок:
```
# myrole/tasks/main.yml
tasks:
- name: ntp tasks
  tags: ntp
  block:
  - name: Install ntp
    ansible.builtin.yum:
      name: ntp
      state: present

  - name: Configure ntp
    ansible.builtin.template:
      src: ntp.conf.j2
      dest: /etc/ntp.conf
    notify:
    - restart ntpd

  - name: Enable and run ntpd
    ansible.builtin.service:
      name: ntpd
      state: started
      enabled: yes

- name: Install NFS utils
  ansible.builtin.yum:
    name:
    - nfs-utils
    - nfs-util-lib
    state: present
  tags: filesharing
```
#### Добавление тегов в игры

Если все задания в пьесе должны иметь один и тот же тег,то можно добавить тег на уровне пьесы.Например,если вы играли только с заданиями NTP,вы можете пометить тегом всю игру:
```
- hosts: all
  tags: ntp
  tasks:
  - name: Install ntp
    ansible.builtin.yum:
      name: ntp
      state: present

  - name: Configure ntp
    ansible.builtin.template:
      src: ntp.conf.j2
      dest: /etc/ntp.conf
    notify:
    - restart ntpd

  - name: Enable and run ntpd
    ansible.builtin.service:
      name: ntpd
      state: started
      enabled: yes

- hosts: fileservers
  tags: filesharing
  tasks:
  ...
```
#### Добавление тегов к ролям

Есть три способа добавить теги к ролям:

1.  Добавьте один и тот же тег или теги ко всем задачам в роли, установив теги под `roles` . См. Примеры в этом разделе.
2.  Добавьте один и тот же тег или теги ко всем задачам в роли, установив теги для статической `import_role` в своей книге. См. Примеры в разделе « [Добавление тегов к импорту»](#tags-on-imports) .
3.  Добавьте тег или теги к отдельным задачам или блокам внутри самой роли. Это единственный подход, который позволяет вам выбрать или пропустить некоторые задачи в рамках роли. Чтобы выбрать или пропустить задачи в рамках роли, вы должны иметь теги, установленные для отдельных задач или блоков, использовать динамическую `include_role` в вашей книге и добавить тот же тег или теги в include. Когда вы используете этот подход, а затем запускаете свой playbook с `--tags foo` , Ansible запускает само включение и любые задачи в роли, которые также имеют тег `foo` . Подробнее см. [Добавление тегов в включает](#tags-on-includes) .

Когда вы статически включаете роль в свою книгу действий с ключевым словом `roles` , Ansible добавляет любые теги, которые вы определяете, ко всем задачам в роли. Например:
```
roles:
  - role: webserver
    vars:
      port: 5000
    tags: [ web, foo ]
```
or:
```
---
- hosts: webservers
  roles:
    - role: foo
      tags:
        - bar
        - baz
    # используя сокращение YAML, это эквивалентно:
    # - { role: foo, tags: ["bar", "baz"] }
```
#### Добавление тегов к импорту

Вы также можете применить тег или теги ко всем задачам, импортированным статическими `import_role` и `import_tasks` :
```
---
- hosts: webservers
  tasks:
    - name: Import the foo role
      import_role:
        name: foo
      tags:
        - bar
        - baz

    - name: Import tasks from foo.yml
      import_tasks: foo.yml
      tags: [ web, foo ]
```
#### Наследование тегов для includes: блоков и ключевого слова `apply`

По умолчанию Ansible не применяет [наследование тегов](#tag-inheritance) к динамическому повторному использованию с `include_role` и `include_tasks` . Если вы добавляете теги к включению, они применяются только к самому включению, а не к каким-либо задачам во включенном файле или роли. Это позволяет вам выполнять выбранные задачи в файле роли или задачи - см. [Выборочный запуск помеченных задач в повторно используемых файлах](#selective-reuse) при запуске playbook.

Если вы хотите наследование тегов, вы, вероятно, захотите использовать импорт. Однако использование как включений, так и импорта в одной книге может привести к трудно диагностируемым ошибкам. По этой причине, если ваш playbook использует `include_*` для повторного использования ролей или задач, и вам нужно наследование тегов для одного include, Ansible предлагает два обходных пути. Вы можете использовать ключевое слово `apply` :
```
- name: Apply the db tag to the include and to all tasks in db.yaml
  include_tasks:
    file: db.yml
    # добавляет тег db к задачам в db.yml
    apply:
      tags: db
  # добавляет тег 'db' к самому этому 'include_tasks'
  tags: db
```
Или ты можешь использовать блок:
```
- block:
   - name: Include tasks from db.yml
     include_tasks: db.yml
  tags: db
```
Специальные теги:всегда и никогда
---------------------------------

Ansible reserves two tag names for special behavior: always and never. If you assign the `always` tag to a task or play, Ansible will always run that task or play, unless you specifically skip it (`--skip-tags always`).

For example:
```
tasks:
- name: Print a message
  ansible.builtin.debug:
    msg: "Always runs"
  tags:
  - always

- name: Print a message
  ansible.builtin.debug:
    msg: "runs when you use tag1"
  tags:
  - tag1
```
Warning

*   Сбор фактов по умолчанию отмечен тегом «всегда». Он пропускается только в том случае, если вы применяете тег, а затем используете другой тег в `--tags` или тот же тег в `--skip-tags` .

Warning

*   Задача проверки спецификации аргумента роли по умолчанию помечена тегом «всегда». Эта проверка будет пропущена, если вы `--skip-tags always` .

Новинка в версии 2.5.

Если вы назначите тег `never` задаче или игре, Ansible пропустит эту задачу или воспроизведение, если вы специально этого не запросите ( `--tags never` ).

For example:
```
tasks:
  - name: Run the rarely-used debug task
    ansible.builtin.debug:
     msg: '{{ showmevar }}'
    tags: [ never, debug ]
```
Редко используемая задача отладки в приведенном выше примере запускается только тогда, когда вы специально запрашиваете теги `debug` или `never` .

Выбор или пропуск тегов при запуске плейбога.
---------------------------------------------

После того, как вы добавили теги в свои задачи, включает, блоки, игры, роли и импорт, вы можете выборочно выполнять или пропускать задачи на основе их тегов при запуске [ansible-playbook](../cli/ansible-playbook#ansible-playbook) . Ansible запускает или пропускает все задачи с тегами, соответствующими тегам, которые вы передаете в командной строке. Если вы добавили тег на уровне блока или воспроизведения, с `roles` или с импортом, этот тег применяется к каждой задаче внутри блока, игры, роли или импортированной роли или файла. Если у вас есть роль с большим количеством тегов, и вы хотите вызывать подмножества роли в разное время, либо [используйте ее с динамическими](#selective-reuse) включениями, либо разделите роль на несколько ролей.

[ansible-playbook](../cli/ansible-playbook#ansible-playbook) предлагает пять параметров командной строки, связанных с тегами:

*   `--tags all` - запускать все задачи, игнорировать теги (поведение по умолчанию)
*   `--tags [tag1, tag2]` - запускать только задачи с тегом `tag1` или тегом `tag2`
*   `--skip-tags [tag3, tag4]` - запускать все задачи, кроме тех, у которых есть тег `tag3` или тег `tag4`
*   `--tags tagged` - запускать только задачи с хотя бы одним тегом
*   `--tags untagged` - запускать только задачи без тегов

For example, to run only tasks and blocks tagged `configuration` and `packages` in a very long playbook:

ansible-playbook example.yml --tags "configuration,packages"

Чтобы запустить все задачи, кроме отмеченных `packages` :

ansible-playbook example.yml --skip-tags "packages"

### Предварительный просмотр результатов использования тегов

Когда вы запускаете роль или учебник, вы можете не знать или не помнить, какие задачи имеют какие теги или какие теги существуют вообще. Ansible предлагает два флага командной строки для [ansible-playbook,](../cli/ansible-playbook#ansible-playbook) которые помогут вам управлять тегами playbook:

*   `--list-tags` - сформировать список доступных тегов
*   `--list-tasks` - при использовании с `--tags tagname` или `--skip-tags tagname` генерировать предварительный просмотр помеченных задач

For example, if you do not know whether the tag for configuration tasks is `config` or `conf` in a playbook, role, or tasks file, you can display all available tags without running any tasks:

ansible-playbook example.yml --list-tags

Если вы не знаете, какие задачи имеют `configuration` тегов и `packages` , вы можете передать эти теги и добавить `--list-tasks` . Ansible перечисляет задачи, но не выполняет ни одну из них.

ansible-playbook example.yml --tags "configuration,packages" --list-tasks

У этих флагов командной строки есть одно ограничение: они не могут отображать теги или задачи в динамически включаемых файлах или ролях. См. Раздел [Сравнение включений и импортов: динамическое и статическое повторное использование](playbooks_reuse#dynamic-vs-static) для получения дополнительной информации о различиях между статическим импортом и динамическими включениями.

### Выборочный запуск задач с метками в повторно используемых файлах

Если у вас есть роль или файл задач с тегами,определенными на уровне задачи или блока,вы можете выборочно запустить или пропустить эти теги в книге воспроизведения,если вы используете динамический include вместо статического импорта.Вы должны использовать один и тот же тег для включенных задач и для самого включаемого оператора.Например,вы можете создать файл с некоторыми тегами и некоторыми немаркированными задачами:
```
# mixed.yml
tasks:
- name: Run the task with no tags
  ansible.builtin.debug:
    msg: this task has no tags

- name: Run the tagged task
  ansible.builtin.debug:
    msg: this task is tagged with mytag
  tags: mytag

- block:
  - name: Run the first block task with mytag
    ...
  - name: Run the second block task with mytag
    ...
  tags:
  - mytag
```
И вы можете включить вышеприведенный файл задач в книгу воспроизведения:
```
# myplaybook.yml
- hosts: all
  tasks:
  - name: Run tasks from mixed.yml
    include_tasks:
      name: mixed.yml
    tags: mytag
```
Когда вы запускаете playbook с помощью `ansible-playbook -i hosts myplaybook.yml --tags "mytag"` , Ansible пропускает задачу без тегов, запускает отдельную задачу с тегами и выполняет две задачи в блоке.

### Глобальная настройка тегов

Если вы запускаете или пропускаете определенные теги по умолчанию, вы можете использовать параметры [TAGS_RUN](../../reference_appendices/config?page=8#tags-run) и [TAGS_SKIP](../../reference_appendices/config?page=8#tags-skip) в конфигурации Ansible, чтобы установить эти значения по умолчанию.
