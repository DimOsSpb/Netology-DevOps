# Домашнее задание к занятию 6 «Создание собственных модулей»

# Решение

**Шаг 3.** Заполните файл в соответствии с требованиями Ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.
**Шаг 4.** Проверьте module на исполняемость локально.

```shell
(venv) odv@matebook16s:~/projects/ansible$ python -m ansible.modules.my_own_module args.json

{"changed": true, "created": true, "updated": false, "invocation": {"module_args": {"path": "/home/odv/tmp-t/Hello.txt", "content": "Hello ansible!!"}}}
```

- Тестирование:

```shell
(venv) odv@matebook16s:~/projects/ansible$ ansible-test sanity my_own_module --python 3.12
WARNING: The validate-modules sanity test cannot compare against the base commit because it was not detected.
WARNING: Skipping tests disabled by default without --allow-disabled: package-data
Running sanity test "action-plugin-docs"
...
Running sanity test "yamllint"
WARNING: Reviewing previous 2 warning(s):
WARNING: The validate-modules sanity test cannot compare against the base commit because it was not detected.
WARNING: Skipping tests disabled by default without --allow-disabled: package-data
```

**Шаг 5.** Напишите single task playbook и используйте module в нём.

![1](img/1.png)

**Шаг 6.** Проверьте через playbook на идемпотентность.

![2](img/2.png)

**Шаг 7.** Выйдите из виртуального окружения.
**Шаг 8.** Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.yandex_cloud_elk`.
**Шаг 9.** В эту collection перенесите свой module в соответствующую директорию.
**Шаг 10.** Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module.
**Шаг 11.** Создайте playbook для использования этой role.
**Шаг 12.** Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.
**Шаг 13.** Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.
**Шаг 14.** Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.
**Шаг 15.** Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`.
**Шаг 16.** Запустите playbook, убедитесь, что он работает.

```shell
odv@matebook16s:~/projects/MY/DevOpsCourse/ansible-homeworks/06$ ansible-playbook site.yml -v
No config file found; using defaults
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [My Own Role Playbook] *************************************************************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************************************************
ok: [localhost]

TASK [dimosspb_devopscourse.training.my_own_role : Create a file with content] **********************************************************************************************************************************
ok: [localhost] => {"changed": false, "created": false, "updated": false}

PLAY RECAP ******************************************************************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

**Шаг 17.** В ответ необходимо прислать ссылки на collection и tar.gz архив, а также скриншоты выполнения пунктов 4, 6, 15 и 16.

- [Collection](https://github.com/DimOsSpb/my_own_collection/tree/1.0.0?tab=readme-ov-file)
- [tar.gz](https://github.com/DimOsSpb/my_own_collection/raw/c0650a6785cc5089d45f39226a4917f5d7fa5a55/dimosspb_devopscourse-training-1.0.0.tar.gz)

## Необязательная часть

1. Реализуйте свой модуль для создания хостов в Yandex Cloud.
2. Модуль может и должен иметь зависимость от `yc`, основной функционал: создание ВМ с нужным сайзингом на основе нужной ОС. Дополнительные модули по созданию кластеров ClickHouse, MySQL и прочего реализовывать не надо, достаточно простейшего создания ВМ.
3. Модуль может формировать динамическое inventory, но эта часть не является обязательной, достаточно, чтобы он делал хосты с указанной спецификацией в YAML.
4. Протестируйте модуль на идемпотентность, исполнимость. При успехе добавьте этот модуль в свою коллекцию.
5. Измените playbook так, чтобы он умел создавать инфраструктуру под inventory, а после устанавливал весь ваш стек Observability на нужные хосты и настраивал его.
6. В итоге ваша коллекция обязательно должна содержать: clickhouse-role (если есть своя), lighthouse-role, vector-role, два модуля: my_own_module и модуль управления Yandex Cloud хостами и playbook, который демонстрирует создание Observability стека.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
