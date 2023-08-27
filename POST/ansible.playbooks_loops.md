Пауза в пределах петли
======================

Новинка в версии 2.2.

Чтобы контролировать время (в секундах) между выполнением каждого элемента в цикле задач, используйте директиву `pause` с `loop_control` :
```
# main.yml
- name: Create servers, pause 3s before creating next
  community.digitalocean.digital\_ocean:
    name: "{{ item }}"
    state: present
  loop:
    - server1
    - server2
  loop_control:
    pause: 3
```
### Отслеживание прогресса через цикл с помощью `index_var`

Новинка в версии 2.5.

Чтобы отслеживать, где вы находитесь в цикле, используйте директиву `index_var` с `loop_control` . Эта директива указывает имя переменной, которая будет содержать текущий индекс цикла:
```
- name: Count our fruit
  ansible.builtin.debug:
    msg: "{{ item }} with index {{ my\_idx }}"
  loop:
    - apple
    - banana
    - pear
  loop_control:
    index_var: my_idx
```
```
Note
```
`index_var` имеет индекс 0.

### Определение внутренних и внешних имен переменных с помощью `loop_var`

Новинка в версии 2.1.

Вы можете вкладывать две циклические задачи, используя `include_tasks` . Однако по умолчанию Ansible устанавливает `item` переменной цикла для каждого цикла. Это означает, что внутренний вложенный цикл перезапишет значение `item` из внешнего цикла. Вы можете указать имя переменной для каждого цикла, используя `loop_var` с `loop_control` :
```
# main.yml
- include_tasks: inner.yml
  loop:
    - 1
    - 2
    - 3
  loop_control:
    loop_var: outer_item
```
```
# inner.yml
- name: Print outer and inner items
  ansible.builtin.debug:
    msg: "outer item={{ outer_item }} inner item={{ item }}"
  loop:
    - a
    - b
    - c
```
```
Note
```
Если Ansible обнаружит,что в текущем цикле используется уже определенная переменная,то это вызовет ошибку,приводящую к провалу задачи.

### Переменные расширенного цикла

Новинка в версии 2.8.

Начиная с версии 2.8 вы можете получить расширенную информацию о цикле, используя `extended` опцию для управления циклом. Эта опция предоставит следующую информацию.

Variable

Description

`ansible_loop.allitems`

Список всех элементов в цикле

`ansible_loop.index`

Текущая итерация петли.(1 индексированная)

`ansible_loop.index0`

Текущая итерация петли.(0 проиндексировано)

`ansible_loop.revindex`

Количество итераций с конца цикла (1 индексированная)

`ansible_loop.revindex0`

Количество итераций в конце цикла (0 проиндексировано)

`ansible_loop.first`

`True` если первая итерация

`ansible_loop.last`

`True` если последняя итерация

`ansible_loop.length`

Количество элементов в цикле

`ansible_loop.previtem`

Элемент из предыдущей итерации цикла.Не определен во время первой итерации.

`ansible_loop.nextitem`

Элемент из следующей итерации петли.Неопределенный во время последней итерации.
```
loop_control:
  extended: yes
```
### Доступ к имени вашего loop_var

Новинка в версии 2.8.

Начиная с версии 2.8 вы можете получить имя значения, предоставленного для `loop_control.loop_var` , используя переменную `ansible_loop_var`

Для авторов ролей, пишущих роли, которые допускают циклы, вместо того, чтобы диктовать требуемое значение `loop_var` , вы можете собрать значение через:
```
"{{ lookup('vars', ansible\_loop\_var) }}"
```
Миграция из с_X в цикл
-----------------------

В большинстве случаев циклы лучше всего работают с ключевым словом `loop` вместо `with_X` стиле with\_X . `loop` синтаксис, как правило , лучше всего выражается с помощью фильтров вместо более сложного использования `query` или `lookup` .

Эти примеры показывают , как преобразовать много общего `with_` петли стиля для `loop` и фильтров.

### with_list

`with_list` напрямую заменяется `loop` .
```
- name: with_list
  ansible.builtin.debug:
    msg: "{{ item }}"
  with_list:
    - one
    - two

- name: with_list -> loop
  ansible.builtin.debug:
    msg: "{{ item }}"
  loop:
    - one
    - two
```
### with_items

