Loops
=====

Анзибль предлагает `loop` , `with_<lookup>` , и `until` ключевые слова не выполнить поставленную задачу несколько раз. Примеры часто используемых циклов включают смену владельца на несколько файлов и / или каталогов с помощью [файлового модуля](../collections/ansible/builtin/file_module#file-module) , создание нескольких пользователей с помощью [пользовательского модуля](../collections/ansible/builtin/user_module#user-module) и повторение шага опроса до тех пор, пока не будет достигнут определенный результат.

Note

*   Мы добавили `loop` в Ansible 2.5. Это еще не полная замена `with_<lookup>` , но мы рекомендуем его для большинства случаев использования.
*   Мы не осуждаем использование `with_<lookup>` - этот синтаксис все еще будет действовать в обозримом будущем.
*   Мы стремимся улучшить синтаксис `loop` - следите за обновлениями на этой странице и [журнале](https://github.com/ansible/ansible/tree/devel/changelogs) изменений.

*   [Сравнивая `loop` и `with_*`](#comparing-loop-and-with)
*   [Standard loops](#standard-loops)
    
    *   [разбросанный по простому списку](#iterating-over-a-simple-list)
    *   [преувеличивая список хэшей](#iterating-over-a-list-of-hashes)
    *   [искажение по словарю](#iterating-over-a-dictionary)
*   [Регистрация переменных в цикле](#registering-variables-with-a-loop)
*   [Complex loops](#complex-loops)
    
    *   [искажение по вложенным спискам](#iterating-over-nested-lists)
    *   [Повторное выполнение задания до тех пор,пока условие не будет выполнено.](#retrying-a-task-until-a-condition-is-met)
    *   [Переключение на инвентаризацию](#looping-over-inventory)
*   [Ensuring list input for `loop`: using `query` rather than `lookup`](#ensuring-list-input-for-loop-using-query-rather-than-lookup)
*   [Добавление элементов управления в контуры](#adding-controls-to-loops)
    
    *   [Ограничение выходного контура с `label`](#limiting-loop-output-with-label)
    *   [Пауза в пределах петли](?page=2#pausing-within-a-loop)
    *   [Отслеживание прогресса через цикл с помощью `index_var`](?page=2#tracking-progress-through-a-loop-with-index-var)
    *   [Определение внутренних и внешних имен переменных с помощью `loop_var`](?page=2#defining-inner-and-outer-variable-names-with-loop-var)
    *   [Переменные расширенного цикла](?page=2#extended-loop-variables)
    *   [Доступ к имени вашего loop\_var](?page=2#accessing-the-name-of-your-loop-var)
*   [Миграция из с\_X в цикл](?page=2#migrating-from-with-x-to-loop)
    
    *   [with\_list](?page=2#with-list)
    *   [with\_items](?page=2#with-items)
    *   [with\_indexed\_items](?page=2#with-indexed-items)
    *   [with\_flattened](?page=2#with-flattened)
    *   [with\_together](?page=2#with-together)
    *   [with\_dict](?page=2#with-dict)
    *   [with\_sequence](?page=2#with-sequence)
    *   [with\_subelements](?page=2#with-subelements)
    *   [with\_nested/with\_cartesian](?page=2#with-nested-with-cartesian)
    *   [with\_random\_choice](?page=2#with-random-choice)

Сравнивая `loop` и `with_*`
---------------------------

*   `with_<lookup>` ключевые слова полагаться на [просмотровых Плагины](../plugins/lookup#lookup-plugins) - даже `items` является поиск.
*   `loop` ключевое слово эквивалентно `with_list` , и это лучший выбор для простых петель.
*   `loop` ключевое слово не будет принимать строку в качестве входных данных, см [Обеспечение ввода списка для цикла: с помощью запроса , а не поиска](#query-vs-lookup) .
*   Вообще говоря, любое использование `with_*` , описанное в разделе « [Миграция с with\_X на цикл»](?page=2#migrating-to-loop) , может быть обновлено для использования `loop` .
*   Будьте осторожны при изменении `with_items` на `loop` , так как `with_items` выполняет неявное одноуровневое выравнивание. Возможно, вам придется использовать `flatten(1)` с `loop` чтобы соответствовать точному результату. Например, чтобы получить тот же результат, что и:
```
with_items:
  - 1
  - [2,3]
  - 4
```
тебе бы это понадобилось:
```
loop: "{{ [1, [2,3] ,4] | flatten(1) }}"
```
*   Любой оператор `with_*` , который требует использования `lookup` в цикле, не следует преобразовывать в ключевое слово `loop` . Например, вместо того, чтобы делать:
```
loop: "{{ lookup('fileglob', '*.txt', wantlist=True) }}"
```
чище,чтобы сохранить:
```
with_fileglob: '*.txt'
```
Standard loops
--------------

### разбросанный по простому списку

Повторяющиеся задачи могут быть записаны как стандартные циклы по простому списку строк.Вы можете определить список непосредственно в задаче:
```
- name: Add several users
  ansible.builtin.user:
    name: "{{ item }}"
    state: present
    groups: "wheel"
  loop:
     - testuser1
     - testuser2
```
Вы можете определить список в файле переменных или в разделе 'vars' вашей пьесы,а затем ссылаться на имя списка в задании:
```
loop: "{{ somelist }}"
```
Любой из этих примеров был бы эквивалентен:
```
- name: Add user testuser1
  ansible.builtin.user:
    name: "testuser1"
    state: present
    groups: "wheel"

- name: Add user testuser2
  ansible.builtin.user:
    name: "testuser2"
    state: present
    groups: "wheel"
```
Вы можете передать список прямо в параметр для некоторых плагинов. Большинство упаковочных модулей, таких как [yum](../collections/ansible/builtin/yum_module#yum-module) и [apt](../collections/ansible/builtin/apt_module#apt-module) , имеют такую ​​возможность. Если возможно, передача списка параметру лучше, чем цикл по задаче. Например:
```
- name: Optimal yum
  ansible.builtin.yum:
    name: "{{  list_of_packages  }}"
    state: present

- name: Non-optimal yum, slower and may cause issues with interdependencies
  ansible.builtin.yum:
    name: "{{  item  }}"
    state: present
  loop: "{{  list_of_packages  }}"
```
Проверьте [документацию по модулю](https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html#modules-by-category) , чтобы узнать, можете ли вы передать список параметрам какого-либо конкретного модуля.

### преувеличивая список хэшей

Если у вас есть список хэшей,вы можете ссылаться на подклавиши в цикле.Например:
```
- name: Add several users
  ansible.builtin.user:
    name: "{{ item.name }}"
    state: present
    groups: "{{ item.groups }}"
  loop:
    - { name: 'testuser1', groups: 'wheel' }
    - { name: 'testuser2', groups: 'root' }
```
При объединении [условных](playbooks_conditionals#playbooks-conditionals) выражений с циклом оператор `when:` обрабатывается отдельно для каждого элемента. См. Примеры в разделе « [Основные условные выражения с когда»](playbooks_conditionals#the-when-statement) .

### искажение по словарю

Чтобы [перебрать](playbooks_filters#dict-filter) dict, используйте dict2items :
```
- name: Using dict2items
  ansible.builtin.debug:
    msg: "{{ item.key }} - {{ item.value }}"
  loop: "{{ tag_data | dict2items }}"
  vars:
    tag_data:
      Environment: dev
      Application: payment
```
Здесь мы перебираем `tag_data` и печатаем ключ и значение из него.

Регистрация переменных в цикле
------------------------------

Выход цикла можно зарегистрировать как переменную.Например:
```
- name: Register loop output as a variable
  ansible.builtin.shell: "echo {{ item }}"
  loop:
    - "one"
    - "two"
  register: echo
```
Когда вы используете `register` с циклом, структура данных, помещенная в переменную, будет содержать атрибут `results` , представляющий собой список всех ответов от модуля. Это отличается от структуры данных, возвращаемой при использовании `register` без цикла:
```
{
    "changed": true,
    "msg": "All items completed",
    "results": [
        {
            "changed": true,
            "cmd": "echo \"one\" ",
            "delta": "0:00:00.003110",
            "end": "2013-12-19 12:00:05.187153",
            "invocation": {
                "module_args": "echo \"one\"",
                "module_name": "shell"
            },
            "item": "one",
            "rc": 0,
            "start": "2013-12-19 12:00:05.184043",
            "stderr": "",
            "stdout": "one"
        },
        {
            "changed": true,
            "cmd": "echo \"two\" ",
            "delta": "0:00:00.002920",
            "end": "2013-12-19 12:00:05.245502",
            "invocation": {
                "module_args": "echo \"two\"",
                "module_name": "shell"
            },
            "item": "two",
            "rc": 0,
            "start": "2013-12-19 12:00:05.242582",
            "stderr": "",
            "stdout": "two"
        }
    ]
}
```
Последующие циклы по зарегистрированной переменной для проверки результатов могут выглядеть так:
```
- name: Fail if return code is not 0
  ansible.builtin.fail:
    msg: "The command ({{ item.cmd }}) did not have a 0 return code"
  when: item.rc != 0
  loop: "{{ echo.results }}"
```
Во время итерации результат текущего элемента будет помещен в переменную:
```
- name: Place the result of the current item in the variable
  ansible.builtin.shell: echo "{{ item }}"
  loop:
    - one
    - two
  register: echo
  changed_when: echo.stdout != "one"
```
Complex loops
-------------

### искажение по вложенным спискам

Вы можете использовать выражения Jinja2 для итераций по сложным спискам.Например,цикл может объединять вложенные списки:
```
- name: Give users access to multiple databases
  community.mysql.mysql_user:
    name: "{{ item[0] }}"
    priv: "{{ item[1] }}.*:ALL"
    append_privs: yes
    password: "foo"
  loop: "{{ ['alice', 'bob'] |product(['clientdb', 'employeedb', 'providerdb'])|list }}"
```
### Повторное выполнение задания до тех пор,пока условие не будет выполнено.

Новинка в версии 1.4.

Вы можете использовать ключевое слово, `until` не повторите задачу, пока не будет выполнено определенное условие. Вот пример:
```
- name: Retry a task until a certain condition is met
  ansible.builtin.shell: /usr/bin/foo
  register: result
  until: result.stdout.find("all systems go") != -1
  retries: 5
  delay: 10
```
Эта задача выполняется до 5 раз с задержкой в 10 секунд между каждой попыткой.Если в результате любой попытки в stdout появляется сообщение "all systems go",задача успешна.Значение по умолчанию для "повторных попыток" равно 3,а для "задержки"-5.

Чтобы увидеть результаты отдельных повторов, запустите игру с `-vv` .

Когда вы запускаете задачу с `until` и регистрируете результат как переменную, зарегистрированная переменная будет включать в себя ключ под названием «попытки», который записывает количество повторных попыток для задачи.
```
Note
```
Вы должны установить параметр `until` если вы хотите, чтобы задача повторилась. Если `until` не определено, значение параметра `retries` будет равно 1.

### Переключение на инвентаризацию

Чтобы перебрать ваш инвентарь или его подмножество, вы можете использовать обычный `loop` с переменными `ansible_play_batch` или `groups` :
```
- name: Show all the hosts in the inventory
  ansible.builtin.debug:
    msg: "{{ item }}"
  loop: "{{ groups['all'] }}"

- name: Show all the hosts in the current play
  ansible.builtin.debug:
    msg: "{{ item }}"
  loop: "{{ ansible_play_batch }}"
```
Существует также определенный поиск плагин `inventory_hostnames` , которые могут быть использованы , как это:
```
- name: Show all the hosts in the inventory
  ansible.builtin.debug:
    msg: "{{ item }}"
  loop: "{{ query('inventory_hostnames', 'all') }}"

- name: Show all the hosts matching the pattern, ie all but the group www
  ansible.builtin.debug:
    msg: "{{ item }}"
  loop: "{{ query('inventory_hostnames', 'all:!www') }}"
```
Более подробную информацию о шаблонах можно найти в разделе [Шаблоны: таргетинг на узлы и группы](intro_patterns#intro-patterns) .

Ensuring list input for `loop`: using `query` rather than `lookup`
------------------------------------------------------------------

`loop` ключевых слов требует список в качестве входных данных, но `lookup` ключевого слова возвращает строку значений , разделенных запятой по умолчанию. В Ansible 2.5 появилась новая функция Jinja2 с именем [query,](../plugins/lookup#query) которая всегда возвращает список, предлагая более простой интерфейс и более предсказуемый вывод от плагинов поиска при использовании ключевого слова `loop` .

Вы можете заставить `lookup` возвращать список в `loop` , используя `wantlist=True` , или вы можете использовать `query` вместо этого.

Эти примеры делают то же самое:
```
loop: "{{ query('inventory_hostnames', 'all') }}"

loop: "{{ lookup('inventory_hostnames', 'all', wantlist=True) }}"
```
Добавление элементов управления в контуры
-----------------------------------------

Новинка в версии 2.1.

`loop_control` ключевое слово позволяет Вам управлять своими петлями полезными способами.

### Ограничение выходного контура с `label`

Новинка в версии 2.2.

При зацикливании сложных структур данных вывод вашей задачи на консоль может быть огромным. Чтобы ограничить отображаемый вывод, используйте директиву `label` с `loop_control` :
```
- name: Create servers
  digital_ocean:
    name: "{{ item.name }}"
    state: present
  loop:
    - name: server1
      disks: 3gb
      ram: 15Gb
      network:
        nic01: 100Gb
        nic02: 10Gb
        ...
  loop_control:
    label: "{{ item.name }}"
```
Выходные данные этой задачи будут отображать только поле `name` для каждого `item` а не все содержимое многострочной переменной `{{ item }}` .
```
Note
```
Это сделано для того, чтобы сделать консольный вывод более читабельным, а не защищать конфиденциальные данные. Если в `loop` есть конфиденциальные данные , установите `no_log: yes` в задаче, чтобы предотвратить раскрытие.
