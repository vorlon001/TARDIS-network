-- https://technekey.com/how-to-write-a-simple-callback-plugin-for-ansible/

How to write a simple callback plugin for ansible
=================================================

[Leave a Comment](https://technekey.com/how-to-write-a-simple-callback-plugin-for-ansible/#respond) / [tech](https://technekey.com/category/tech/)

This post will provide an example and explain how to write a simple callback plugin for ansible. Although ansible comes with multiple callback plugins out of the box, we can write our own callback plugin for extended customization for our requirements.

### What is a callback plugin?

A callback plugin is a chunk of [independent pieces of code](https://en.wikipedia.org/wiki/Callback_(computer_programming)) that will be called during the various stages(explained later) of playbook execution. To understand this better, let’s take an example of a sample playbook. The following playbook consists of two plays. The first play is targeted to `localhost`, Whereas 2nd play is targeted to “`webservers`” hosts.

    ---
    - name: This is play-1
      hosts: localhost
      tasks:
      - name: "This is 1st task of play-1"
        debug:
          msg: "This message is printed by 1st task of 1st play"
    
      - name: "This is 2nd task of play-1"
        debug:
          msg: "This message is printed by 2nd task of 1st play"
    
    - name: This is play-2
      hosts: webservers
      tasks:
      - name: "This is 1st task of play-2"
        debug:
          msg: "This message is printed by 1st task of 2nd play"
    
      - name: "This is 2nd task of play-2"
        debug:
          msg: "This message is printed by 2nd task of 2nd play"
    
      - name: "This is 3rd task of play-2"
        debug:
          msg: "This message is printed by 3rd task of 2nd play"
    

  
When the above playbook is executed with the default strategy, the flow of the playbook execution will be from top to bottom. The ansible core code is super intelligent in understanding the playbook execution lifecycle. During the playbook execution, when the execution flow reaches any of the stages, like the start/stop of the playbook, a task, etc., the playbook will take a pause and look for any callback code(**called runner functions**) that is supplied by the user for execution. The ad-hoc code supplied in the callback function will get executed, and then the playbook execution flow will move to the following stages.

![](https://raw.githubusercontent.com/vorlon001/TARDIS-network/main/IMAGES/callback.drawio.png.webp)

### How to find all the playbook execution stages and runners functions?

We can check the list of all stages in this URL [https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/callback/init.py](https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/callback/init.py).  
**Or** you can get the same file locally at /usr/local/lib/python3.10/dist-packages/ansible/plugins/callback/__**init__**.py; make sure you use the correct python version as per your installation environment.  
  
Here is a list of runner functions when writing this post, meaning you can plug in your custom code during any stage of playbook execution.

        def runner_on_failed(self, host, res, ignore_errors=False):
        def runner_on_ok(self, host, res):
        def runner_on_skipped(self, host, item=None):
        def runner_on_unreachable(self, host, res):
        def runner_on_no_hosts(self):
        def runner_on_async_poll(self, host, res, jid, clock):
        def runner_on_async_ok(self, host, res, jid):
        def runner_on_async_failed(self, host, res, jid):
        def playbook_on_start(self):
        def playbook_on_notify(self, host, handler):
        def playbook_on_no_hosts_matched(self):
        def playbook_on_no_hosts_remaining(self):
        def playbook_on_task_start(self, name, is_conditional):
        def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None, unsafe=None):
        def playbook_on_setup(self):
        def playbook_on_import_for_host(self, host, imported_file):
        def playbook_on_not_import_for_host(self, host, missing_file):
        def playbook_on_play_start(self, name):
        def playbook_on_stats(self, stats):
        def on_file_diff(self, host, diff):
        def v2_on_any(self, *args, **kwargs):
        def v2_runner_on_failed(self, result, ignore_errors=False):
        def v2_runner_on_ok(self, result):
        def v2_runner_on_skipped(self, result):
        def v2_runner_on_unreachable(self, result):
        def v2_runner_on_async_poll(self, result):
        def v2_runner_on_async_ok(self, result):
        def v2_runner_on_async_failed(self, result):
        def v2_playbook_on_start(self, playbook):
        def v2_playbook_on_notify(self, handler, host):
        def v2_playbook_on_no_hosts_matched(self):
        def v2_playbook_on_no_hosts_remaining(self):
        def v2_playbook_on_task_start(self, task, is_conditional):
        def v2_playbook_on_cleanup_task_start(self, task):
        def v2_playbook_on_handler_task_start(self, task):
        def v2_playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None, unsafe=None):
        def v2_playbook_on_import_for_host(self, result, imported_file):
        def v2_playbook_on_not_import_for_host(self, result, missing_file):
        def v2_playbook_on_play_start(self, play):
        def v2_playbook_on_stats(self, stats):
        def v2_on_file_diff(self, result):
        def v2_playbook_on_include(self, included_file):
        def v2_runner_item_on_ok(self, result):
        def v2_runner_item_on_failed(self, result):
        def v2_runner_item_on_skipped(self, result):
        def v2_runner_retry(self, result):
        def v2_runner_on_start(self, host, task):

### Writing own callback plugin

Here is an example of the most straightforward callback plugin; I am printing a message at the start of the playbook execution. Once you know all the runner functions supported by ansible, as seen in previous steps, you can do anything you want with this! But before you use it, you must place your callback plugin in a specific directory called ‘callback_plugins’ at the same level as your playbook. (perhaps softlink it if you have multiple playbooks using the same callback).  
  
For example, my playbook name is foo.yml, so at the same level as foo.yml, I will create a directory called.’`callback_plugins`‘ and place my callback code(shown later in the post) inside this directory.

    .
    |-- callback_plugins
    |   |-- technekey_callback.py
    `-- foo.yml
    
    1 directory, 2 files
    

  
Example of simplest callback plugin:

    from __future__ import (absolute_import, division, print_function)
    __metaclass__ = type
    
    
    from ansible.plugins.callback import CallbackBase
    from ansible import constants as C
    from ansible.utils.color import colorize, hostcolor
    from ansible.utils.display import Display
    
    DOCUMENTATION = '''
        callback: verbose_retry
        type: stdout
        short_description: 
          1. Print the stdout and stderr during until/delay/retries
          2. Print the results during the loop for each item
        description:
          - During the retry of any task, by default the task stdout and stderr are hidden from the user on the terminal.
          - To make things more transparent, we are printing the stdout and stderr to the terminal. 
        requirements:
          - python subprocess,datetime,pprint
        '''
    
    
    
    class CallbackModule(CallbackBase):
    
        '''
        Call all the runner functions here
        '''
    
        CALLBACK_VERSION = 2.0                          # you should use version 2.0 at the time of wrtiting this post
        CALLBACK_TYPE = 'notification'                  # you can only use 1 stdout plugin at a time, so used notification
        CALLBACK_NAME = 'loop_and_retry_verbose'        # name it anything, it probably does not matter.
    
        def __init__(self, *args, **kwargs):
            super(CallbackModule, self).__init__()
    
    
        ##
        ## Start writing runner functions here as per the playbook 
        ## lifecycle
    
        def v2_playbook_on_start(self, playbook):
            self._display.display("Hello, The playbook is started",color=C.COLOR_OK)
    

  
Here is the output of the playbook:

    ansible-playbook  foo.yml -i my_invenetory.yml
    
    Hello, The playbook is started
    
    PLAY [This is play-1] **************************************************************************************************************************************************************************************
    
    TASK [Gathering Facts] *************************************************************************************************************************************************************************************
    ok: [localhost]
    
    TASK [This is 1st task of play-1] **************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": "This message is printed by 1st task of 1st play"
    }
    
    TASK [This is 2nd task of play-1] **************************************************************************************************************************************************************************
    ok: [webservers] => {
        "msg": "This message is printed by 2nd task of 1st play"
    }
    
    PLAY [This is play-2] **************************************************************************************************************************************************************************************
    
    TASK [Gathering Facts] *************************************************************************************************************************************************************************************
    ok: [webservers]
    
    TASK [This is 1st task of play-2] **************************************************************************************************************************************************************************
    ok: [webservers] => {
        "msg": "This message is printed by 1st task of 2nd play"
    }
    
    TASK [This is 2nd task of play-2] **************************************************************************************************************************************************************************
    ok: [webservers] => {
        "msg": "This message is printed by 2nd task of 2nd play"
    }
    
    TASK [This is 3rd task of play-2] **************************************************************************************************************************************************************************
    ok: [webservers] => {
        "msg": "This message is printed by 3rd task of 2nd play"
    }
    
    PLAY RECAP *************************************************************************************************************************************************************************************************
    localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    
    rescued=0    ignored=0   
    localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    
    rescued=0    ignored=0   
    
    
    

### Writing a more advanced plugin

You can copy a more advanced callback plugin from one of my other projects https://raw.githubusercontent.com/technekey/ha-kubernetes-cluster/master/common/callback\_plugin/technekey\_callback.py.  
Now, I will run the same playbook with my new plugin.

    cd callback_plugins/
    wget https://raw.githubusercontent.com/technekey/ha-kubernetes-cluster/master/common/callback_plugin/technekey_callback.py

  
**Here is the newly updated output; notice the fancy summary, timestamps, and execution duration for all the tasks.**

    ansible-playbook  foo.yml -i my_inventory.yml
    
    PLAY [This is play-1] **************************************************************************************************************************************************************************************
    
    TASK [Gathering Facts] *************************************************************************************************************************************************************************************
                                                                                                                                                                                      [Tue Nov  1 11:35:58 2022]
    ok: [localhost]
    
    TASK [This is 1st task of play-1] **************************************************************************************************************************************************************************
                                                                                                                                                                                      [Tue Nov  1 11:35:59 2022]
    ok: [localhost] => {
        "msg": "This message is printed by 1st task of 1st play"
    }
    
    TASK [This is 2nd task of play-1] **************************************************************************************************************************************************************************
                                                                                                                                                                                      [Tue Nov  1 11:35:59 2022]
    ok: [webservers] => {
        "msg": "This message is printed by 2nd task of 1st play"
    }
    
    PLAY [This is play-2] **************************************************************************************************************************************************************************************
    
    TASK [Gathering Facts] *************************************************************************************************************************************************************************************
                                                                                                                                                                                      [Tue Nov  1 11:35:59 2022]
    ok: [webservers]
    
    TASK [This is 1st task of play-2] **************************************************************************************************************************************************************************
                                                                                                                                                                                      [Tue Nov  1 11:36:00 2022]
    ok: [webservers] => {
        "msg": "This message is printed by 1st task of 2nd play"
    }
    
    TASK [This is 2nd task of play-2] **************************************************************************************************************************************************************************
                                                                                                                                                                                      [Tue Nov  1 11:36:00 2022]
    ok: [webservers] => {
        "msg": "This message is printed by 2nd task of 2nd play"
    }
    
    TASK [This is 3rd task of play-2] **************************************************************************************************************************************************************************
                                                                                                                                                                                      [Tue Nov  1 11:36:00 2022]
    ok: [webservers] => {
        "msg": "This message is printed by 3rd task of 2nd play"
    }
    
    PLAY RECAP *************************************************************************************************************************************************************************************************
    localhost                  : ok=7    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    
    [localhost]
    11:35:58 Gathering Facts                                                                                Passed       0.85s
    11:35:59 This is 1st task of play-1                                                                     Passed       0.01s
    11:35:59 This is 2nd task of play-1                                                                     Passed       0.01s
    [webservers]
    11:35:59 Gathering Facts                                                                                Passed       0.66s
    11:36:00 This is 1st task of play-2                                                                     Passed       0.01s
    11:36:00 This is 2nd task of play-2                                                                     Passed       0.01s
    11:36:00 This is 3rd task of play-2                                                                     Passed       0.00s
    

### Summary:

The idea of this post is to showcase how you can use a callback plugin to customize the output of any task as per your requirements. I hope these examples provide you with a starting point with callback plugins.

#### Reference:

* https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/callback/**init**.py
* https://docs.ansible.com/ansible/latest/plugins/callback.html
* https://docs.ansible.com/ansible/2.4/dev\_guide/developing\_plugins.html#developing-callback-plugins (**Here another good example)**
