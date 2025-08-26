# Домашнее задание к занятию 5 «Тестирование roles»

## Подготовка к выполнению

1. Установите molecule и его драйвера: `pip3 install "molecule molecule_docker molecule_podman`.
2. Выполните `docker pull aragast/netology:latest` —  это образ с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри.

## Основная часть

Ваша цель — настроить тестирование ваших ролей.

Задача — сделать сценарии тестирования для vector.

Ожидаемый результат — все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test -s ubuntu_xenial` (или с любым другим сценарием, не имеет значения) внутри корневой директории clickhouse-role, посмотрите на вывод команды. Данная команда может отработать с ошибками или не отработать вовсе, это нормально. Наша цель - посмотреть как другие в реальном мире используют молекулу И из чего может состоять сценарий тестирования.
2. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (oraclelinux:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
4. Добавьте несколько assert в verify.yml-файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска и др.).
5. Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.
---

# Выполнение задания

* [Vector role repository - Molecule tests version](https://github.com/DimOsSpb/ansible-role-vector/tree/Molecule)

## Замечания по ошибкам, исправлениям и ситуациям

- Тестирование роли требует на целевой системе установленных зависимостей для работы ansible. Не все образы имеют python3, sudo. По ссылке ниже приведены примеры решения этой задачи для molecule
  - [Инструкция по установке зависимостей через Customizing the Docker Image Used by a Scenario/Platform](https://ansible.readthedocs.io/projects/molecule/guides/custom-image/)
  - [Implementation in molecule docker driver](https://github.com/ansible/ansible/blob/devel/docs/docsite/rst/dev_guide/developing_modules_documenting.rst#testing-your-module)
  - [Буду работать по этому примеру - вариант из лекций](https://github.com/AlexeySetevoi/ansible-clickhouse/blob/master/molecule/resources/Dockerfile.j2)
  - [Пример с использованием подготовленных образов (как вариант более простой)](https://github.com/cloudalchemy/ansible-prometheus/blob/master/molecule/default/playbook.yml)
  - [RedOS](https://redos.red-soft.ru/base/redos-8_0/8_0-administation/8_0-containers/8_0-docker-install/#base)
      docker search --no-trunc registry.red-soft.ru/ubi8

 > **Используем эти инструкции для сборки образа с необходимыми зависимостями.**
- Работа с контейнерами требует учитывать, что например systemd может не работать в контейнерах...А oraclelinux:8 имеет старые версии python3...
- По этому проще и удобнее использовать готовые образы с необходимыми зависимостями.
---

## Вывод консолипо этапам проверки molecule:
---

- **Создание:**

```shell
odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector$ molecule create
WARNING  Driver docker does not provide a schema.
WARNING  Driver docker does not provide a schema.
INFO     default ➜ discovery: scenario test matrix: dependency, create, prepare
INFO     default ➜ prerun: Performing prerun with role_name_check=0...
INFO     default ➜ dependency: Starting
WARNING  default ➜ dependency: Skipping, missing the requirements file.
WARNING  default ➜ dependency: Skipping, missing the requirements file.
INFO     default ➜ dependency: Completed
INFO     default ➜ create: Starting
INFO     default ➜ create: ansible-playbook version: ansible-playbook
  config file = None
  configured module search path = ['/home/odv/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/odv/.pyenv/versions/3.12.9/lib/python3.12/site-packages/ansible
  ansible collection location = /home/odv/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/odv/.pyenv/versions/3.12.9/bin/ansible-playbook
  python version = 3.12.9 (main, Apr  3 2025, 17:05:56)  (/home/odv/.pyenv/versions/3.12.9/bin/python3.12)
  jinja version = 3.1.6
  libyaml = True
INFO     Sanity checks: 'docker'

PLAY [Create] ******************************************************************

TASK [Set async_dir for HOME env] **********************************************
ok: [localhost]

TASK [Log into a Docker registry] **********************************************
skipping: [localhost] => (item=None)
skipping: [localhost] => (item=None)
skipping: [localhost] => (item=None)
skipping: [localhost]

TASK [Check presence of custom Dockerfiles] ************************************
ok: [localhost] => (item={'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'image': 'debian:latest', 'name': 'debian', 'privileged': True, 'user': 'ansible'})
ok: [localhost] => (item={'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'environment': {'ANSIBLE_PYTHON_INTERPRETER': '/usr/bin/python3'}, 'image': 'registry.red-soft.ru/ubi8/python-311-minimal', 'name': 'redos', 'privileged': True, 'user': 'ansible'})
ok: [localhost] => (item={'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'image': 'oraclelinux:9', 'name': 'oracle', 'privileged': True, 'user': 'ansible'})

TASK [Create Dockerfiles from image names] *************************************
changed: [localhost] => (item={'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'image': 'debian:latest', 'name': 'debian', 'privileged': True, 'user': 'ansible'})
changed: [localhost] => (item={'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'environment': {'ANSIBLE_PYTHON_INTERPRETER': '/usr/bin/python3'}, 'image': 'registry.red-soft.ru/ubi8/python-311-minimal', 'name': 'redos', 'privileged': True, 'user': 'ansible'})
changed: [localhost] => (item={'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'image': 'oraclelinux:9', 'name': 'oracle', 'privileged': True, 'user': 'ansible'})

TASK [Synchronization the context] *********************************************
changed: [localhost] => (item={'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'image': 'debian:latest', 'name': 'debian', 'privileged': True, 'user': 'ansible'})
ok: [localhost] => (item=None)
ok: [localhost] => (item=None)
changed: [localhost]

TASK [Discover local Docker images] ********************************************
ok: [localhost] => (item=None)
ok: [localhost] => (item=None)
ok: [localhost] => (item=None)
ok: [localhost]

TASK [Build an Ansible compatible image (new)] *********************************
ok: [localhost] => (item=molecule_local/debian:latest)
ok: [localhost] => (item=molecule_local/registry.red-soft.ru/ubi8/python-311-minimal)
ok: [localhost] => (item=molecule_local/oraclelinux:9)

TASK [Create docker network(s)] ************************************************
skipping: [localhost]

TASK [Determine the CMD directives] ********************************************
ok: [localhost] => (item=None)
ok: [localhost] => (item=None)
ok: [localhost] => (item=None)
ok: [localhost]

TASK [Create molecule instance(s)] *********************************************
changed: [localhost] => (item=debian)
changed: [localhost] => (item=redos)
changed: [localhost] => (item=oracle)

TASK [Wait for instance(s) creation to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (300 retries left).
changed: [localhost] => (item=None)
changed: [localhost] => (item=None)
changed: [localhost] => (item=None)
changed: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=9    changed=4    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

INFO     default ➜ create: Completed
INFO     default ➜ prepare: Starting
WARNING  default ➜ prepare: Skipping, prepare playbook not configured.
INFO     default ➜ prepare: Completed
```

- **Установка роли:**

```shell
odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector$ molecule converge
WARNING  Driver docker does not provide a schema.
WARNING  Driver docker does not provide a schema.
INFO     default ➜ discovery: scenario test matrix: dependency, create, prepare, converge
INFO     default ➜ prerun: Performing prerun with role_name_check=0...
INFO     default ➜ dependency: Starting
WARNING  default ➜ dependency: Skipping, missing the requirements file.
WARNING  default ➜ dependency: Skipping, missing the requirements file.
INFO     default ➜ dependency: Completed
INFO     default ➜ create: Starting
WARNING  default ➜ create: Skipping, instances already created.
INFO     default ➜ create: Completed
INFO     default ➜ prepare: Starting
WARNING  default ➜ prepare: Skipping, prepare playbook not configured.
INFO     default ➜ prepare: Completed
INFO     default ➜ converge: Starting
INFO     default ➜ converge: ansible-playbook version: ansible-playbook
  config file = None
  configured module search path = ['/home/odv/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/odv/.pyenv/versions/3.12.9/lib/python3.12/site-packages/ansible
  ansible collection location = /home/odv/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/odv/.pyenv/versions/3.12.9/bin/ansible-playbook
  python version = 3.12.9 (main, Apr  3 2025, 17:05:56)  (/home/odv/.pyenv/versions/3.12.9/bin/python3.12)
  jinja version = 3.1.6
  libyaml = True
INFO     Sanity checks: 'docker'

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [redos]
ok: [oracle]
ok: [debian]

TASK [Include role] ************************************************************
included: ../../../vector for debian, oracle, redos

TASK [../../../vector : Show OS family] ****************************************
ok: [debian] => {
    "msg": "OS family detected: Debian"
}
ok: [oracle] => {
    "msg": "OS family detected: RedHat"
}
ok: [redos] => {
    "msg": "OS family detected: RED"
}

TASK [../../../vector : Download Vector DEB] ***********************************
skipping: [oracle]
skipping: [redos]
changed: [debian]

TASK [../../../vector : Install Vector DEB] ************************************
skipping: [oracle]
skipping: [redos]
changed: [debian]

TASK [../../../vector : Add Vector GPG key RHEL] *******************************
skipping: [debian]
changed: [oracle]
changed: [redos]

TASK [../../../vector : Install Vector on RHEL] ********************************
skipping: [debian]
changed: [oracle]
changed: [redos]

TASK [../../../vector : Vector config from template] ***************************
changed: [oracle]
changed: [debian]
changed: [redos]

TASK [../../../vector : Ensure test file exists] *******************************
changed: [debian]
changed: [oracle]
changed: [redos]

RUNNING HANDLER [../../../vector : Restart vector service] *********************
included: /home/odv/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector/tasks/restart_vector.yml for debian, oracle, redos

RUNNING HANDLER [../../../vector : Restart via systemd on VM] ******************
skipping: [debian]
skipping: [oracle]
skipping: [redos]

RUNNING HANDLER [../../../vector : Stop vector manually in Docker/container] ***
changed: [debian]
changed: [oracle]
changed: [redos]

RUNNING HANDLER [../../../vector : Start vector manually in Docker/container] ***
changed: [oracle]
changed: [redos]
changed: [debian]

PLAY RECAP *********************************************************************
debian                     : ok=10   changed=6    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
oracle                     : ok=10   changed=6    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
redos                      : ok=10   changed=6    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

INFO     default ➜ converge: Completed
```

- **Тестирование роли:**

```shell
odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector$ molecule verify
WARNING  Driver docker does not provide a schema.
WARNING  Driver docker does not provide a schema.
INFO     default ➜ discovery: scenario test matrix: verify
INFO     default ➜ prerun: Performing prerun with role_name_check=0...
INFO     default ➜ verify: Starting
INFO     default ➜ verify: Running Ansible Verifier
INFO     default ➜ verify: ansible-playbook version: ansible-playbook
  config file = /home/odv/.ansible/tmp/molecule.sNUc.default/ansible.cfg
  configured module search path = ['/home/odv/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/odv/.pyenv/versions/3.12.9/lib/python3.12/site-packages/ansible
  ansible collection location = /home/odv/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/odv/.pyenv/versions/3.12.9/bin/ansible-playbook
  python version = 3.12.9 (main, Apr  3 2025, 17:05:56)  (/home/odv/.pyenv/versions/3.12.9/bin/python3.12)
  jinja version = 3.1.6
  libyaml = True
INFO     Sanity checks: 'docker'

PLAY [Verify Vector Installation] **********************************************

TASK [Gather facts] ************************************************************
ok: [debian]
ok: [oracle]
ok: [redos]

TASK [Gather Installed Packages - NOT CONTAINERIZED] ***************************
skipping: [debian]
skipping: [oracle]
skipping: [redos]

TASK [Assert Vector Package Installed - NOT CONTAINERIZED] *********************
skipping: [debian]
skipping: [oracle]
skipping: [redos]

TASK [Check vector binary exists - CONTAINERIZED] ******************************
ok: [debian]
ok: [oracle]
ok: [redos]

TASK [Assert vector binary present - CONTAINERIZED] ****************************
ok: [debian] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [oracle] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [redos] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Gather Vector Config Files Stats] ****************************************
ok: [debian] => (item=/etc/vector/vector.yaml)
ok: [oracle] => (item=/etc/vector/vector.yaml)
ok: [redos] => (item=/etc/vector/vector.yaml)

TASK [Assert Vector Config Files Stats] ****************************************
ok: [debian] => (item={'changed': False, 'stat': {'exists': True, 'path': '/etc/vector/vector.yaml', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 203, 'inode': 24642160, 'dev': 72, 'nlink': 1, 'atime': 1756207162.09326, 'mtime': 1756207161.0656931, 'ctime': 1756207161.06127, 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False, 'blocks': 8, 'block_size': 4096, 'device_type': 0, 'readable': True, 'writeable': True, 'executable': False, 'pw_name': 'root', 'gr_name': 'root', 'checksum': 'f0edbbb7f613729837be7b1e9970fb85c8a31d37', 'mimetype': 'unknown', 'charset': 'unknown', 'version': None, 'attributes': [], 'attr_flags': ''}, 'invocation': {'module_args': {'path': '/etc/vector/vector.yaml', 'follow': False, 'get_checksum': True, 'get_mime': True, 'get_attributes': True, 'checksum_algorithm': 'sha1'}}, 'ansible_facts': {'discovered_interpreter_python': '/usr/bin/python3.13'}, 'failed': False, 'item': '/etc/vector/vector.yaml', 'ansible_loop_var': 'item'}) => {
    "ansible_loop_var": "item",
    "changed": false,
    "item": {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3.13"
        },
        "ansible_loop_var": "item",
        "changed": false,
        "failed": false,
        "invocation": {
            "module_args": {
                "checksum_algorithm": "sha1",
                "follow": false,
                "get_attributes": true,
                "get_checksum": true,
                "get_mime": true,
                "path": "/etc/vector/vector.yaml"
            }
        },
        "item": "/etc/vector/vector.yaml",
        "stat": {
            "atime": 1756207162.09326,
            "attr_flags": "",
            "attributes": [],
            "block_size": 4096,
            "blocks": 8,
            "charset": "unknown",
            "checksum": "f0edbbb7f613729837be7b1e9970fb85c8a31d37",
            "ctime": 1756207161.06127,
            "dev": 72,
            "device_type": 0,
            "executable": false,
            "exists": true,
            "gid": 0,
            "gr_name": "root",
            "inode": 24642160,
            "isblk": false,
            "ischr": false,
            "isdir": false,
            "isfifo": false,
            "isgid": false,
            "islnk": false,
            "isreg": true,
            "issock": false,
            "isuid": false,
            "mimetype": "unknown",
            "mode": "0644",
            "mtime": 1756207161.0656931,
            "nlink": 1,
            "path": "/etc/vector/vector.yaml",
            "pw_name": "root",
            "readable": true,
            "rgrp": true,
            "roth": true,
            "rusr": true,
            "size": 203,
            "uid": 0,
            "version": null,
            "wgrp": false,
            "woth": false,
            "writeable": true,
            "wusr": true,
            "xgrp": false,
            "xoth": false,
            "xusr": false
        }
    },
    "msg": "All assertions passed"
}
ok: [oracle] => (item={'changed': False, 'stat': {'exists': True, 'path': '/etc/vector/vector.yaml', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 203, 'inode': 24642223, 'dev': 86, 'nlink': 1, 'atime': 1756207162.0892599, 'mtime': 1756207161.0561662, 'ctime': 1756207161.05327, 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False, 'blocks': 8, 'block_size': 4096, 'device_type': 0, 'readable': True, 'writeable': True, 'executable': False, 'pw_name': 'root', 'gr_name': 'root', 'checksum': 'f0edbbb7f613729837be7b1e9970fb85c8a31d37', 'mimetype': 'unknown', 'charset': 'unknown', 'version': None, 'attributes': [], 'attr_flags': ''}, 'invocation': {'module_args': {'path': '/etc/vector/vector.yaml', 'follow': False, 'get_checksum': True, 'get_mime': True, 'get_attributes': True, 'checksum_algorithm': 'sha1'}}, 'ansible_facts': {'discovered_interpreter_python': '/usr/bin/python3.9'}, 'failed': False, 'item': '/etc/vector/vector.yaml', 'ansible_loop_var': 'item'}) => {
    "ansible_loop_var": "item",
    "changed": false,
    "item": {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python3.9"
        },
        "ansible_loop_var": "item",
        "changed": false,
        "failed": false,
        "invocation": {
            "module_args": {
                "checksum_algorithm": "sha1",
                "follow": false,
                "get_attributes": true,
                "get_checksum": true,
                "get_mime": true,
                "path": "/etc/vector/vector.yaml"
            }
        },
        "item": "/etc/vector/vector.yaml",
        "stat": {
            "atime": 1756207162.0892599,
            "attr_flags": "",
            "attributes": [],
            "block_size": 4096,
            "blocks": 8,
            "charset": "unknown",
            "checksum": "f0edbbb7f613729837be7b1e9970fb85c8a31d37",
            "ctime": 1756207161.05327,
            "dev": 86,
            "device_type": 0,
            "executable": false,
            "exists": true,
            "gid": 0,
            "gr_name": "root",
            "inode": 24642223,
            "isblk": false,
            "ischr": false,
            "isdir": false,
            "isfifo": false,
            "isgid": false,
            "islnk": false,
            "isreg": true,
            "issock": false,
            "isuid": false,
            "mimetype": "unknown",
            "mode": "0644",
            "mtime": 1756207161.0561662,
            "nlink": 1,
            "path": "/etc/vector/vector.yaml",
            "pw_name": "root",
            "readable": true,
            "rgrp": true,
            "roth": true,
            "rusr": true,
            "size": 203,
            "uid": 0,
            "version": null,
            "wgrp": false,
            "woth": false,
            "writeable": true,
            "wusr": true,
            "xgrp": false,
            "xoth": false,
            "xusr": false
        }
    },
    "msg": "All assertions passed"
}
ok: [redos] => (item={'changed': False, 'stat': {'exists': True, 'path': '/etc/vector/vector.yaml', 'mode': '0644', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 0, 'gid': 0, 'size': 203, 'inode': 24642283, 'dev': 83, 'nlink': 1, 'atime': 1756207162.1092598, 'mtime': 1756207161.063978, 'ctime': 1756207161.06127, 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': True, 'xgrp': False, 'woth': False, 'roth': True, 'xoth': False, 'isuid': False, 'isgid': False, 'blocks': 8, 'block_size': 4096, 'device_type': 0, 'readable': True, 'writeable': True, 'executable': False, 'pw_name': 'root', 'gr_name': 'root', 'checksum': 'f0edbbb7f613729837be7b1e9970fb85c8a31d37', 'mimetype': 'text/plain', 'charset': 'us-ascii', 'version': None, 'attributes': [], 'attr_flags': ''}, 'invocation': {'module_args': {'path': '/etc/vector/vector.yaml', 'follow': False, 'get_checksum': True, 'get_mime': True, 'get_attributes': True, 'checksum_algorithm': 'sha1'}}, 'ansible_facts': {'discovered_interpreter_python': '/opt/app-root/bin/python3.11'}, 'failed': False, 'item': '/etc/vector/vector.yaml', 'ansible_loop_var': 'item'}) => {
    "ansible_loop_var": "item",
    "changed": false,
    "item": {
        "ansible_facts": {
            "discovered_interpreter_python": "/opt/app-root/bin/python3.11"
        },
        "ansible_loop_var": "item",
        "changed": false,
        "failed": false,
        "invocation": {
            "module_args": {
                "checksum_algorithm": "sha1",
                "follow": false,
                "get_attributes": true,
                "get_checksum": true,
                "get_mime": true,
                "path": "/etc/vector/vector.yaml"
            }
        },
        "item": "/etc/vector/vector.yaml",
        "stat": {
            "atime": 1756207162.1092598,
            "attr_flags": "",
            "attributes": [],
            "block_size": 4096,
            "blocks": 8,
            "charset": "us-ascii",
            "checksum": "f0edbbb7f613729837be7b1e9970fb85c8a31d37",
            "ctime": 1756207161.06127,
            "dev": 83,
            "device_type": 0,
            "executable": false,
            "exists": true,
            "gid": 0,
            "gr_name": "root",
            "inode": 24642283,
            "isblk": false,
            "ischr": false,
            "isdir": false,
            "isfifo": false,
            "isgid": false,
            "islnk": false,
            "isreg": true,
            "issock": false,
            "isuid": false,
            "mimetype": "text/plain",
            "mode": "0644",
            "mtime": 1756207161.063978,
            "nlink": 1,
            "path": "/etc/vector/vector.yaml",
            "pw_name": "root",
            "readable": true,
            "rgrp": true,
            "roth": true,
            "rusr": true,
            "size": 203,
            "uid": 0,
            "version": null,
            "wgrp": false,
            "woth": false,
            "writeable": true,
            "wusr": true,
            "xgrp": false,
            "xoth": false,
            "xusr": false
        }
    },
    "msg": "All assertions passed"
}

TASK [Gather Local Services - NOT CONTAINERIZED] *******************************
skipping: [debian]
skipping: [oracle]
skipping: [redos]

TASK [Assert Vector Service - NOT CONTAINERIZED] *******************************
skipping: [debian]
skipping: [oracle]
skipping: [redos]

TASK [Check vector process running - CONTAINERIZED] ****************************
ok: [debian]
ok: [oracle]
ok: [redos]

TASK [Check that Vector port is open] ******************************************
ok: [oracle]
ok: [debian]
ok: [redos]

PLAY RECAP *********************************************************************
debian                     : ok=7    changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
oracle                     : ok=7    changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
redos                      : ok=7    changed=0    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

INFO     default ➜ verify: Verifier completed successfully.
INFO     default ➜ verify: Completed
```

* [Vector role repository - Molecule tests version](https://github.com/DimOsSpb/ansible-role-vector/tree/Molecule)


### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./example).
2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`, где path_to_repo — путь до корня репозитория с vector-role на вашей файловой системе.
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.

```
docker run --privileged=True -v /home/odv/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`
```
- Падает по ошибке, понятно почему - у меня нет сценария molecule **compatibility**. И даже если пропишу в tox.ini свой - не поедет, т.к. драйвер docker.
```
sudo apt install -y podman
```

5. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.

```
odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector$ molecule init scenario --driver-name podman podman_light
WARNING  default ➜ config: Driver 'docker' is currently in use but the scenario config has changed and now defines 'default'. To change drivers, run 'molecule destroy' for converged scenarios or 'molecule reset' otherwise.
WARNING  default ➜ config: Driver 'docker' is currently in use but the scenario config has changed and now defines 'default'. To change drivers, run 'molecule destroy' for converged scenarios or 'molecule reset' otherwise.
INFO     podman_light ➜ init: Initializing new scenario podman_light...

PLAY [Create a new molecule scenario] ******************************************

TASK [Check if destination folder exists] **************************************
changed: [localhost]

TASK [Check if destination folder is empty] ************************************
ok: [localhost]

TASK [Fail if destination folder is not empty] *********************************
skipping: [localhost]

TASK [Expand templates] ********************************************************
changed: [localhost] => (item=molecule/podman_light/converge.yml)
skipping: [localhost] => (item=molecule/podman_light/create.yml)
changed: [localhost] => (item=molecule/podman_light/molecule.yml)
skipping: [localhost] => (item=molecule/podman_light/destroy.yml)

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     podman_light ➜ init: Initialized scenario in /home/odv/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector/molecule/podman_light successfully.
```

```
odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector$ molecule create -s podman_light
WARNING  Driver podman does not provide a schema.
WARNING  Driver docker does not provide a schema.
INFO     podman_light ➜ discovery: scenario test matrix: dependency, create, prepare
INFO     podman_light ➜ prerun: Performing prerun with role_name_check=0...
INFO     podman_light ➜ dependency: Starting
WARNING  podman_light ➜ dependency: Skipping, missing the requirements file.
WARNING  podman_light ➜ dependency: Skipping, missing the requirements file.
INFO     podman_light ➜ dependency: Completed
INFO     podman_light ➜ create: Starting
INFO     podman_light ➜ create: ansible-playbook version: ansible-playbook
  config file = None
  configured module search path = ['/home/odv/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/odv/.pyenv/versions/3.12.9/lib/python3.12/site-packages/ansible
  ansible collection location = /home/odv/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/odv/.pyenv/versions/3.12.9/bin/ansible-playbook
  python version = 3.12.9 (main, Apr  3 2025, 17:05:56)  (/home/odv/.pyenv/versions/3.12.9/bin/python3.12)
  jinja version = 3.1.6
  libyaml = True
INFO     Sanity checks: 'podman'

PLAY [Create] ******************************************************************

TASK [get podman executable path] **********************************************
ok: [localhost]

TASK [save path to executable as fact] *****************************************
ok: [localhost]

TASK [Set async_dir for HOME env] **********************************************
ok: [localhost]

TASK [Log into a container registry] *******************************************
skipping: [localhost] => (item="redos registry username: None specified")
skipping: [localhost]

TASK [Check presence of custom Dockerfiles] ************************************
ok: [localhost] => (item=Dockerfile: ../resources/Dockerfile-rom.j2)

TASK [Create Dockerfiles from image names] *************************************
changed: [localhost] => (item="Dockerfile: ../resources/Dockerfile-rom.j2; Image: registry.red-soft.ru/ubi8/ubi")

TASK [Discover local Podman images] ********************************************
ok: [localhost] => (item=redos)

TASK [Build an Ansible compatible image] ***************************************
changed: [localhost] => (item=registry.red-soft.ru/ubi8/ubi)

TASK [Determine the CMD directives] ********************************************
ok: [localhost] => (item="redos command: /usr/sbin/init")

TASK [Remove possible pre-existing containers] *********************************
changed: [localhost]

TASK [Discover local podman networks] ******************************************
skipping: [localhost] => (item=redos: None specified)
skipping: [localhost]

TASK [Create podman network dedicated to this scenario] ************************
skipping: [localhost]

TASK [Create molecule instance(s)] *********************************************
changed: [localhost] => (item=redos)

TASK [Wait for instance(s) creation to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (300 retries left).
changed: [localhost] => (item=redos)

PLAY RECAP *********************************************************************
localhost                  : ok=11   changed=5    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

INFO     podman_light ➜ create: Completed
INFO     podman_light ➜ prepare: Starting
WARNING  podman_light ➜ prepare: Skipping, prepare playbook not configured.
INFO     podman_light ➜ prepare: Completed
odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector$ molecule converge -s podman_light
WARNING  Driver podman does not provide a schema.
WARNING  Driver docker does not provide a schema.
INFO     podman_light ➜ discovery: scenario test matrix: dependency, create, prepare, converge
INFO     podman_light ➜ prerun: Performing prerun with role_name_check=0...
INFO     podman_light ➜ dependency: Starting
WARNING  podman_light ➜ dependency: Skipping, missing the requirements file.
WARNING  podman_light ➜ dependency: Skipping, missing the requirements file.
INFO     podman_light ➜ dependency: Completed
INFO     podman_light ➜ create: Starting
WARNING  podman_light ➜ create: Skipping, instances already created.
INFO     podman_light ➜ create: Completed
INFO     podman_light ➜ prepare: Starting
WARNING  podman_light ➜ prepare: Skipping, prepare playbook not configured.
INFO     podman_light ➜ prepare: Completed
INFO     podman_light ➜ converge: Starting
INFO     podman_light ➜ converge: ansible-playbook version: ansible-playbook
  config file = None
  configured module search path = ['/home/odv/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/odv/.pyenv/versions/3.12.9/lib/python3.12/site-packages/ansible
  ansible collection location = /home/odv/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/odv/.pyenv/versions/3.12.9/bin/ansible-playbook
  python version = 3.12.9 (main, Apr  3 2025, 17:05:56)  (/home/odv/.pyenv/versions/3.12.9/bin/python3.12)
  jinja version = 3.1.6
  libyaml = True
INFO     Sanity checks: 'podman'

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [redos]

TASK [Include role] ************************************************************
included: ../../../vector for redos

TASK [../../../vector : Show OS family] ****************************************
ok: [redos] => {
    "msg": "OS family detected: RED"
}

TASK [../../../vector : Download Vector DEB] ***********************************
skipping: [redos]

TASK [../../../vector : Install Vector DEB] ************************************
skipping: [redos]

TASK [../../../vector : Add Vector GPG key RHEL] *******************************
changed: [redos]

TASK [../../../vector : Install Vector on RHEL] ********************************
changed: [redos]

TASK [../../../vector : Vector config from template] ***************************
changed: [redos]

RUNNING HANDLER [../../../vector : Restart vector service] *********************
included: /home/odv/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector/tasks/restart_vector.yml for redos

RUNNING HANDLER [../../../vector : Restart via systemd on VM] ******************
skipping: [redos]

RUNNING HANDLER [../../../vector : Stop vector manually in Docker/container] ***
changed: [redos]

RUNNING HANDLER [../../../vector : Start vector manually in Docker/container] ***
changed: [redos]

PLAY RECAP *********************************************************************
redos                      : ok=9    changed=5    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

INFO     podman_light ➜ converge: Completed
```

6. Пропишите правильную команду в `tox.ini`, чтобы запускался облегчённый сценарий.
8. Запустите команду `tox`. Убедитесь, что всё отработало успешно.

```
python3 -m pip install --user tox
```
- [Tox](https://tox.wiki/en/latest/user_guide.html)
- Задача иметь один проект, который можно тестировать на нескольких версиях Python и нескольких версиях Ansible. Для начала нам надо установить сам Tox на мой компьютер.
  У нас в tox.ini несколько версий Ansible, и они зависят от Python-окружения

  tox-requirements.txt = общие зависимости

  tox.ini = специфичные версии (Python/Ansible)

  pyenv versions - Покажет установленные версии Python

  В одном виртуальном окружении (venv) может быть только одна версия Ansible

  ansible --version

  [ansible-core versions table](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-core-support-matrix)

  Для понимания среды, схема того, как версии Python и Ansible могут сосуществовать:

      Система (system)
      ├─ Python 3.11
      │  └─ Пакеты: базовые (pip, setuptools…)
      ├─ Python 3.12
      │  └─ Пакеты: базовые (pip, setuptools…)
      └─ Ansible (если установлен в system-wide) → версия 2.10

      Виртуальные окружения (venv)
      ├─ venv-ansible210
      │  ├─ Python: 3.11
      │  └─ Ansible: 2.10
      ├─ venv-ansible218
      │  ├─ Python: 3.12
      │  └─ Ansible: 2.18
      └─ venv-ansible30
        ├─ Python: 3.12
        └─ Ansible: 3.0


## tox.ini

- Т.о. Смотрим какой пайтон есть в системе (pyenv versions), ставим если нет но нужен (pyenv install -s x.x.x)
- По таблице выбираем подходящий ansible [ansible-core versions table](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-core-support-matrix)
- Согласно этим соответсвиям формируем envlist
- Зависимости и соответствия версий ansible в deps
   - Замечание - начиная с Ansible 2.10 проект разделили:
      - ansible-core → ядро, версии 2.11, 2.12, 2.14, 2.15, 2.16, 2.17 и т. д.
      - ansible → метапакет, начиная с 5.x. У него версия ≠ ansible-core, а мажорная:
      - ansible==7.* → тянет ansible-core==2.14.*
      - ansible==8.* → тянет ansible-core==2.15.*

- Для версий python в глобальном PATH системы должен быть путь до папки с python версии. Настройка через basepython
- Пример установки пакета ansible версию которого не находит pip для tox. Переключиться на совместимый python (должен быть в системе) и установить пакет:
```shell
pyenv global 3.9.20
python -m pip install "ansible-core==2.15.*"
```
- **Успешный тест**

```shell
odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/05/src/playbook/roles/vector$ tox
py310-ansible214: install_deps> python -I -m pip install 'ansible-core==2.14.*' -r tox-requirements.txt
py310-ansible214: commands[0]> molecule test -s podman_light --destroy always
WARNING  Driver podman does not provide a schema.
INFO     podman_light scenario test matrix: dependency, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun with role_name_check=0...
INFO     Running podman_light > dependenc

-.-.-.-.-.-.-.-

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
  py311-ansible218: OK (101.41=setup[0.04]+cmd[101.37] seconds)
  py312-ansible218: OK (102.95=setup[0.01]+cmd[102.94] seconds)
  py310-ansible214: OK (25.92=setup[0.01]+cmd[25.91] seconds)
  py310-ansible215: OK (26.54=setup[0.01]+cmd[26.53] seconds)
  congratulations :) (256.88 seconds)
```

9. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в репозитории. Не забудьте указать в ответе теги решений Tox и Molecule заданий. В качестве решения пришлите ссылку на  ваш репозиторий и скриншоты этапов выполнения задания.

## Необязательная часть - возможно позже для полноценного стека

1. Проделайте схожие манипуляции для создания роли LightHouse.
2. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
3. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
4. Выложите свои roles в репозитории.
