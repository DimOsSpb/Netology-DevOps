# Домашнее задание к занятию «Микросервисы: принципы»

    Вы работаете в крупной компании, которая строит систему на основе микросервисной архитектуры.
    Вам как DevOps-специалисту необходимо выдвинуть предложение по организации инфраструктуры для разработки и эксплуатации.

    ## Задача 1: API Gateway 

    Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

    Решение должно соответствовать следующим требованиям:
    - маршрутизация запросов к нужному сервису на основе конфигурации,
    - возможность проверки аутентификационной информации в запросах,
    - обеспечение терминации HTTPS.

    Обоснуйте свой выбор.
---
### Решение:

API Gateway - это единая точка входа для всех запросов. Он маршрутизирует запрос к нужному микросервису. Gateway расшифровывает (терминирует) запрос, проверяет сертификат, аутентификацию, логирует и маршрутизирует дальше уже обычный HTTP-трафик во внутреннюю сеть к микросервисам (там уже не нужно шифрование, если сеть защищённая).

Вот сравнительная таблица решений, которые наиболее извесны и активно используются. Здесь я еще отразил российские и облачные решения, они платные, но например для системы развернутой в том-же Yandex Cloud - Yandex API Gateway будет логичным выбором.

| Критерий                      | Kong (OSS)   | Apache APISIX | Tyk           | Nginx        | Traefik      | Yandex API Gateway | Nexign API Gateway | Platform V SOWA |
|------------------------------|--------------|---------------|---------------|-------------|--------------|--------------------|------------------|----------------|
| Open-source                   | да           | да            | да            | да          | да           | нет                | нет              | нет            |
| Стоимость                     | бесплатно     | бесплатно      | бесплатно      | бесплатно    | бесплатно    | платно              | платно           | платно         |
| Доступность документации      | хорошая      | отличная      | средняя       | отличная    | хорошая      | высокая             | высокая          | высокая        |
| Сложность установки и эксплуатации | средняя      | низкая        | средняя       | очень низкая| низкая       | низкая               | высокая          | высокая        |
| Микросервисная архитектура   | да           | да            | да            | да          | да           | да                 | да               | да             |
| Маршрутизация на основе конфигурации | да           | да            | да            | да          | да           | да                 | да               | да             |
| Совместимость с Kubernetes (k8s) | да           | да            | да            | ограничена  | да           | да                 | да               | да             |
| Совместимость с Docker Swarm  | да           | да            | да            | ограничена  | да           | да                 | да               | да             |
| Масштабируемость              | да           | да            | да            | ограничено  | да           | да                 | да               | да             |
| Заблокировано для России      | частично     | нет           | нет           | нет         | нет          | нет                | нет              | нет            |

#### - Таким образом для `крупной` компании следует сделать ставку на масштабируемость, функциональность - Apache APISIX или Traefik. Kong (OSS) остаётся хорошим выбором, но учитывая санкции, стоит учесть возможные трудности с поддержкой и развитием  
#### - Для системы развернутой в облаке будет нативно использовать решение от провайдера - например Yandex Cloud - Yandex API Gateway
#### - Из таблицы видно, что теоретически Nginx можно использовать совместно с Kubernetes или Docker Swarm, но такая настройка сложна. Специализированные API-шлюзы (например, Traefik или Kong) изначально поддерживают автообновления маршрутов и балансировку нагрузки на уровне оркестратора.

## Задача 2: Брокер сообщений

    Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

    Решение должно соответствовать следующим требованиям:
    - поддержка кластеризации для обеспечения надёжности,
    - хранение сообщений на диске в процессе доставки,
    - высокая скорость работы,
    - поддержка различных форматов сообщений,
    - разделение прав доступа к различным потокам сообщений,
    - простота эксплуатации.

    Обоснуйте свой выбор.
---
### Решение:

Таблица оценки критериев: (``+``) - это лучше или (да), (``-``) - это хуже или (нет) 

| Критерий                          | RabbitMQ   | Kafka      | ActiveMQ    | Redis Streams | RocketMQ   | Nats Streaming | Yandex Message Queue |
|----------------------------------|------------|------------|-------------|---------------|------------|-------------------|-----------------------|
| **Open-source**                   | +          | +          | +           | +             | +          | +                 | -                   |
| **Стоимость**                     | ++++       | ++++       | ++++        | ++++          | ++++       | ++++              | -                   |
| **Поддержка кластеризации**       | ++         | ++++       | ++          | -             | ++         | ++               | ++++                |
| **Хранение сообщений на диске**    | +++        | +++++      | +++         | -             | +++        | +++              | +++++               |
| **Высокая скорость работы**       | +++        | +++++      | +++         | ++++          | +++        | ++++             | ++++                |
| **Разделяемые форматы сообщений** | +++        | ++++       | +++         | ++++          | +++        | ++++             | ++++                |
| **Разграничение прав доступа**     | +++        | ++++       | +++         | -             | +++        | +++              | ++++                |
| **Простота эксплуатации**         | ++++       | +++        | +++         | ++++          | +++        | ++++             | ++++                |
| **Российский брокер сообщений**    | -          | -          | -           | -             | -          | -                | ++++                |
| **Заблокирован для России**       | -          | -          | -           | -             | -          | -                | -                   |

#### По совокупности лучшие кандидаты на роль брокера сообщений для нашей задачи — это RabbitMQ, Kafka и Yandex Message Queue. В зависимости от специфики системы остается выбрать наиболее подходящий брокер из:

