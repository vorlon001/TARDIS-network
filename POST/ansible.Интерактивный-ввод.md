Интерактивный ввод:подсказки
============================

Если вы хотите,чтобы ваш плейбук запрашивал у пользователя определенные данные,добавьте раздел 'vars\_prompt'.Запрос пользователю переменных позволяет избежать записи конфиденциальных данных,таких как пароли.Помимо безопасности,подсказки поддерживают гибкость.Например,если вы используете один плейбук для нескольких версий программного обеспечения,вы можете запросить конкретную версию выпуска.

*   [Шифрование значений, предоставляемых `vars_prompt`](#encrypting-values-supplied-by-vars-prompt)
*   [Разрешение специальных символов в значениях `vars_prompt`](#allowing-special-characters-in-vars-prompt-values)

Вот самый основной пример:
```
---
- hosts: all
  vars_prompt:

    - name: username
      prompt: What is your username?
      private: no

    - name: password
      prompt: What is your password?

  tasks:

    - name: Print a message
      ansible.builtin.debug:
        msg: 'Logging in as {{ username }}'
```
Пользовательский ввод скрыт по умолчанию, но его можно сделать видимым, установив `private: no` .
```
Note
```
Запросы для отдельных переменных `vars_prompt` будут пропущены для любой переменной, которая уже определена с помощью параметра командной строки `--extra-vars` или при запуске из неинтерактивного сеанса (например, cron или Ansible AWX). См [. Определение переменных во время выполнения](playbooks_variables?page=2#passing-variables-on-the-command-line) .

Если у вас есть переменная,которая изменяется нечасто,вы можете предоставить значение по умолчанию,которое можно переопределить:
```
vars_prompt:

  - name: release_version
    prompt: Product release version
    default: "1.0"
```
Шифрование значений, предоставляемых `vars_prompt`
--------------------------------------------------

Вы можете зашифровать введенное значение,чтобы использовать его,например,с модулем пользователя для определения пароля:
```
vars_prompt:

  - name: my_password2
    prompt: Enter password2
    private: yes
    encrypt: sha512_crypt
    confirm: yes
    salt_size: 7
```
Если у вас установлен [Passlib](https://passlib.readthedocs.io/en/stable/) , вы можете использовать любую схему шифрования , которую поддерживает библиотека:
```
*   _des\_crypt_ - DES Crypt
*   _bsdi\_crypt_ - BSDi Crypt
*   _BigCrypt_ - BigCrypt
*   _crypt16_ - Crypt16
*   _md5_crypt_ - MD5 Crypt
*   _bcrypt_ - BCrypt
*   _sha1_crypt_ - Склеп SHA-1
*   _sun_md5_crypt_ - Sun MD5 Crypt
*   _sha256_crypt_ - Склеп SHA-256
*   _sha512_crypt_ - Склеп SHA-512
*   _apr_md5_crypt_ — вариант Apache MD5-Crypt.
*   _phpass_ — портативный хэш PHPass
*   _pbkdf2_digest_ - Универсальные хэши PBKDF2
*   _cta_pbkdf2_sha1_ — хеш PBKDF2 Cryptacular
*   _dlitz_pbkdf2_sha1_ — хеш PBKDF2 Дуэйна Литценбергера
*   _Скрам_ - Храм Храм
*   _bsd_nthash_ — кодировка nthash, совместимая с MCF для FreeBSD.
```
Единственными принимаемыми параметрами являются 'salt' или 'salt\_size'.Вы можете использовать свою собственную соль,определив 'salt',или автоматически сгенерировать ее,используя 'salt\_size'.По умолчанию Ansible генерирует соль размером 8.

Новинка в версии 2.7.

Если у вас не установлен Passlib, Ansible использует библиотеку [crypt](https://docs.python.org/2/library/crypt.html) как запасной вариант. Ansible поддерживает не более четырех схем шифрования, в зависимости от вашей платформы поддерживаются не более следующих схем шифрования:
```
*   _bcrypt_ - BCrypt
*   _md5_crypt_ - MD5 Crypt
*   _sha256_crypt_ - Склеп SHA-256
*   _sha512_crypt_ - Склеп SHA-512
```
Новинка в версии 2.8.

Разрешение специальных символов в значениях `vars_prompt`
---------------------------------------------------------

Некоторые специальные символы, такие как `{` и `%` , могут создавать ошибки в шаблоне. Если вам нужно принимать специальные символы, используйте `unsafe` вариант:
```
vars_prompt:
  - name: my_password_with_weird_chars
    prompt: Enter password
    unsafe: yes
    private: yes
```
