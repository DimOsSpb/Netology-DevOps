# Домашнее задание к занятию Troubleshooting

### Цель задания

Устранить неисправности при деплое приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ export KUBECONFIG=~/.kube/NetologyK8S-1.conf
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl get nodes
NAME      STATUS   ROLES           AGE    VERSION
master0   Ready    control-plane   110s   v1.34.2
worker0   Ready    <none>          97s    v1.34.2
worker1   Ready    <none>          97s    v1.34.2
```

>### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить
>
>1. Установить приложение по команде:
>```shell
>kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
>```
>2. Выявить проблему и описать.
>3. Исправить проблему, описать, что сделано.
>4. Продемонстрировать, что проблема решена.


---
## Решение

- Пробуем установить

```bach
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "web" not found
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "data" not found
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "data" not found
```
- Очевидно что у нас нет таких namespace (web, data)
- [Создадим и применим namespaces.yml где эти ns создаются](sol/app/solution.yml)
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl apply -f solution.yml 
namespace/web created
namespace/data created
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl get namespaces 
NAME              STATUS   AGE
data              Active   9s
default           Active   17m
ingress-nginx     Active   17m
kube-node-lease   Active   17m
kube-public       Active   17m
kube-system       Active   17m
web               Active   9s

odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl get pods -n web
NAME                            READY   STATUS             RESTARTS      AGE
web-consumer-64fc486bdf-2pc8c   0/1     CrashLoopBackOff   5 (40s ago)   3m33s
web-consumer-64fc486bdf-g98qc   0/1     CrashLoopBackOff   5 (35s ago)   3m33s
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl get pods -n data
NAME                       READY   STATUS    RESTARTS   AGE
auth-db-849bffd554-6dbvg   1/1     Running   0          3m37s
```
- В namespace web поды в `rashLoopBackOff` - Если посмотреть [манифест task.yml](sol/app/task.yml), становится ясно почему. 
    `- while true; do curl auth-db; sleep 5; done` curl  обращается к auth-db - он в другом неймспейс. Цикл сломается изза ненуленого результата и под завершится.
- Вариант исправления:
    1. Исправить манифест, но он не наш
    2. Создать сервис-прокси в целевом namespace, т.е.ExternalName сервис с именем auth-db с пересылкой по полному dns имени auth-db.data.svc.cluster.local
- Добавим [сервис в](sol/app/solution.yml)
- Примени и проверим работу.  
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
deployment.apps/web-consumer created
deployment.apps/auth-db unchanged
service/auth-db unchanged
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl get pods -n web
NAME                            READY   STATUS             RESTARTS     AGE
web-consumer-64fc486bdf-b86f8   0/1     CrashLoopBackOff   1 (3s ago)   4s
web-consumer-64fc486bdf-smwt2   0/1     CrashLoopBackOff   1 (3s ago)   4s
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ 
```
-  Все также. Но например 
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl run test -n web --image=curlimages/curl --rm -it -- /bin/sh
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
~ $ nslookup auth-db
Server:         10.96.0.10
Address:        10.96.0.10:53


auth-db.web.svc.cluster.local   canonical name = auth-db.data.svc.cluster.local
Name:   auth-db.data.svc.cluster.local
Address: 10.107.171.56

~ $ curl auth-db
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
~ $ 
```
- Говорит что дело в образе. Я не смог ничего сделать в этом образе.
- Мы можем подменить образ в приложении командой:
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl get pods -n web
NAME                            READY   STATUS             RESTARTS       AGE
web-consumer-64fc486bdf-b86f8   0/1     CrashLoopBackOff   6 (101s ago)   7m12s
web-consumer-64fc486bdf-smwt2   0/1     CrashLoopBackOff   6 (83s ago)    7m12s
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl set image deployment/web-consumer -n web busybox=curlimages/curl
deployment.apps/web-consumer image updated
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl get pods -n web
NAME                            READY   STATUS    RESTARTS   AGE
web-consumer-6d57d5bb48-fqp9q   1/1     Running   0          4s
web-consumer-6d57d5bb48-nvzcs   1/1     Running   0          2s
```
- Видим статус Running и
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ kubectl logs web-consumer-6d57d5bb48-fqp9q -n web | tail -n 30
</body>
</html>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612 100   612   0     0 265740     0  --:--:-- --:--:-- --:--:-- 306000
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.5/sol/app$ 
```
- Сервис отдает страницу

**Как-то так, не меняя исходный манифест***

---



### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
