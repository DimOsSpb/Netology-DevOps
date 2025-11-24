# Подготовка среды
- Установим terraform 
    - [Дистрибутив](https://github.com/netology-code/devops-materials?tab=readme-ov-file)
    - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli?in=terraform%2Faws-get-started#install-cli)
- Установим yandex cloud cli и настроим работу с облаком
    - [Yandex cloud](https://yandex.cloud/ru/docs/cli/quickstart#install)
- Установим хост k8s в облаке [terraform](terraform)
- Установим на хост snapd, microk8s
```
    sudo apt install snapd
    sudo snap install microk8s --classic
    sudo usermod -aG microk8s $USER
    sudo chown -f -R $USER ~/.kube
    newgrp microk8s
    microk8s status
```
- Для задания надо добавить ingress
  
```
microk8s enable ingress
```

## Для подключения к внешнему ip-адресу

- Сгенерировать сертификат для подключения к внешнему ip-адресу.
- Пропишем внешний ip хоста с microk8s в файл /var/snap/microk8s/current/certs/csr.conf.template
- обновиm сертификаты `sudo microk8s refresh-certs --cert server.crt`
- И что важно - нужно добавить строчки в /var/snap/microk8s/current/args/kube-apiserver
```
--bind-address=0.0.0.0
--advertise-address=EXTIP
```
- Рестарт microk8s `sudo snap restart microk8s`

- Получим конфиг для kuberctl
```
microk8s config > kubeconfig-microk8s
```
- Скопируем его себе на хосте управления
```
scp -i ~/.ssh/netology ubuntu@158.160.37.177:~/kubeconfig-microk8s ~/.kube/microk8s-config

```
- Отредактируем наш конфиг на хосте управления. Надо добавить из microk8s-config разделы сервера, контекста, и пользователя не дублируя имена - сделать их уникальными.

```
- Должно получится например
```
odv@matebook16s:~$ kubectl config get-contexts
CURRENT   NAME           CLUSTER            AUTHINFO   NAMESPACE
*         microk8s       microk8s-cluster   admin      
          microk8s-ext   microk8s-ext       admin-ext
```
- Переключимся
```
kubectl config use-context microk8s-ext
kuberctl cluster-info

```
