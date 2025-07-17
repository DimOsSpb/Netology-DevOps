# [Домашнее задание к занятию 6. «Оркестрация кластером Docker контейнеров на примере Docker Swarm»](https://github.com/netology-code/virtd-homeworks/tree/shvirtd-1/05-virt-05-docker-swarm)

# Задача 1: Создадим Docker Swarm-кластер в Яндекс Облаке:

По условию задания, **не предполагается** использование "terraform" и "ansible", их мы должны использовать в последующем - 3-м задании.  
В результате у нас должен получиться docker swarm кластер из 1 мастера и 2-х рабочих нод (3 облачные виртуальные машины в одной сети яндекс облака). Итогом проверка - docker node ls  

**Но делать все в ручную, используя интерфейс яндекс облака - не интересно.**  

- В src/bash создам скрипт для автоматизации этого процесса. Управлять облаком будем через стандартное yandexcloud api (cli) - "ya". Важно учесть [особенности передачи переменных окружения vm в метаданных через CLI](https://yandex.cloud/ru/docs/compute/concepts/metadata/sending-metadata#environment-variables).
- Используем ранее созданый ssh-key .ssh/netology.
- Cli ya уже проинициализирована для доступа с этого хоста к яндекс облаку на прошлых уроках.
- В Yandex Cloud для каждой сети автоматически создается Default Security Group который разрешает весь трафик между ВМ внутри одной подсети и разрешает входящий трафик из любого внешнего источника для Docker Swarm это небезопасно — лучше ограничить доступ только до [нужных портов](https://docs.docker.com/engine/network/drivers/overlay/#firewall-rules)  
**В данной работе я не буду производить эти настройки и настройки iptables на хостах.**
- В yandex cloud используем cloud-init [Создать виртуальную машину с пользовательским скриптом конфигурации](https://yandex.cloud/ru/docs/compute/operations/vm-create/create-with-cloud-init-scripts), [--metadata-from-file user-data="<путь_к_файлу_конфигурации>"](src/bash/node.yaml)
---
- В каталоге src/bash [Скрипт для запуска создания swarm в яндекс облаке](src/bash/make_swarm.sh). В шапке скрипта настроим основные переменные, можно добавить настроек в [файл инициализации вм](src/bash/node.yaml) и запустим его:

        odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-05-docker-swarm/src/bash$ ./make_swarm.sh 
        - Making the Docker Swarm cluster on the Yandex cloud....
        - Create vm1-manager ip:10.128.0.11
        ...1s...6s...11s...16s...22s...27s...32s...38s...43s...done (47s)
        - vm1-manager NAT IP: 46.21.246.58
        - Create vm2-worker ip:10.128.0.12
        ...1s...6s...11s...16s...21s...27s...32s...37s...43s...48s...done (52s)
        - vm2-worker NAT IP: 158.160.98.14
        - Create vm3-worker ip:10.128.0.13
        ...1s...6s...11s...16s...21s...27s...32s...37s...done (40s)
        - vm3-worker NAT IP: 158.160.97.21
        - Wait ssh connection, cloud-init and docker started on node #1...

        - All services ready on node #1
        - Wait ssh connection, cloud-init and docker started on node #2...
        ............
        - All services ready on node #2
        - Wait ssh connection, cloud-init and docker started on node #3...
        ........
        - All services ready on node #3
        - Add manager vm1 ip:10.128.0.11 nat_ip:46.21.246.58
        - Add worker vm2-worker ip:10.128.0.12 nat_ip:158.160.98.14
        This node joined a swarm as a worker.
        - Add worker vm3-worker ip:10.128.0.13 nat_ip:158.160.97.21
        This node joined a swarm as a worker.
        - Make Finish - Docker Swarm Nodes List:

        ID                            HOSTNAME      STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
        5p2sd2q516jc0a0t1ab7db81y *   vm1-manager   Ready     Active         Leader           28.3.2
        yq8bp727qv8cznqpgvhupg6rh     vm2-worker    Ready     Active                          28.3.2
        uctc6jcg9gffwbzfspidl0dsf     vm3-worker    Ready     Active                          28.3.2
        odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-05-docker-swarm/src/bash$
    
- Удалим эти вм в облаке для экономии ресурсов

## LINKS
- [Yandex Cloud - cli - user-data example](https://yandex.cloud/ru/docs/compute/operations/vm-create/create-with-cloud-init-scripts#examples)
- [Особенности передачи переменных окружения в метаданных через CLI](https://yandex.cloud/ru/docs/compute/concepts/metadata/sending-metadata#environment-variables)
- [Docker Swarm Firewall Guide](https://docs.docker.com/engine/network/drivers/overlay/#firewall-rules)



---
# **Следующие не обязательные задания сделаю позже, после 05-virt-04-docker-in-practice, т.к. они ссылаются на него...**
# Задача 2: * 
# Задача 3: * 