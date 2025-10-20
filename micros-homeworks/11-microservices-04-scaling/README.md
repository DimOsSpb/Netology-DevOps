
# Домашнее задание к занятию «Микросервисы: масштабирование»

    Вы работаете в крупной компании, которая строит систему на основе микросервисной архитектуры.
    Вам как DevOps-специалисту необходимо выдвинуть предложение по организации инфраструктуры для разработки и эксплуатации.

    ## Задача 1: Кластеризация

    Предложите решение для обеспечения развёртывания, запуска и управления приложениями.
    Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

    Решение должно соответствовать следующим требованиям:
    - поддержка контейнеров;
    - обеспечивать обнаружение сервисов и маршрутизацию запросов;
    - обеспечивать возможность горизонтального масштабирования;
    - обеспечивать возможность автоматического масштабирования;
    - обеспечивать явное разделение ресурсов, доступных извне и внутри системы;
    - обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т. п.

    Обоснуйте свой выбор.

---

## Решение

Опираясь на требования, составим список инструментов для обеспечения развёртывания, запуска и управления приложениями:

1. _поддержка контейнеров;_
    - Прежде всего это Docker или даже Podman т.к. он удобнее для безопасной локальной разработки, CI/CD без демона и rootless сценариев.  
    
А вот из нструментов которые лучше подходит для оркестрации микросервисной архитектуры по всем источникам это - Kubernetes и Docker Swarm, который по многим критериям проигрывает.
Я рассматривал только общепринятые open source решения, OpenShift от Red Hat и тот-же HashiCorp Nomad здесь не рассматривал.  
К тому же на сегодня k8s для крупных и сложных систем K8s всё равно остаётся стандартом, развивается, он хорошо покрывает все нижестоящие требования, open source, отлично документирован.   
Возможно на начальных этапах использовать Docker Swarm, т.к. k8s более сложный и требователен к ресурсам.
    
Итак по пунктам, т.к нам нужно:

2. _обеспечивать обнаружение сервисов и маршрутизацию запросов;_
    - у ``k8s`` встроенное обнаружение сервисов и маршрутизация запросов. Docker swarm имеет service discovery и встроенный балансировщик. Оба подходят но ``K8s`` более гибкий, умеет более сложную маршрутизацию.

3. _обеспечивать возможность горизонтального масштабирования;_
    - ``K8s`` имеет Horizontal Pod Autoscaler по метрикам, а в Docker swarm можно масштабировать сервисы только вручную.

4. _обеспечивать возможность автоматического масштабирования;_
    - ``K8s`` имеет Cluster Autoscaler, swarm nолько ручное масштабирование.

5. _обеспечивать явное разделение ресурсов, доступных извне и внутри системы;_
    - ``K8s`` имеет Namespaces + NetworkPolicies, swarm ограниченные возможности сетевой сегментации

6. _обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т. п._
    - ``K8S`` имеет ConfigMaps + Secrets с шифрованием, в swarm Secrets есть, но управление ограничено

**В итоге Kubernetes полностью удовлетворяет всем требованиям как платформа для крупной микросервисной архитектуры, где важны масштабирование, безопасное разделение ресурсов и гибкая маршрутизация. Docker или Podman для работы с контейнерами. GitLab для CI/CD, локальный или облачный.**

---

## Задача 2: Распределённый кеш * (необязательная)

    Разработчикам вашей компании понадобился распределённый кеш для организации хранения временной информации по сессиям пользователей.
    Вам необходимо построить Redis Cluster, состоящий из трёх шард с тремя репликами.

    ### Схема:

![11-04-01](img/task.png)

---

## Решение

