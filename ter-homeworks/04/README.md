# Домашнее задание к занятию «Продвинутые методы работы с Terraform»

### Цели задания

1. Научиться использовать модули.
2. Отработать операции state.
3. Закрепить пройденный материал.

### Задание 1

1. Возьмите из [демонстрации к лекции готовый код](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1) для создания с помощью двух вызовов remote-модуля -> двух ВМ, относящихся к разным проектам(marketing и analytics) используйте labels для обозначения принадлежности.  В файле cloud-init.yml необходимо использовать переменную для ssh-ключа вместо хардкода. Передайте ssh-ключ в функцию template_file в блоке vars ={} .
Воспользуйтесь [**примером**](https://grantorchard.com/dynamic-cloudinit-content-with-terraform-file-templates/). Обратите внимание, что ssh-authorized-keys принимает в себя список, а не строку.
3. Добавьте в файл cloud-init.yml установку nginx.
4. Предоставьте скриншот подключения к консоли и вывод команды ```sudo nginx -t```, скриншот консоли ВМ yandex cloud с их метками. Откройте terraform console и предоставьте скриншот содержимого модуля. Пример: > module.marketing_vm

  - Решение:

    ![T1](img/task1-1.png)

    ```shell
    ubuntu@marketing-0:~$ sudo nginx -t
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful
    ```
    ```cpp
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform console
    > module.vm-marketing
    {
      "external_ip_address" = [
        "51.250.9.14",
      ]
      "fqdn" = [
        "marketing-0.ru-central1.internal",
      ]
      "internal_ip_address" = [
        "10.0.1.9",
      ]
      "labels" = [
        tomap({
          "project" = "marketing"
        }),
      ]
      "network_interface" = [
        tolist([
          {
            "dns_record" = tolist([])
            "index" = 0
            "ip_address" = "10.0.1.9"
            "ipv4" = true
            "ipv6" = false
            "ipv6_address" = ""
            "ipv6_dns_record" = tolist([])
            "mac_address" = "d0:0d:1c:e9:29:b1"
            "nat" = true
            "nat_dns_record" = tolist([])
            "nat_ip_address" = "51.250.9.14"
            "nat_ip_version" = "IPV4"
            "security_group_ids" = toset([])
            "subnet_id" = "e9bdbudoi1pvih5g22r1"
          },
        ]),
      ]
    }
    >  
    ```
------

### Задание 2

1. Напишите локальный модуль vpc, который будет создавать 2 ресурса: **одну** сеть и **одну** подсеть в зоне, объявленной при вызове модуля, например: ```ru-central1-a```.
2. Вы должны передать в модуль переменные с названием сети, zone и v4_cidr_blocks.
3. Модуль должен возвращать в root module с помощью output информацию о yandex_vpc_subnet. Пришлите скриншот информации из terraform console о своем модуле. Пример: > module.vpc_dev  
4. Замените ресурсы yandex_vpc_network и yandex_vpc_subnet созданным модулем. Не забудьте передать необходимые параметры сети из модуля vpc в модуль с виртуальной машиной.

  - Исходный код данного задания будет сохранен в ветке [ter-04-task2](https://github.com/DimOsSpb/Netology-DevOps/tree/terr-04-task2/ter-homeworks/04/src)

    ```cpp
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform console
    > module.vpc
    {
      "cidr" = tolist([
        "10.0.1.0/24",
      ])
      "name" = "develop"
      "subnet_id" = "e9bhhs7b3ta66joc11b5"
      "vpc_id" = "enplukq57f419hophos3"
      "zone" = "ru-central1-a"
    }
    >  

5. Сгенерируйте документацию к модулю с помощью terraform-docs.
 
  - [vpc-doc.md](src/modules/vpc/vpc-doc.md)

### Задание 3
1. Выведите список ресурсов в стейте.

    ```bash
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state list
    data.template_file.metadata
    data.yandex_compute_image.ubuntu
    module.vm-analytics.data.yandex_compute_image.my_image
    module.vm-analytics.yandex_compute_instance.vm[0]
    module.vm-marketing.data.yandex_compute_image.my_image
    module.vm-marketing.yandex_compute_instance.vm[0]
    module.vpc.yandex_vpc_network.this
    module.vpc.yandex_vpc_subnet.this
    ```
2. Полностью удалите из стейта модуль vpc.
3. Полностью удалите из стейта модуль vm.

    ```bash
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state rm module.vpc.yandex_vpc_network.this
    Removed module.vpc.yandex_vpc_network.this
    Successfully removed 1 resource instance(s).
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state rm module.vpc.yandex_vpc_subnet.this
    Removed module.vpc.yandex_vpc_subnet.this
    Successfully removed 1 resource instance(s).
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state rm module.vm-marketing.yandex_compute_instance.vm[0]
    Removed module.vm-marketing.yandex_compute_instance.vm[0]
    Successfully removed 1 resource instance(s).
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state rm module.vm-marketing.data.yandex_compute_image.my_image
    Removed module.vm-marketing.data.yandex_compute_image.my_image
    Successfully removed 1 resource instance(s).
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state rm module.vm-analytics.yandex_compute_instance.vm[0]
    Removed module.vm-analytics.yandex_compute_instance.vm[0]
    Successfully removed 1 resource instance(s).
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state rm module.vm-analytics.data.yandex_compute_image.my_image
    Removed module.vm-analytics.data.yandex_compute_image.my_image
    Successfully removed 1 resource instance(s).
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state list
    data.template_file.metadata
    data.yandex_compute_image.ubuntu
    ```
4. Импортируйте всё обратно. Проверьте terraform plan. Значимых(!!) изменений быть не должно.
Приложите список выполненных команд и скриншоты процессы.


    ```bash
    cat terraform.tfstate.1754397696.backup | jq -r '
    .resources[]
    | select(.module != null and (.module | test("^module\\.")))
    | "\(.module).\(.type).\(.name) \(.instances[0].attributes.id)"'
    module.vm-analytics.yandex_compute_image.my_image fd8383qtki9fpldbhtmd
    module.vm-analytics.yandex_compute_instance.vm fhmvih6kv91e9f06pgt2
    module.vm-marketing.yandex_compute_image.my_image fd8383qtki9fpldbhtmd
    module.vm-marketing.yandex_compute_instance.vm fhmhestqe88va8llcv2t
    module.vpc.yandex_vpc_network.this enplukq57f419hophos3
    module.vpc.yandex_vpc_subnet.this e9bhhs7b3ta66joc11b5
    ```
    - Здесь ввод весь, вывод последней команды импорта (так короче). Не сразу понял, что для loop ресурсов нужен индекс [0].

    ```bash
    terraform import module.vpc.yandex_vpc_network.this enplukq57f419hophos3
    terraform import module.vpc.yandex_vpc_subnet.this e9bhhs7b3ta66joc11b5
    terraform import module.vm-analytics.yandex_compute_image.my_image fd8383qtki9fpldbhtmd    
    terraform import module.vm-analytics.yandex_compute_instance.vm[0] fhmvih6kv91e9f06pgt2
    terraform import module.vm-marketing.yandex_compute_image.my_image fd8383qtki9fpldbhtmd
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform import module.vm-marketing.yandex_compute_instance.vm[0] fhmhestqe88va8llcv2t
    data.template_file.metadata: Reading...
    data.template_file.metadata: Read complete after 0s [id=e29077f3afdfd9a900a80f4434d788a45af29af8406df4ff2dd5da66999f5971]
    data.yandex_compute_image.ubuntu: Reading...
    data.yandex_compute_image.ubuntu: Read complete after 0s [id=fd8383qtki9fpldbhtmd]
    module.vm-marketing.data.yandex_compute_image.my_image: Reading...
    module.vm-analytics.data.yandex_compute_image.my_image: Reading...
    module.vm-marketing.data.yandex_compute_image.my_image: Read complete after 0s [id=fd8383qtki9fpldbhtmd]
    module.vm-marketing.yandex_compute_instance.vm[0]: Importing from ID "fhmhestqe88va8llcv2t"...
    module.vm-marketing.yandex_compute_instance.vm[0]: Import prepared!
      Prepared yandex_compute_instance for import
    module.vm-marketing.yandex_compute_instance.vm[0]: Refreshing state... [id=fhmhestqe88va8llcv2t]
    module.vm-analytics.data.yandex_compute_image.my_image: Read complete after 0s [id=fd8383qtki9fpldbhtmd]

    Import successful!

    The resources that were imported are shown above. These resources are now in
    your Terraform state and will henceforth be managed by Terraform.

    ```

    ```bash
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform state list
    data.template_file.metadata
    data.yandex_compute_image.ubuntu
    module.vm-analytics.data.yandex_compute_image.my_image
    module.vm-analytics.yandex_compute_instance.vm[0]
    module.vm-marketing.data.yandex_compute_image.my_image
    module.vm-marketing.yandex_compute_instance.vm[0]
    module.vpc.yandex_vpc_network.this
    module.vpc.yandex_vpc_subnet.this


    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/04/src$ terraform plan
    data.template_file.metadata: Reading...
    data.template_file.metadata: Read complete after 0s [id=e29077f3afdfd9a900a80f4434d788a45af29af8406df4ff2dd5da66999f5971]
    data.yandex_compute_image.ubuntu: Reading...
    module.vpc.yandex_vpc_network.this: Refreshing state... [id=enplukq57f419hophos3]
    data.yandex_compute_image.ubuntu: Read complete after 0s [id=fd8383qtki9fpldbhtmd]
    module.vm-analytics.data.yandex_compute_image.my_image: Reading...
    module.vm-marketing.data.yandex_compute_image.my_image: Reading...
    module.vm-analytics.data.yandex_compute_image.my_image: Read complete after 0s [id=fd8383qtki9fpldbhtmd]
    module.vm-marketing.data.yandex_compute_image.my_image: Read complete after 0s [id=fd8383qtki9fpldbhtmd]
    module.vpc.yandex_vpc_subnet.this: Refreshing state... [id=e9bhhs7b3ta66joc11b5]
    module.vm-analytics.yandex_compute_instance.vm[0]: Refreshing state... [id=fhmvih6kv91e9f06pgt2]
    module.vm-marketing.yandex_compute_instance.vm[0]: Refreshing state... [id=fhmhestqe88va8llcv2t]

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
      ~ update in-place

    Terraform will perform the following actions:

      # module.vm-analytics.yandex_compute_instance.vm[0] will be updated in-place
      ~ resource "yandex_compute_instance" "vm" {
          + allow_stopping_for_update = true
            id                        = "fhmvih6kv91e9f06pgt2"
            name                      = "analytics-0"
            # (15 unchanged attributes hidden)

            # (6 unchanged blocks hidden)
        }

      # module.vm-marketing.yandex_compute_instance.vm[0] will be updated in-place
      ~ resource "yandex_compute_instance" "vm" {
          + allow_stopping_for_update = true
            id                        = "fhmhestqe88va8llcv2t"
            name                      = "marketing-0"
            # (15 unchanged attributes hidden)

            # (6 unchanged blocks hidden)
        }

    Plan: 0 to add, 2 to change, 0 to destroy.
    ```

---

### Задание 4*

1. Измените модуль vpc так, чтобы он мог создать подсети во всех зонах доступности, переданных в переменной типа list(object) при вызове модуля.  
  
Пример вызова
```
module "vpc_prod" {
  source       = "./vpc"
  env_name     = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-c", cidr = "10.0.3.0/24" },
  ]
}

module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
}
```

Предоставьте код, план выполнения, результат из консоли YC.

### Задание 5*

1. Напишите модуль для создания кластера managed БД Mysql в Yandex Cloud с одним или несколькими(2 по умолчанию) хостами в зависимости от переменной HA=true или HA=false. Используйте ресурс yandex_mdb_mysql_cluster: передайте имя кластера и id сети.
2. Напишите модуль для создания базы данных и пользователя в уже существующем кластере managed БД Mysql. Используйте ресурсы yandex_mdb_mysql_database и yandex_mdb_mysql_user: передайте имя базы данных, имя пользователя и id кластера при вызове модуля.
3. Используя оба модуля, создайте кластер example из одного хоста, а затем добавьте в него БД test и пользователя app. Затем измените переменную и превратите сингл хост в кластер из 2-х серверов.
4. Предоставьте план выполнения и по возможности результат. Сразу же удаляйте созданные ресурсы, так как кластер может стоить очень дорого. Используйте минимальную конфигурацию.

### Задание 6*
1. Используя готовый yandex cloud terraform module и пример его вызова(examples/simple-bucket): https://github.com/terraform-yc-modules/terraform-yc-s3 .
Создайте и не удаляйте для себя s3 бакет размером 1 ГБ(это бесплатно), он пригодится вам в ДЗ к 5 лекции.

### Задание 7*

1. Разверните у себя локально vault, используя docker-compose.yml в проекте.
2. Для входа в web-интерфейс и авторизации terraform в vault используйте токен "education".
3. Создайте новый секрет по пути http://127.0.0.1:8200/ui/vault/secrets/secret/create
Path: example  
secret data key: test 
secret data value: congrats!  
4. Считайте этот секрет с помощью terraform и выведите его в output по примеру:
```
provider "vault" {
 address = "http://<IP_ADDRESS>:<PORT_NUMBER>"
 skip_tls_verify = true
 token = "education"
}
data "vault_generic_secret" "vault_example"{
 path = "secret/example"
}