- RabbitMQ т.к. простотой в эксплуатации и много форматов сообщений.
- Kafka т.к. имеет выше скорость и масштабируемость - лучше для больших нагрузок.
- Yandex Message Queue - по базированию решения и это русский брокер сообщений, обладает высоким уровнем надежности и хорошими характеристиками хранения и скорости.
---

## Задача 3: API Gateway * (необязательная)

    ### Есть три сервиса:

    **minio**
    - хранит загруженные файлы в бакете images,
    - S3 протокол,

    **uploader**
    - принимает файл, если картинка сжимает и загружает его в minio,
    - POST /v1/upload,

    **security**
    - регистрация пользователя POST /v1/user,
    - получение информации о пользователе GET /v1/user,
    - логин пользователя POST /v1/token,
    - проверка токена GET /v1/token/validation.

    ### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

    **POST /v1/register**
    1. Анонимный доступ.
    2. Запрос направляется в сервис security POST /v1/user.

    **POST /v1/token**
    1. Анонимный доступ.
    2. Запрос направляется в сервис security POST /v1/token.

    **GET /v1/user**
    1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
    2. Запрос направляется в сервис security GET /v1/user.

    **POST /v1/upload**
    1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
    2. Запрос направляется в сервис uploader POST /v1/upload.

    **GET /v1/user/{image}**
    1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
    2. Запрос направляется в сервис minio GET /images/{image}.

    ### Ожидаемый результат

    Результатом выполнения задачи должен быть docker compose файл, запустив который можно локально выполнить следующие команды с успешным результатом.
    Предполагается, что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки, который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
    Авторизация
    curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

    **Загрузка файла**

    curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload

    **Получение файла**
    curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg

    ---

    #### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)


---

### Решение:

#### Что сделал в [api-gateway](api-gateway):

1. Подготовил [gateway/nginx.conf](api-gateway/gateway/nginx.conf)
2. Модифицировал [security/src/server.py](api-gateway/security/src/server.py) и [security/requirements.txt](api-gateway/security/requirements.txt) чтобы подружить библиотеки под свежие версии и привести код в рабочее состояние в текущем окружении.
3. Немного прологировал [uploader/src/server.js](api-gateway/uploader/src/server.js)  в поисках причины отдачи не полного файла из s3 (как я по началу подумал)... Но причина в применении политики доступа в контейнере создания бакета - для последних версий /usr/bin/mc policy set download ... - устарело:
    ```
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ docker logs api-gateway-createbuckets-1
    Added `storage` successfully.
    Bucket created successfully `storage/data`.
    mc: Please use 'mc anonymous'
    ```

- **Надо в docker-compose заменить на /usr/bin/mc anonymous set download ...**

    ```
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ docker logs api-gateway-createbuckets-1
    Added `storage` successfully.
    Bucket created successfully `storage/data`.
    Access permission for `storage/data` is set to `download`
    ```
4. Ну и в условии у нас анонимных доступа к nginx только два - POST /v1/register; POST /v1/token, а в проверке приведен пример ``Получение файла`` без токена. Надо это учесть и в настройке и в проверке.

    ```shell
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ docker ps -a
    CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS                      PORTS                                             NAMES
    af345d46d16f   nginx:alpine           "/docker-entrypoint.…"   21 minutes ago   Up 20 minutes               80/tcp, 0.0.0.0:80->9090/tcp, [::]:80->9090/tcp   api-gateway-gateway-1
    3529eb7796cd   api-gateway-uploader   "docker-entrypoint.s…"   21 minutes ago   Up 20 minutes               3000/tcp                                          api-gateway-uploader-1
    f72ef6f6120f   minio/mc               "/bin/sh -c ' sleep …"   21 minutes ago   Exited (0) 20 minutes ago                                                     api-gateway-createbuckets-1
    ba931b06b6f5   minio/minio:latest     "/usr/bin/docker-ent…"   21 minutes ago   Up 20 minutes (healthy)     9000/tcp                                          api-gateway-storage-1
    03938d493e1b   api-gateway-security   "python ./server.py"     21 minutes ago   Up 20 minutes               3000/tcp                                          api-gateway-security-1
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJib2IifQ.-51G5JQmpJleARHp8rIljBczPFanWT93d_N_7LQGUXU(venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ 
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ curl -X GET -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJib2IifQ.-51G5JQmpJleARHp8rIljBczPFanWT93d_N_7LQGUXU' http://localhost/user
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ curl -X POST -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJib2IifQ.-51G5JQmpJleARHp8rIljBczPFanWT93d_N_7LQGUXU' -H 'Content-Type: octet/stream' --data-binary @../img/1.jpg http://localhost/upload
    {"filename":"98b49156-b6d0-49ac-a790-eab4d808faec.jpg"}(venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ 
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ curl -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJib2IifQ
    .-51G5JQmpJleARHp8rIljBczPFanWT93d_N_7LQGUXU' http://localhost/image/98b49156-b6d0-49ac-a790-eab4d808faec.jpg > test.jpg
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100  418k  100  418k    0     0  44.9M      0 --:--:-- --:--:-- --:--:-- 45.4M
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ ls -al ../img/1.jpg
    -rw-r--r-- 1 odv odv 428965 окт 16 15:09 ../img/1.jpg
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ ls -al test.jpg
    -rw-r--r-- 1 odv odv 428965 окт 16 18:39 test.jpg
    (venv) odv@matebook16s:~/projects/MY/DevOpsCourse/micros-homeworks/11-microservices-02-principles/api-gateway$ 
    ```

    ![img](img/2.png)