[Redis cluster specification](https://redis-doc.netlify.app/docs/reference/cluster-spec/)

- Такая конфигурация, как на картинке, подходит для разработки и тестирования,небольших проектов с умеренной нагрузкой, демонстрационных стендов. Для production лучше использовать 6 контейнеров, но конфигурация с 3 контейнерами и разнесенными репликами - это хороший компромисс

```shell
odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-04-scaling/redis-cluster$ docker logs redis-setup
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica node2:6380 to node1:6379
Adding replica node3:6380 to node2:6379
Adding replica node1:6380 to node3:6379
M: 0796e1d825a4f3a70b5c785d096394a5247c5e83 node1:6379
   slots:[0-5460] (5461 slots) master
S: c597633c2e19a3243945a5c3def55e9e529da02f node1:6380
   replicates a8379e06892d2d9247760b126e40272ade57ce4f
M: 0acf19b41f46ac318c7e1b58d2e566c5fda84da9 node2:6379
   slots:[5461-10922] (5462 slots) master
S: 631dacfddddd3655e8f36ab14ff48f6d0460c2fd node2:6380
   replicates 0796e1d825a4f3a70b5c785d096394a5247c5e83
M: a8379e06892d2d9247760b126e40272ade57ce4f node3:6379
   slots:[10923-16383] (5461 slots) master
S: 6a8ae2d0228e50b9b5a31831ccb28ca716ab81e4 node3:6380
   replicates 0acf19b41f46ac318c7e1b58d2e566c5fda84da9
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join

>>> Performing Cluster Check (using node node1:6379)
M: 0796e1d825a4f3a70b5c785d096394a5247c5e83 node1:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 6a8ae2d0228e50b9b5a31831ccb28ca716ab81e4 172.18.0.4:6380
   slots: (0 slots) slave
   replicates 0acf19b41f46ac318c7e1b58d2e566c5fda84da9
M: a8379e06892d2d9247760b126e40272ade57ce4f 172.18.0.4:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 631dacfddddd3655e8f36ab14ff48f6d0460c2fd 172.18.0.3:6380
   slots: (0 slots) slave
   replicates 0796e1d825a4f3a70b5c785d096394a5247c5e83
S: c597633c2e19a3243945a5c3def55e9e529da02f 172.18.0.2:6380
   slots: (0 slots) slave
   replicates a8379e06892d2d9247760b126e40272ade57ce4f
M: 0acf19b41f46ac318c7e1b58d2e566c5fda84da9 172.18.0.3:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-04-scaling/redis-cluster$ 
```

```shell
odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-04-scaling/redis-cluster$ docker exec -it node1 redis-cli --cluster check node1:6379
node1:6379 (0796e1d8...) -> 0 keys | 5461 slots | 1 slaves.
172.18.0.4:6379 (a8379e06...) -> 0 keys | 5461 slots | 1 slaves.
172.18.0.3:6379 (0acf19b4...) -> 0 keys | 5462 slots | 1 slaves.
[OK] 0 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node node1:6379)
M: 0796e1d825a4f3a70b5c785d096394a5247c5e83 node1:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 6a8ae2d0228e50b9b5a31831ccb28ca716ab81e4 172.18.0.4:6380
   slots: (0 slots) slave
   replicates 0acf19b41f46ac318c7e1b58d2e566c5fda84da9
M: a8379e06892d2d9247760b126e40272ade57ce4f 172.18.0.4:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 631dacfddddd3655e8f36ab14ff48f6d0460c2fd 172.18.0.3:6380
   slots: (0 slots) slave
   replicates 0796e1d825a4f3a70b5c785d096394a5247c5e83
S: c597633c2e19a3243945a5c3def55e9e529da02f 172.18.0.2:6380
   slots: (0 slots) slave
   replicates a8379e06892d2d9247760b126e40272ade57ce4f
M: 0acf19b41f46ac318c7e1b58d2e566c5fda84da9 172.18.0.3:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```
```shell
odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-04-scaling/redis-cluster$ docker exec -it node1 redis-cli -c cluster nodes
6a8ae2d0228e50b9b5a31831ccb28ca716ab81e4 172.18.0.4:6380@16380 slave 0acf19b41f46ac318c7e1b58d2e566c5fda84da9 0 1760982460604 3 connected
a8379e06892d2d9247760b126e40272ade57ce4f 172.18.0.4:6379@16379 master - 0 1760982461613 5 connected 10923-16383
631dacfddddd3655e8f36ab14ff48f6d0460c2fd 172.18.0.3:6380@16380 slave 0796e1d825a4f3a70b5c785d096394a5247c5e83 0 1760982461000 1 connected
c597633c2e19a3243945a5c3def55e9e529da02f 172.18.0.2:6380@16380 slave a8379e06892d2d9247760b126e40272ade57ce4f 0 1760982461512 5 connected
0acf19b41f46ac318c7e1b58d2e566c5fda84da9 172.18.0.3:6379@16379 master - 0 1760982461000 3 connected 5461-10922
0796e1d825a4f3a70b5c785d096394a5247c5e83 172.18.0.2:6379@16379 myself,master - 0 0 1 connected 0-5460
```