output "vault_example" {
 value = "${nonsensitive(data.vault_generic_secret.vault_example.data)}"
} 

Можно обратиться не к словарю, а конкретному ключу:
terraform console: >nonsensitive(data.vault_generic_secret.vault_example.data.<имя ключа в секрете>)
```
5. Попробуйте самостоятельно разобраться в документации и записать новый секрет в vault с помощью terraform. 

### Задание 8*
Попробуйте самостоятельно разобраться в документаци и с помощью terraform remote state разделить root модуль на два отдельных root-модуля: создание VPC , создание ВМ . 

### Правила приёма работы

В своём git-репозитории создайте новую ветку terraform-04, закоммитьте в эту ветку свой финальный код проекта. Ответы на задания и необходимые скриншоты оформите в md-файле в ветке terraform-04.

В качестве результата прикрепите ссылку на ветку terraform-04 в вашем репозитории.

**Важно.** Удалите все созданные ресурсы.

### Критерии оценки

Зачёт ставится, если:

* выполнены все задания,
* ответы даны в развёрнутой форме,
* приложены соответствующие скриншоты и файлы проекта,
* в выполненных заданиях нет противоречий и нарушения логики.

На доработку работу отправят, если:

* задание выполнено частично или не выполнено вообще,
* в логике выполнения заданий есть противоречия и существенные недостатки. 




