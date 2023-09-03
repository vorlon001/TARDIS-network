
I have a heterogenous set of hosts and a mix of different roles that I want to apply to each host.
Using groups would mean creating a group for nearly every role, which felt like overkill.

This combination of a playbook and two task scripts runs the roles specified in the host's `required_roles`
variable, in order. It supports a tag named after the role, to run the specific role, and a tag `role-partial` to activate the role but to require other tags to activate specific tasks in the role (helpful when debugging roles).


```
---
- name: 'Run required role: {{ item }}'
  include_role:
    name: '{{ item }}'
    apply:
      tags:
        # Apply the role's tag to all tasks in this role so they all run
        - '{{ item }}'
  # Only run this role if the role's tag is present (or no tags are present)
  tags:
    - '{{ item }}'
    # A role-partial will activate the role, but other tags are required to choose the tasks in the role
    - '{{ item }}-partial'
```

```
---
# Iterate over the `required_roles` array of role names and run each one.
- name: Run required roles
  include_tasks: ./run-required-role.yml
  loop: '{{ required_roles }}'
  when: required_roles is defined
  tags:
    - always
```

```
- name: Run required roles
  hosts: all
  become: yes
  tasks:
    - include_tasks: ./required-roles.yml
      tags:
        - always
      # Note that it is key that the tag is applied on the task not on the play
      # as tags applied on a play apply to all tasks in the play regardless of
      # whether they're a dynamic import.
      # It is also key that we use include_tasks so that the always tag is not
      # inherited.
```