`with_items` заменяется `loop` и фильтром `flatten` .
```
- name: with_items
  ansible.builtin.debug:
    msg: "{{ item }}"
  with_items: "{{ items }}"

- name: with_items -> loop
  ansible.builtin.debug:
    msg: "{{ item }}"
  loop: "{{ items|flatten(levels=1) }}"
```
### with_indexed_items

`with_indexed_items` заменяется на `loop` , на `flatten` фильтр и `loop_control.index_var` .
```
- name: with_indexed_items
  ansible.builtin.debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  with_indexed_items: "{{ items }}"

- name: with_indexed_items -> loop
  ansible.builtin.debug:
    msg: "{{ index }} - {{ item }}"
  loop: "{{ items|flatten(levels=1) }}"
  loop_control:
    index_var: index
```
### with\_flattened

`with_flattened` заменяется `loop` и фильтром `flatten` .
```
- name: with_flattened
  ansible.builtin.debug:
    msg: "{{ item }}"
  with_flattened: "{{ items }}"

- name: with_flattened -> loop
  ansible.builtin.debug:
    msg: "{{ item }}"
  loop: "{{ items|flatten }}"
```
### with_together

`with_together` заменяется `loop` и `zip` фильтром.
```
- name: with_together
  ansible.builtin.debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  with_together:
    - "{{ list_one }}"
    - "{{ list_two }}"

- name: with_together -> loop
  ansible.builtin.debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  loop: "{{ list_one|zip(list_two)|list }}"
```
Другой пример со сложными данными
```
- name: with_together -> loop
  ansible.builtin.debug:
    msg: "{{ item.0 }} - {{ item.1 }} - {{ item.2 }}"
  loop: "{{ data[0]|zip(*data[1:])|list }}"
  vars:
    data:
      - ['a', 'b', 'c']
      - ['d', 'e', 'f']
      - ['g', 'h', 'i']
```
### with_dict

`with_dict` может быть заменен `loop` и `dictsort` или `dict2items` .
```
- name: with_dict
  ansible.builtin.debug:
    msg: "{{ item.key }} - {{ item.value }}"
  with\_dict: "{{ dictionary }}"

- name: with_dict -> loop (option 1)
  ansible.builtin.debug:
    msg: "{{ item.key }} - {{ item.value }}"
  loop: "{{ dictionary|dict2items }}"

- name: with_dict -> loop (option 2)
  ansible.builtin.debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  loop: "{{ dictionary|dictsort }}"
```
### with_sequence

`with_sequence` заменяется `loop` и `range` функции, и , возможно, `format` фильтра.
```
- name: with_sequence
  ansible.builtin.debug:
    msg: "{{ item }}"
  with_sequence: start=0 end=4 stride=2 format=testuser%02x

- name: with_sequence -> loop
  ansible.builtin.debug:
    msg: "{{ 'testuser%02x' | format(item) }}"
  # диапазон не включает конечную точку
  loop: "{{ range(0, 4 + 1, 2)|list }}"
```
### with_subelements

`with_subelements` заменяется `loop` и фильтром `subelements` .
```
- name: with_subelements
  ansible.builtin.debug:
    msg: "{{ item.0.name }} - {{ item.1 }}"
  with_subelements:
    - "{{ users }}"
    - mysql.hosts

- name: with_subelements -> loop
  ansible.builtin.debug:
    msg: "{{ item.0.name }} - {{ item.1 }}"
  loop: "{{ users|subelements('mysql.hosts') }}"
```
### with_nested/with_cartesian

`with_nested` и `with_cartesian` заменяются циклом и фильтром `product` .
```
- name: with_nested
  ansible.builtin.debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  with_nested:
    - "{{ list_one }}"
    - "{{ list_two }}"

- name: with_nested -> loop
  ansible.builtin.debug:
    msg: "{{ item.0 }} - {{ item.1 }}"
  loop: "{{ list_one|product(list_two)|list }}"
```
### with_random_choice

`with_random_choice` заменяется просто использованием `random` фильтра, без необходимости `loop` .
```
- name: with_random_choice
  ansible.builtin.debug:
    msg: "{{ item }}"
  with_random_choice: "{{ my_list }}"

- name: with_random_choice -> loop (No loop is needed here)
  ansible.builtin.debug:
    msg: "{{ my_list|random }}"
  tags: random
```
