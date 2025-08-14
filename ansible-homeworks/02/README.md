# Домашнее задание к занятию 2 «Работа с Playbook»

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Подготовьте свой inventory-файл `prod.yml`.

    - Установил два узла на yandex cloude через terraform [src/tf](src/ft) clickhouse & vector

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install). не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

    ```shell
    odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/02$ ansible-lint playbook/site.yml 
    `WARNING  Listing 10 violation(s) that are fatal
    name[missing]: All tasks should be named.
    playbook/site.yml:12 Task/Handler: block/always/rescue 

    risky-file-permissions: File permissions unset or incorrect.
    playbook/site.yml:13 Task/Handler: Get clickhouse distrib

    yaml[indentation]: Wrong indentation: expected 8 but found 6
    playbook/site.yml:13

    fqcn[action-core]: Use FQCN for builtin module actions (meta).
    playbook/site.yml:35 Use `ansible.builtin.meta` or `ansible.legacy.meta` instead.

    jinja[spacing]: Jinja2 spacing could be improved: create_db.rc != 0 and create_db.rc !=82 -> create_db.rc != 0 and create_db.rc != 82 (warning)
    playbook/site.yml:45 Jinja2 template rewrite recommendation: `create_db.rc != 0 and create_db.rc != 82`.

    name[missing]: All tasks should be named.
    playbook/site.yml:61 Task/Handler: block/always/rescue 

    risky-file-permissions: File permissions unset or incorrect.
    playbook/site.yml:62 Task/Handler: Download Vector package

    yaml[indentation]: Wrong indentation: expected 8 but found 6
    playbook/site.yml:62

    yaml[trailing-spaces]: Trailing spaces
    playbook/site.yml:66

    fqcn[action-core]: Use FQCN for builtin module actions (meta).
    playbook/site.yml:83 Use `ansible.builtin.meta` or `ansible.legacy.meta` instead.

    Read documentation for instructions on how to ignore specific rule violations.

                        Rule Violation Summary                    
    count tag                    profile    rule associated tags 
        1 jinja[spacing]         basic      formatting (warning) 
        2 name[missing]          basic      idiom                
        2 yaml[indentation]      basic      formatting, yaml     
        1 yaml[trailing-spaces]  basic      formatting, yaml     
        2 risky-file-permissions safety     unpredictability     
        2 fqcn[action-core]      production formatting           

    Failed after min profile: 9 failure(s), 1 warning(s) on 1 files.
    ```
    - После исправлений:

    ```shell
    odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/02$ ansible-lint playbook/site.yml 

    Passed with production profile: 0 failure(s), 0 warning(s) on 1 files.
    ```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

    ```shell
    odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/02$ ansible-playbook -i playbook/inventory/prod.yml playbook/site.yml --check

    PLAY [Install Clickhouse] **************************************************************************************************************************************************************************

    TASK [Gathering Facts] *****************************************************************************************************************************************************************************
    ok: [clickhouse-01]

    TASK [Get clickhouse distrib] **********************************************************************************************************************************************************************
    changed: [clickhouse-01] => (item=clickhouse-common-static)
    changed: [clickhouse-01] => (item=clickhouse-client)
    changed: [clickhouse-01] => (item=clickhouse-server)

    TASK [Install clickhouse packages manually] ********************************************************************************************************************************************************
    failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "item": "clickhouse-common-static", "msg": "Unable to install package: E:Could not open file /tmp/clickhouse-common-static-22.8.5.29.deb - open (2: No such file or directory)"}
    failed: [clickhouse-01] (item=clickhouse-client) => {"ansible_loop_var": "item", "changed": false, "item": "clickhouse-client", "msg": "Unable to install package: E:Could not open file /tmp/clickhouse-client-22.8.5.29.deb - open (2: No such file or directory)"}
    failed: [clickhouse-01] (item=clickhouse-server) => {"ansible_loop_var": "item", "changed": false, "item": "clickhouse-server", "msg": "Unable to install package: E:Could not open file /tmp/clickhouse-server-22.8.5.29.deb - open (2: No such file or directory)"}

    TASK [Log error in ClickHouse install] *************************************************************************************************************************************************************
    ok: [clickhouse-01] => {
        "msg": "Произошла ошибка, но продолжаем playbook"
    }

    TASK [Remove temporary deb files] ******************************************************************************************************************************************************************
    ok: [clickhouse-01] => (item=clickhouse-common-static)
    ok: [clickhouse-01] => (item=clickhouse-client)
    ok: [clickhouse-01] => (item=clickhouse-server)

    TASK [Flush handlers] ******************************************************************************************************************************************************************************

    TASK [Wait for ClickHouse ready] *******************************************************************************************************************************************************************
    skipping: [clickhouse-01]

    TASK [Create database] *****************************************************************************************************************************************************************************
    skipping: [clickhouse-01]

    PLAY [Install Vector] ******************************************************************************************************************************************************************************

    TASK [Gathering Facts] *****************************************************************************************************************************************************************************
    ok: [vector-01]

    TASK [Download Vector package] *********************************************************************************************************************************************************************
    fatal: [vector-01]: FAILED! => {"changed": false, "dest": "/tmp/vector-22.8.5.29.deb", "elapsed": 0, "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://apt.vector.dev/pool/v/ve/vector_22.8.5.29_amd64.deb"}

    TASK [Log error in Vector install] *****************************************************************************************************************************************************************
    ok: [vector-01] => {
        "msg": "Произошла ошибка - vector"
    }

    TASK [Remove temporary deb files] ******************************************************************************************************************************************************************
    ok: [vector-01]

    TASK [Flush handlers] ******************************************************************************************************************************************************************************

    PLAY RECAP *****************************************************************************************************************************************************************************************
    clickhouse-01              : ok=4    changed=1    unreachable=0    failed=0    skipped=2    rescued=1    ignored=0   
    vector-01                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
    ```
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

    ```shell
    odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/02$ ansible-playbook -i playbook/inventory/prod.yml playbook/site.yml --diff

    PLAY [Install Clickhouse] **************************************************************************************************************************************************************************

    TASK [Gathering Facts] *****************************************************************************************************************************************************************************
    The authenticity of host '51.250.69.20 (51.250.69.20)' can't be established.
    ED25519 key fingerprint is SHA256:rJL4ZKQgum04EDQ3rMv6RKXjFFOi9zl42NsyY+rgErQ.
    This key is not known by any other names.
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    ok: [clickhouse-01]

    TASK [Get clickhouse distrib] **********************************************************************************************************************************************************************
    changed: [clickhouse-01] => (item=clickhouse-common-static)
    changed: [clickhouse-01] => (item=clickhouse-client)
    changed: [clickhouse-01] => (item=clickhouse-server)

    TASK [Install clickhouse packages manually] ********************************************************************************************************************************************************
    Selecting previously unselected package clickhouse-common-static.
    (Reading database ... 34788 files and directories currently installed.)
    Preparing to unpack .../clickhouse-common-static-22.8.5.29.deb ...
    Unpacking clickhouse-common-static (22.8.5.29) ...
    Setting up clickhouse-common-static (22.8.5.29) ...
    changed: [clickhouse-01] => (item=clickhouse-common-static)
    Selecting previously unselected package clickhouse-client.
    (Reading database ... 34803 files and directories currently installed.)
    Preparing to unpack .../clickhouse-client-22.8.5.29.deb ...
    Unpacking clickhouse-client (22.8.5.29) ...
    Setting up clickhouse-client (22.8.5.29) ...
    changed: [clickhouse-01] => (item=clickhouse-client)
    Selecting previously unselected package clickhouse-server.
    (Reading database ... 34816 files and directories currently installed.)
    Preparing to unpack .../clickhouse-server-22.8.5.29.deb ...
    Unpacking clickhouse-server (22.8.5.29) ...
    Setting up clickhouse-server (22.8.5.29) ...
    changed: [clickhouse-01] => (item=clickhouse-server)

    TASK [Flush handlers] ******************************************************************************************************************************************************************************

    RUNNING HANDLER [Start clickhouse service] *********************************************************************************************************************************************************
    changed: [clickhouse-01]

    TASK [Wait for ClickHouse ready] *******************************************************************************************************************************************************************
    ok: [clickhouse-01]

    TASK [Create database] *****************************************************************************************************************************************************************************
    changed: [clickhouse-01]

    PLAY [Install Vector] ******************************************************************************************************************************************************************************

    TASK [Gathering Facts] *****************************************************************************************************************************************************************************
    The authenticity of host '130.193.38.99 (130.193.38.99)' can't be established.
    ED25519 key fingerprint is SHA256:Kx1ZEqQ6ArFggaj/8saR/zEWr0JvIImxhS7K21ILd+U.
    This key is not known by any other names.
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    ok: [vector-01]

    TASK [Download Vector package] *********************************************************************************************************************************************************************
    changed: [vector-01]

    TASK [Install vector packages manually] ************************************************************************************************************************************************************
    Selecting previously unselected package vector.
    (Reading database ... 34788 files and directories currently installed.)
    Preparing to unpack /tmp/vector-0.49.0-1.deb ...
    Unpacking vector (0.49.0-1) ...
    Setting up vector (0.49.0-1) ...
    systemd-journal:x:999:
    changed: [vector-01]

    TASK [Vector config from template] *****************************************************************************************************************************************************************
    --- before: /etc/vector/vector.yaml
    +++ after: /home/odv/.ansible/tmp/ansible-local-6587082fs74zf4/tmpc1u37y0a/vector.yaml.j2
    @@ -1,49 +1,11 @@
    -#                                    __   __  __
    -#                                    \ \ / / / /
    -#                                     \ V / / /
    -#                                      \_/  \/
    -#
    -#                                    V E C T O R
    -#                                   Configuration
    -#
    -# ------------------------------------------------------------------------------
    -# Website: https://vector.dev
    -# Docs: https://vector.dev/docs
    -# Chat: https://chat.vector.dev
    -# ------------------------------------------------------------------------------
    +sources:
    +  in:
    +    type: "stdin"
    
    -# Change this to use a non-default directory for Vector data storage:
    -# data_dir: "/var/lib/vector"
    -
    -# Random Syslog-formatted logs
    -sources:
    -  dummy_logs:
    -    type: "demo_logs"
    -    format: "syslog"
    -    interval: 1
    -
    -# Parse Syslog logs
    -# See the Vector Remap Language reference for more info: https://vrl.dev
    -transforms:
    -  parse_logs:
    -    type: "remap"
    -    inputs: ["dummy_logs"]
    -    source: |
    -      . = parse_syslog!(string!(.message))
    -
    -# Print parsed logs to stdout
    sinks:
    -  print:
    +  out:
    +    inputs:
    +      - "in"
        type: "console"
    -    inputs: ["parse_logs"]
        encoding:
    -      codec: "json"
    -      json:
    -        pretty: true
    -
    -# Vector's GraphQL API (disabled by default)
    -# Uncomment to try it out with the `vector top` command or
    -# in your browser at http://localhost:8686
    -# api:
    -#   enabled: true
    -#   address: "127.0.0.1:8686"
    +      codec: "text"
    \ No newline at end of file

    changed: [vector-01]

    TASK [Flush handlers] ******************************************************************************************************************************************************************************

    RUNNING HANDLER [Restart vector service] ***********************************************************************************************************************************************************
    changed: [vector-01]

    PLAY RECAP *****************************************************************************************************************************************************************************************
    clickhouse-01              : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    vector-01                  : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

    ```shell
    odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/02$ ansible-playbook -i playbook/inventory/prod.yml playbook/site.yml --diff

    PLAY [Install Clickhouse] **************************************************************************************************************************************************************************

    TASK [Gathering Facts] *****************************************************************************************************************************************************************************
    ok: [clickhouse-01]

    TASK [Get clickhouse distrib] **********************************************************************************************************************************************************************
    ok: [clickhouse-01] => (item=clickhouse-common-static)
    ok: [clickhouse-01] => (item=clickhouse-client)
    ok: [clickhouse-01] => (item=clickhouse-server)

    TASK [Install clickhouse packages manually] ********************************************************************************************************************************************************
    ok: [clickhouse-01] => (item=clickhouse-common-static)
    ok: [clickhouse-01] => (item=clickhouse-client)
    ok: [clickhouse-01] => (item=clickhouse-server)

    TASK [Flush handlers] ******************************************************************************************************************************************************************************

    TASK [Wait for ClickHouse ready] *******************************************************************************************************************************************************************
    ok: [clickhouse-01]

    TASK [Create database] *****************************************************************************************************************************************************************************
    changed: [clickhouse-01]

    PLAY [Install Vector] ******************************************************************************************************************************************************************************

    TASK [Gathering Facts] *****************************************************************************************************************************************************************************
    ok: [vector-01]

    TASK [Download Vector package] *********************************************************************************************************************************************************************
    ok: [vector-01]

    TASK [Install vector packages manually] ************************************************************************************************************************************************************
    ok: [vector-01]

    TASK [Vector config from template] *****************************************************************************************************************************************************************
    ok: [vector-01]

    TASK [Flush handlers] ******************************************************************************************************************************************************************************

    PLAY RECAP *****************************************************************************************************************************************************************************************
    clickhouse-01              : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    vector-01                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```
9. Подготовьте README.md-файл по своему playbook.

    - [README.md](playbook/README.md)

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить решение задания

Приложите ссылку на ваше решение в поле "Ссылка на решение" и нажмите "Отправить решение"

---
