# Домашнее задание к занятию «Как работает сеть в K8s»

### Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер K8s с установленным сетевым плагином Calico.

-----

>### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа
>
>1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
>2. В качестве образа использовать network-multitool.
>3. Разместить поды в namespace App.
>4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
>5. Продемонстрировать, что трафик разрешён и запрещён.


---
## Решение

- Разверну кластер в облаке через 1 мастер, 2 ноды  [terraform/ansible (из прошлых решений) - соответствующие каталоги](sol/) 

```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol1/terraform$ export KUBECONFIG=~/.kube/NetologyK8S-1.conf
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol1/terraform$ kubectl cluster-info 
Kubernetes control plane is running at https://158.160.126.82:6443
CoreDNS is running at https://158.160.126.82:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol1/terraform$ kubectl get nodes
NAME      STATUS   ROLES           AGE     VERSION
master0   Ready    control-plane   20m     v1.34.2
worker0   Ready    <none>          6m35s   v1.34.2
worker1   Ready    <none>          6m36s   v1.34.2
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol1/terraform$ kubectl get pods -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-6fd9cc49d6-6tn89   1/1     Running   0          25m
kube-system   calico-node-jh947                          1/1     Running   0          25m
kube-system   calico-node-wc4xv                          1/1     Running   0          12m
kube-system   calico-node-zdjk7                          1/1     Running   0          12m
kube-system   coredns-66bc5c9577-28ql5                   1/1     Running   0          25m
kube-system   coredns-66bc5c9577-9npzv                   1/1     Running   0          25m
kube-system   etcd-master0                               1/1     Running   0          26m
kube-system   kube-apiserver-master0                     1/1     Running   0          26m
kube-system   kube-controller-manager-master0            1/1     Running   0          26m
kube-system   kube-proxy-k5kks                           1/1     Running   0          25m
kube-system   kube-proxy-r9rcm                           1/1     Running   0          12m
kube-system   kube-proxy-wnz2m                           1/1     Running   0          12m
kube-system   kube-scheduler-master0                     1/1     Running   0          26m
```
- Создаём namespace App
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol1/terraform$ kubectl create namespace app
namespace/app created
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol1/terraform$ kubectl config set-context --current --namespace=app
Context "kubernetes-admin@kubernetes" modified.
```
- Развернем [приложение в неймспейс app](sol/app/app.yaml)
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl apply -f app.yaml 
deployment.apps/frontend created
deployment.apps/backend created
deployment.apps/cache created
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl get all -n app
NAME                            READY   STATUS    RESTARTS   AGE
pod/backend-f898756c8-fnv4f     1/1     Running   0          20m
pod/backend-f898756c8-z2h7c     1/1     Running   0          20m
pod/cache-6f66499db6-52h7t      1/1     Running   0          20m
pod/frontend-66877c74c4-9gcv2   1/1     Running   0          20m
pod/frontend-66877c74c4-lmpwp   1/1     Running   0          20m

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/backend    ClusterIP   10.110.157.244   <none>        80/TCP    20m
service/cache      ClusterIP   10.104.130.245   <none>        80/TCP    20m
service/frontend   ClusterIP   10.100.93.33     <none>        80/TCP    20m

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend    2/2     2            2           20m
deployment.apps/cache      1/1     1            1           20m
deployment.apps/frontend   2/2     2            2           20m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/backend-f898756c8     2         2         2       20m
replicaset.apps/cache-6f66499db6      1         1         1       20m
replicaset.apps/frontend-66877c74c4   2         2         2       20m
```
- Проверим что все доступно до применения политик
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl apply -f app.yaml 
deployment.apps/frontend unchanged
service/frontend unchanged
deployment.apps/backend unchanged
service/backend unchanged
deployment.apps/cache configured
service/cache unchanged
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/frontend -n app -- curl -s http://cache.app.svc.cluster.local
WBITT Network MultiTool (with NGINX) - cache-5bcc4769b8-j6x9m - 10.244.204.68 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/backend -n app -- curl -s http://backend.app.svc.cluster.local
WBITT Network MultiTool (with NGINX) - backend-f898756c8-z2h7c - 10.244.235.129 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/frontend -n app -- curl -s http://frontend.app.svc.cluster.local
WBITT Network MultiTool (with NGINX) - frontend-66877c74c4-lmpwp - 10.244.204.65 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ 
```
- Подготовим [policy](sol/app/policy.yml) и применим его
```bash
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl apply -f policy.yml -n app
networkpolicy.networking.k8s.io/default-deny created
networkpolicy.networking.k8s.io/allow-dns-egress created
networkpolicy.networking.k8s.io/allow-frontend-to-backend-ingress created
networkpolicy.networking.k8s.io/allow-frontend-to-backend-egress created
networkpolicy.networking.k8s.io/allow-backend-to-cache-ingress created
networkpolicy.networking.k8s.io/allow-backend-to-cache-egress created
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/frontend -n app -- curl -s --connect-timeout 3 http://cache.app.svc.cluster.local
command terminated with exit code 28
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/cache -n app -- curl -s --connect-timeout 3 http://backend.app.svc.cluster.local
command terminated with exit code 28
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/cache -n app -- curl -s --connect-timeout 3 http://frontend.app.svc.cluster.local
command terminated with exit code 28
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/backend -n app -- curl -s --connect-timeout 3 http://frontend.app.svc.cluster.local
command terminated with exit code 28
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/frontend -n app -- curl -s --connect-timeout 3 http://backend.app.svc.cluster.local
WBITT Network MultiTool (with NGINX) - backend-f898756c8-fnv4f - 10.244.204.66 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
odv@matebook16s:~/project/MY/Netology-DevOps/kuber-homeworks/3.3/sol/app$ kubectl exec deploy/backend -n app -- curl -s --connect-timeout 3 http://cache.app.svc.cluster.local
WBITT Network MultiTool (with NGINX) - cache-5bcc4769b8-j6x9m - 10.244.204.68 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/).
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy).