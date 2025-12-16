# Домашнее задание к занятию «Обновление приложений»

### Цель задания

Выбрать и настроить стратегию обновления приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.
-----

>### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор
>
>1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
>2. Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
>3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
>4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
>5. Вам нужно объяснить свой выбор стратегии обновления приложения.

---
## Решение задания 1.

1. Мы ограничены в ресурсах с запасом 20% - это оставляет нам только 2 стратегии (Recreate & RollingUpdate).
2. Blue-green & Canary требуют ресурсов которых у нас нет - не рассматриваем эти стратегии. 
3. RollingUpdate хорошо вписалось бы здесь с 0-м downtime, НО `"Обновление мажорное, новые версии приложения не умеют работать со старыми"` - при RollingUpdate мы рискуем сломать приложение, т.к. при этой стратегии будут сосуществовать одновременно поды с разными несовместимыми версиями! Т.е. RollingUpdate без дополнительных механизмов использовать нельзя.

**Т.о. остается только Recreate. При мем есть downtime, но он контролируемый и честный.**

>### Задание 2. Обновить приложение
>
>1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
>2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
>3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
>4. Откатиться после неудачного обновления.

---
## Решение задания 2.

- Кластер

```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/terraform$ export KUBECONFIG=~/.kube/NetologyK8S-1.conf
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/terraform$ kubectl get nodes
NAME      STATUS   ROLES           AGE   VERSION
master0   Ready    control-plane   90s   v1.34.2
worker0   Ready    <none>          79s   v1.34.2
worker1   Ready    <none>          79s   v1.34.2
```
- [Deployment приложения с nginx:1.19 и multitool. Количество реплик — 5](sol/app/app1.yaml)

```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ kubectl create namespace app
namespace/app created
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ kubectl config set-context --current --namespace=app
Context "kubernetes-admin@kubernetes" modified.
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ kubectl apply -f app1.yaml
deployment.apps/app created
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ kubectl get pods
NAME                  READY   STATUS    RESTARTS   AGE
app-9c998bc5b-dp8ll   2/2     Running   0          18s
app-9c998bc5b-f9x8m   2/2     Running   0          18s
app-9c998bc5b-nj4l6   2/2     Running   0          21s
app-9c998bc5b-rmnwz   2/2     Running   0          21s
app-9c998bc5b-t98mp   2/2     Running   0          21s
```
- `Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.`
    - [Меняем в Deployment nginx: 1.19 на 1.20. Пропишем стратегию = RollingUpdate](sol/app/app2.yaml). RollingUpdate выполнит условие доступности приложения с обновлением в максимально возможное короткое время - maxSurge: 100%,
    maxUnavailable: 0.
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ kubectl apply -f app2.yaml
deployment.apps/app configured
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ kubectl get pods
NAME                   READY   STATUS              RESTARTS   AGE
app-7f555d46bd-8rthp   0/2     ContainerCreating   0          3s
app-7f555d46bd-9hbwr   0/2     ContainerCreating   0          3s
app-7f555d46bd-kdzdb   0/2     ContainerCreating   0          3s
app-7f555d46bd-p92fj   0/2     ContainerCreating   0          3s
app-7f555d46bd-z6hsw   0/2     ContainerCreating   0          3s
app-9c998bc5b-dp8ll    2/2     Running             0          16m
app-9c998bc5b-f9x8m    2/2     Running             0          16m
app-9c998bc5b-nj4l6    2/2     Running             0          16m
app-9c998bc5b-rmnwz    2/2     Running             0          16m
app-9c998bc5b-t98mp    2/2     Running             0          16m
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ kubectl get pods
NAME                   READY   STATUS              RESTARTS   AGE
app-7f555d46bd-8rthp   0/2     ContainerCreating   0          12s
app-7f555d46bd-9hbwr   0/2     ContainerCreating   0          12s
app-7f555d46bd-kdzdb   0/2     ContainerCreating   0          12s
app-7f555d46bd-p92fj   2/2     Running             0          12s
app-7f555d46bd-z6hsw   2/2     Running             0          12s
app-9c998bc5b-dp8ll    2/2     Running             0          16m
app-9c998bc5b-f9x8m    2/2     Running             0          16m
app-9c998bc5b-nj4l6    2/2     Terminating         0          16m
app-9c998bc5b-rmnwz    2/2     Terminating         0          16m
app-9c998bc5b-t98mp    2/2     Running             0          16m
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
app-7f555d46bd-8rthp   2/2     Running   0          20s
app-7f555d46bd-9hbwr   2/2     Running   0          20s
app-7f555d46bd-kdzdb   2/2     Running   0          20s
app-7f555d46bd-p92fj   2/2     Running   0          20s
app-7f555d46bd-z6hsw   2/2     Running   0          20s
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app$ 
```
---

>## Дополнительные задания — со звёздочкой*
>### Задание 3*. Создать Canary deployment
>
>1. Создать два deployment'а приложения nginx.
>2. При помощи разных ConfigMap сделать две версии приложения — веб-страницы.
>3. С помощью ingress создать канареечный деплоймент, чтобы можно было часть трафика перебросить на разные версии приложения.

- Canary-деплой реализуется через создание дополнительного Ingress с аннотациями canary, позволяющими маршрутизировать часть трафика на сервис новой версии приложения по определенным критериям.  
Это позволяет протестировать новую версию без влияния на основной трафик с постепенным переходом на новый релиз.

- [Исходники манифестов sol/app*](sol/app*/)
- Применим пока deployment1.yml configmap1.yml service-stable.yml ingress.yml
```bash
^Codv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
Handling connection for 8080

odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ curl -I http://localhost:8080/
HTTP/1.1 200 OK
Date: Tue, 16 Dec 2025 12:15:00 GMT
Content-Type: text/html
Content-Length: 283
Connection: keep-alive
Last-Modified: Tue, 16 Dec 2025 11:25:32 GMT
ETag: "694141ac-11b"
Accept-Ranges: bytes

odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ curl http://localhost:8080/
<!DOCTYPE html>
<html>
<head>
  <title>Страница APP ver 1.1</title>
</head>
<body>
  <h1>Прмер, как реализуется канареечный деплоймент</h1>
  <h2>Это стабильная версия приложения</h2>      
</body>
</html>
```
- Работает.
- Теперь применим canary deployment2.yml configmap2.yml service-new.yml ingress-canary.yml
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ kubectl get all,ingress -n app
NAME                        READY   STATUS    RESTARTS   AGE
pod/app1-6dfd7c78d4-vh9cs   1/1     Running   0          10m
pod/app2-df86b89c6-c429f    1/1     Running   0          10m

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/ngx-new      ClusterIP   10.108.105.139   <none>        80/TCP    10m
service/ngx-stable   ClusterIP   10.108.107.139   <none>        80/TCP    10m

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app1   1/1     1            1           10m
deployment.apps/app2   1/1     1            1           10m

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/app1-6dfd7c78d4   1         1         1       10m
replicaset.apps/app2-df86b89c6    1         1         1       10m

NAME                                       CLASS   HOSTS   ADDRESS   PORTS   AGE
ingress.networking.k8s.io/ingress-stable   nginx   *                 80      10m
ingress.networking.k8s.io/nginx-canary     nginx   *                 80      10m
```
- Теперь видим, что часть трафика уходит на canary ingress
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
```
- В другом терминале:

```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ curl http://localhost:8080/ 
<!DOCTYPE html>
<html>
<head>
  <title>Страница APP ver 1.1</title>
</head>
<body>
  <h1>Прмер, как реализуется канареечный деплоймент</h1>
  <h2>Это стабильная версия приложения</h2>      
</body>
</html>
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ curl http://localhost:8080/ 
<!DOCTYPE html>
<html>
<head>
  <title>Страница APP ver 1.1</title>
</head>
<body>
  <h1>Прмер, как реализуется канареечный деплоймент</h1>
  <h2>Это стабильная версия приложения</h2>      
</body>
</html>
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ curl http://localhost:8080/ 
<!DOCTYPE html>
<html>
<head>
  <title>Страница APP ver 1.2</title>
</head>
<body>
  <h1>Прмер, как реализуется канареечный деплоймент</h1>
  <h2>Это <b>новая</b> версия приложения 1.2</h2>      
</body>
</html>
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ curl http://localhost:8080/ 
<!DOCTYPE html>
<html>
<head>
  <title>Страница APP ver 1.2</title>
</head>
<body>
  <h1>Прмер, как реализуется канареечный деплоймент</h1>
  <h2>Это <b>новая</b> версия приложения 1.2</h2>      
</body>
</html>
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.4/sol/app*$ curl http://localhost:8080/ 
<!DOCTYPE html>
<html>
<head>
  <title>Страница APP ver 1.1</title>
</head>
<body>
  <h1>Прмер, как реализуется канареечный деплоймент</h1>
  <h2>Это стабильная версия приложения</h2>      
</body>
</html>
``` 

**В данном случае настроено 30% на canary ingress, можно менять и настраивать другии критерии**
---
 
*
### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Updating a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment).
2. [Статья про стратегии обновлений](https://habr.com/ru/companies/flant/articles/471620/).
3. [Canary-релизы в Kubernetes на базе Ingress-NGINX Controller](https://habr.com/ru/companies/flant/articles/697030/)