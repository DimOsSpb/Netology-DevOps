### Ansible-Playbook по заданию к занятию 2 «Работа с Playbook»

Данный плейбук не предназначен для решения каких-то определенных практических задач. Это результат решения домашней работы по курсу DevOps и пример использования возможностей Ansible для автоматического развертывания сервисов на примере установки ClickHouse, LightHouse и Vector.

## Описание

Плейбук устанавливает на хосты указанные в инвентори - ClickHouse, LightHouse (+ Nginx) и Vector, согласно настройке состава пакетов и версий в переменных groupe_vars: 

- Для ClickHouse 
    - clickhouse_version - версия пакетов
    - clickhouse_packages - состав пакетов
    - pakage_type - тип пакетного менеджера 

- Для Vector
    - vector_version - версия
    - vector_input_type - тип input
    - vector_input_include - список input
    - pakage_type - тип пакетного менеджера 

- Для LightHouse
    - lighthouse_version: commit id/ tag/ ветка git 
    - lighthouse_rep: url git репозитория
    - lighthouse_dir: каталог развертывания
    - lighthouse_nginx_conf: имя конфиг файла lighhouse для nginx
    - lighthouse_nginx_name: имя сервера для nginx
    - pakage_type - тип пакетного менеджера
    - pakage_type - тип пакетного менеджера
Для Nginx в папке templates темплейт файл с конфигурационным файлом. Этот файл может быть расширен согласно вашим требованиям и будет установлен вместе с сервисом.  
Для сервиса ClickHouse будет добавлена база logs  
Для сервиса Vector в папке templates темплейт файл с конфигурационным файлом. Этот файл может быть расширен согласно вашим требованиям и будет установлен вместе с сервисом.  
При модификации конфигурационного файла и повторном применении, плейбук перезагрузит сервис для принятия изменений.  
Все play`s помечены Tags для избирательного использования  

Т.о. этот плейбук готов к работе и дальнейшему развитию согласно Вашим задачам.  

## Требования

- Работующие Debian хосты (версии >= 11) с установленым python, с минимальными требованиями к ClickHouse, LightHouse и Vector, их IP, которые должны быть доступны и в соответствии сервисам, прописаны в inventory/prod.yml
- На целевых хостах должен быть установлен ssh public key для доступа с хоста управления.
- На хосте управления (от куда производится запуск playbook) Ansible ver >= 2.9
- В playbook/group_vars... настроены нужные версии сервисов, см. ссылки ниже 
    - [ClickHouse](https://packages.clickhouse.com/deb/pool/main/c/)
    - [LightHouse](https://github.com/VKCOM/lighthouse)
    - [Vector](https://apt.vector.dev/pool/v/ve/)

## Установка

- Перейти в каталог с плейбуком site.yml
- Выполнить плейбук
```shell
playbook$ ansible-playbook -i inventory/prod.yml site.yml
```

## Ссылки
    
- [Исходное задание](https://github.com/netology-code/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex)
- [Репозиторий с решением](../)
- [ClickHouse](https://clickhouse.com/)
- [LightHouse](https://github.com/VKCOM/lighthouse)
- [Vector](https://vector.dev/)
- [Nginx](https://nginx.org/) 