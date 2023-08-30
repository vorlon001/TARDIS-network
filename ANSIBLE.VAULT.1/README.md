```shell


cat <<EOF>play.yml
---
- name: secret
  hosts: 127.0.0.1
  connection: local
  vars:
    my_secret: P@ssword123
  tasks:
    - name: Print secret
      debug:
         var: my_secret
EOF


ansible-playbook play.yml



```


```shell
pwd:123

ansible-vault encrypt_string 'P@ssword123' --name 'my_secret'

root@node4:/cloud/TEST.1/ANSIBLE# ansible-vault encrypt_string 'P@ssword123' --name 'my_secret'
New Vault password:
Confirm New Vault password:
my_secret: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66343963656266383237356562353332386231353834343031343935626264616266646331333737
          3037336430306562643137656365653732646461386232340a643838306665393765666132376565
          30393466396130356137383434303464653064373332356436333736353130373936336463323935
          3530323331316639310a633161323634623966306438386338366135303964663139653065303739
          6230
Encryption successful


ansible-playbook play.secret.yml  --ask-vault-pass
>> enter: 123


root@node4:/cloud/TEST.1/ANSIBLE# echo "123">pass.txt
root@node4:/cloud/TEST.1/ANSIBLE# ansible-playbook play.secret.yml  --vault-password-file $(pwd)/pass.txt
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost
does not match 'all'

PLAY [secret] ********************************************************************************************

TASK [Gathering Facts] ***********************************************************************************
ok: [127.0.0.1]

TASK [Print secret] **************************************************************************************
ok: [127.0.0.1] => {
    "my_secret": "P@ssword123"
}

PLAY RECAP ***********************************************************************************************
127.0.0.1                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0



cat <<EOF>play.secret.yml
---
- name: secret
  hosts: 127.0.0.1
  connection: local
  vars:
    my_secret: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66343963656266383237356562353332386231353834343031343935626264616266646331333737
          3037336430306562643137656365653732646461386232340a643838306665393765666132376565
          30393466396130356137383434303464653064373332356436333736353130373936336463323935
          3530323331316639310a633161323634623966306438386338366135303964663139653065303739
          6230

  tasks:
    - name: Print secret
      debug:
         var: my_secret
EOF


```


```shell

root@node4:/cloud/TEST.1/ANSIBLE# ansible-vault edit secret_file.yml
Vault password:

root@node4:/cloud/TEST.1/ANSIBLE# ansible-vault edit secret_file.yml
Vault password:
>>> PASSWORD:111
secret: "asdfasd"
secret2: 2345234234



 root@node4:/cloud/TEST.1/ANSIBLE# ansible-vault view secret_file.yml
Vault password: 111
secret: "asdfasd"
secret2: 2345234234


ansible-vault rekey secret_file.yml


```


```shell



cat <<EOF>play.secret.2.yml
---
- name: secret
  hosts: 127.0.0.1
  connection: local
  vars:
    my_secret: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66343963656266383237356562353332386231353834343031343935626264616266646331333737
          3037336430306562643137656365653732646461386232340a643838306665393765666132376565
          30393466396130356137383434303464653064373332356436333736353130373936336463323935
          3530323331316639310a633161323634623966306438386338366135303964663139653065303739
          6230

  tasks:
    - name: Print secret
      debug:
         var: my_secret
    - name: Print secret
      debug:
         var: secret
    - name: Print secret
      debug:
         var: secret2
EOF


ansible-playbook -e @secret_file.yml --ask-vault-pass play.secret.2.yml 

echo "123">pass.txt
ansible-playbook -e @secret_file.yml   --vault-password-file $(pwd)/pass.txt play.secret.2.yml

```
