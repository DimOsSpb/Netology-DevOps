# Домашнее задание к занятию «Введение в Terraform»

### Цели задания

1. Установить и настроить Terrafrom.
2. Научиться использовать готовый код.

### Задание 1

1. Перейдите в каталог [**src**](https://github.com/netology-code/ter-homeworks/tree/main/01/src). Скачайте все необходимые зависимости, использованные в проекте. 
    ```bash
    cp .terraformrc ~/
2. Изучите файл **.gitignore**. В каком terraform-файле, согласно этому .gitignore, допустимо сохранить личную, секретную информацию?(логины,пароли,ключи,токены итд)
    ```
    personal.auto.tfvars

3. Выполните код проекта. Найдите  в state-файле секретное содержимое созданного ресурса **random_password**, пришлите в качестве ответа конкретный ключ и его значение.

    ```
    "bcrypt_hash": "$2a$10$/TgnMnQArfGVHdaxo4W0/e2Q2qtQhneBIqa5ZAp7UYycyh2F0xGvS"
    
4. Раскомментируйте блок кода, примерно расположенный на строчках 29–42 файла **main.tf**.
Выполните команду ```terraform validate```. Объясните, в чём заключаются намеренно допущенные ошибки. Исправьте их.

    
    1. Нет имени ресурса для "docker_image" исправим -> resource "docker_image" "nginx" {...
    2. Нельзя давать любые названия с начальной цифрой, поэтому "1nginx" для "docker_container" исправим -> resource "docker_container" "nginx" {...
    3. "FAKE.resulT" - "example_${random_password.random_string_FAKE.resulT}" исправим -> "example_${random_password.random_string.result}"
    
    
5. Выполните код. В качестве ответа приложите: исправленный фрагмент кода и вывод команды ```docker ps```.

      ```bash
      odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/01/src$ terraform validate
      Success! The configuration is valid.
      ```
      ```c
      resource "docker_image" "nginx" {
        name         = "nginx:latest"
        keep_locally = true
      }

      resource "docker_container" "nginx" {
        image = docker_image.nginx.image_id
      #  name  = "example_${random_password.random_string_FAKE.resulT}"
        name  = "example_${random_password.random_string.result}"

        ports {
          internal = 80
          external = 9090
        }
      }
      ```

      ```bash
      odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/01/src$ docker ps
      CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
      4ddfe1940823   2cd1d97f893f   "/docker-entrypoint.…"   6 seconds ago   Up 5 seconds   0.0.0.0:9090->80/tcp   example_iAA70goDT667ThTx
      odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/01/src$ 
      

6. Замените имя docker-контейнера в блоке кода на ```hello_world```. Не перепутайте имя контейнера и имя образа. Мы всё ещё продолжаем использовать name = "nginx:latest". Выполните команду ```terraform apply -auto-approve```.
Объясните своими словами, в чём может быть опасность применения ключа  ```-auto-approve```. Догадайтесь или нагуглите зачем может пригодиться данный ключ? В качестве ответа дополнительно приложите вывод команды ```docker ps```.

    - -auto-approve - отменяет интерактивное подтверждение, которое terraform выдает перед применением изменений, что дает избежать случайного применения и позволяет оценить план изменения перед применением.  
    Польза от ключа в возможности его использования для автоматизации различных сценариев в скриптах, циклах CI/CD и т.п.

    ```bash
    ...
    Plan: 1 to add, 0 to change, 1 to destroy.
    docker_container.nginx: Destroying... [id=4ddfe1940823962f42eb4463c5dc79a3ae372309a90cd045e52f539f466ca2f5]
    docker_container.nginx: Destruction complete after 1s
    docker_container.nginx: Creating...
    docker_container.nginx: Creation complete after 0s [id=0a06786d54711dad8f84f883ed936b2f7ba601caff95387177276bba16c3916f]

    Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/01/src$ docker ps
    CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                  NAMES
    0a06786d5471   2cd1d97f893f   "/docker-entrypoint.…"   24 seconds ago   Up 23 seconds   0.0.0.0:9090->80/tcp   hello_world
    
8. Уничтожьте созданные ресурсы с помощью **terraform**. Убедитесь, что все ресурсы удалены. Приложите содержимое файла **terraform.tfstate**.

    ```bash
    terraform destroy
    ...

      # docker_image.nginx will be destroyed
      - resource "docker_image" "nginx" {
          ...
          - keep_locally = true -> null

    ...

    Destroy complete! Resources: 3 destroyed.
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/01/src$ terraform show
    The state file is empty. No resources are represented.

    ```
    ```json
    {
    "version": 4,
    "terraform_version": "1.12.0",
    "serial": 11,
    "lineage": "19b26d94-e52c-16dd-3777-3ce7b18680e8",
    "outputs": {},
    "resources": [],
    "check_results": null
    }


9. Объясните, почему при этом не был удалён docker-образ **nginx:latest**. Ответ **ОБЯЗАТЕЛЬНО НАЙДИТЕ В ПРЕДОСТАВЛЕННОМ КОДЕ**, а затем **ОБЯЗАТЕЛЬНО ПОДКРЕПИТЕ** строчкой из документации [**terraform провайдера docker**](https://docs.comcloud.xyz/providers/kreuzwerker/docker/latest/docs).  (ищите в классификаторе resource docker_image )

    - Образ не удален из хранилища контейнера, т.к. в настройках ресурса образа прописано keep_locally = true, вот из документации:

    
    _keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will delete the image from the docker local storage on destroy operation._

    Но в выводе самого тераформа типо удалю и удалил)), проверим - nginx:latest на месте:

    ```bash
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/01/src$ docker images
    REPOSITORY                                              TAG       IMAGE ID       CREATED         SIZE
    ...                                            latest    20d732e24d4e   6 days ago      281MB
    nginx                                                   latest    2cd1d97f893f   10 days ago     192MB
    ...
    ```
    ```
    *** Интересно проверить:
    Изменил keep_locally = false, terraform apply, terraform destroy, docker images - Да -образ удален!
    
  ------

### Задание 2*

1. Создайте в облаке ВМ. Сделайте это через web-консоль, чтобы не слить по незнанию токен от облака в github(это тема следующей лекции). Если хотите - попробуйте сделать это через terraform, прочитав документацию yandex cloud. Используйте файл ```personal.auto.tfvars``` и гитигнор или иной, безопасный способ передачи токена!
2. Подключитесь к ВМ по ssh и установите стек docker.
---
  - Забегая вперед, [настроил развертывание вм через тераформ](task/db.tf). Ну и по ходу развернул докер тоже через тераформ и cloud-init.


      ```bash
      ...
      yandex_compute_instance.vm: Still creating... [00m30s elapsed]
      yandex_compute_instance.vm: Creation complete after 36s [id=fhmia2q363fs3kh7f64j]

      Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

      odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/01/task$ ssh -i ~/.ssh/netology odv@89.169.159.53
      The authenticity of host '89.169.159.53 (89.169.159.53)' can't be established.
      ED25519 key fingerprint is SHA256:8vS8mlBZB1AMm0TrivNJpwZB0mgxPz2pbWnhnA8OQdA.
      This key is not known by any other names.
      Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
      Warning: Permanently added '89.169.159.53' (ED25519) to the list of known hosts.
      Linux fhmia2q363fs3kh7f64j 6.1.0-37-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64

      The programs included with the Debian GNU/Linux system are free software;
      the exact distribution terms for each program are described in the
      individual files in /usr/share/doc/*/copyright.

      Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
      permitted by applicable law.

      odv@fhmia2q363fs3kh7f64j:~$ docker -v
      Docker version 20.10.24+dfsg1, build 297e128
      ```
3. Найдите в документации docker provider способ настроить подключение terraform на вашей рабочей станции к remote docker context вашей ВМ через ssh.

    
    - [Remote Hosts](https://docs.comcloud.xyz/providers/kreuzwerker/docker/latest/docs#remote-hosts)

4. Используя terraform и  remote docker context, скачайте и запустите на вашей ВМ контейнер ```mysql:8``` на порту ```127.0.0.1:3306```, передайте ENV-переменные. Сгенерируйте разные пароли через random_password и передайте их в контейнер...

    - [task/db.tf]()

6. Зайдите на вашу ВМ , подключитесь к контейнеру и проверьте наличие секретных env-переменных с помощью команды ```env```. Запишите ваш финальный код в репозиторий.

    ```shell
    odv@fhm5der9j6kcf2ivdc28:~$ docker ps
    CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                 NAMES
    f3f8afc3ec93   4606814384c7   "docker-entrypoint.s…"   14 minutes ago   Up 14 minutes   127.0.0.1:3306->3306/tcp, 33060/tcp   mysql8
    odv@fhm5der9j6kcf2ivdc28:~$ docker exec -it f3f8afc3ec93 /bin/bash
    bash-5.1# env
    MYSQL_MAJOR=8.4
    HOSTNAME=f3f8afc3ec93
    PWD=/
    MYSQL_ROOT_PASSWORD=qSR4lyBGUtkbtehB
    MYSQL_PASSWORD=nz6YWfEISH8mzjSO
    MYSQL_USER=wordpress
    HOME=/root
    MYSQL_VERSION=8.4.6-1.el9
    GOSU_VERSION=1.17
    TERM=xterm
    MYSQL_ROOT_HOST=%
    SHLVL=1
    MYSQL_DATABASE=wordpress
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    MYSQL_SHELL_VERSION=8.4.6-1.el9
    _=/usr/bin/env
    bash-5.1# 

    ```

### Задание 3*
1. Установите [opentofu](https://opentofu.org/)(fork terraform с лицензией Mozilla Public License, version 2.0) любой версии

  - [Installing using the installer](https://opentofu.org/docs/intro/install/deb/#installing-using-the-installer)
    ```shell
    odv@matebook16s:~/Downloads$ tofu -v
    OpenTofu v1.10.3
    on linux_amd64

2. Попробуйте выполнить тот же код с помощью ```tofu apply```, а не terraform apply.

    ! Не без проблемы этого времени, информация как это решить есть, но эти решения не помогают в независимости. Получив работу, имея сертификат на Х, используя инструмент X и обнаружив, что он вдруг перестал работать - плохая история. :
      ```
      cp ~/.terraformrc ~/.tofurc
      + Для каждого описанного провайдера в параметр source необходимо добавить префикс registry.terraform.io/
      ```
    ```shell
    OpenTofu has been successfully initialized!

    You may now begin working with OpenTofu. Try running "tofu plan" to see
    any changes that are required for your infrastructure. All OpenTofu commands
    should now work.

    If you ever set or change modules or backend configuration for OpenTofu,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/01/task2$ tofu apply
    random_password.mysql_root_password: Refreshing state... [id=none]
    random_password.mysql_user_password: Refreshing state... [id=none]
    docker_image.mysql: Refreshing state... [id=sha256:4606814384c7ad5895ade4e05aa6d5fbe9056b30706848020ecb8b59e0e8f60dmysql:8]
    yandex_compute_instance.db: Refreshing state... [id=fhm5der9j6kcf2ivdc28]
    docker_container.mysql: Refreshing state... [id=f3f8afc3ec931b2da0b3fa0355860cc766ae7601d2d96a688169f239fd9c0061]

    No changes. Your infrastructure matches the configuration.

    OpenTofu has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
    ```
  ## Как пожелание - как-то отражать работаюшие у нас в Росии варианты замещения. Как с этими проблемами борются (или нет), что  думают? ..



