# Домашнее задание к занятию «Использование Terraform в команде»

### Цели задания

1. Научиться использовать remote state с блокировками.
2. Освоить приёмы командной работы.

------

### Задание 1

1. Возьмите код:
- из [ДЗ к лекции 4](https://github.com/netology-code/ter-homeworks/tree/main/04/src),
- из [демо к лекции 4](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1).
2. Проверьте код с помощью tflint и checkov. Вам не нужно инициализировать этот проект.
3. Перечислите, какие **типы** ошибок обнаружены в проекте (без дублей).

    - ДЗ к лекции 4 (src):

    tflint: Warning: Missing version constraint for provider "yandex" in `required_providers` (terraform_required_providers)
        - Нам следует отслеживать и фиксировать версии ПО, которое используем, т.к. от версии к версии его поведение может менятся и приводить к непредсказуемым результатам 
    tflint: Warning: [Fixable] variable "vms_ssh_root_key" is declared but not used (terraform_unused_declarations)
        - Переменные объявлены но не используются. Это может говорить о потенциальных ошибках, удаленном коде и приводить к дополнительному времени в работе terraform. Рекомендуется чистить эти объявления.

    - ДЗ к лекции 4 (vms):

    tflint: Warning: Module source "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main" uses a default branch as ref (main) (terraform_module_pinned_source)
    checkov: Check: CKV_TF_1: "Ensure Terraform module sources use a commit hash"
    checkov: Check: CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
        - Здесь не указана фиксированая версия модуля, ветку main не рекомендуется указывать, т.к. она меняется и поведение кода может быть не предсказуемо. Нужно указывать версию по тегу, например v1.2.3 (?ref=v1.2.0"), или конкретный commit hash
    
------
### Задание 2

1. Возьмите ваш GitHub-репозиторий с **выполненным ДЗ 4** в ветке 'terraform-04' и сделайте из него ветку 'terraform-05'.
2. Повторите демонстрацию лекции: настройте YDB, S3 bucket, yandex service account, права доступа и мигрируйте state проекта в S3 с блокировками. Предоставьте скриншоты процесса в качестве ответа.

    - [Загрузка состояний Terraform в Yandex Object Storage](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage)
    - [Блокировка состояний Terraform с помощью Yandex Managed Service for YDB](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-lock)

    ```shell
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/05/src$ terraform init -backend-config="/home/odv/.secret/ya-tf-sa-keys"

    Initializing the backend...
    Do you want to copy existing state to the new backend?
    Pre-existing state was found while migrating the previous "local" backend to the
    newly configured "s3" backend. No existing state was found in the newly
    configured "s3" backend. Do you want to copy this state to the new "s3"
    backend? Enter "yes" to copy and "no" to start with an empty state.

    Enter a value: yes


    Successfully configured the backend "s3"! Terraform will automatically
    use this backend unless the backend configuration changes.
    Initializing modules...

    Initializing provider plugins...
    - Reusing previous version of yandex-cloud/yandex from the dependency lock file
    - Reusing previous version of hashicorp/template from the dependency lock file
    - Using previously-installed hashicorp/template v2.2.0
    - Using previously-installed yandex-cloud/yandex v0.149.0

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

3. Закоммитьте в ветку 'terraform-05' все изменения.
4. Откройте в проекте terraform console, а в другом окне из этой же директории попробуйте запустить terraform apply.
5. Пришлите ответ об ошибке доступа к state.

    ```shell
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/05/src$ terraform apply
    ╷
    │ Error: Error acquiring the state lock
    │ 
    │ Error message: operation error DynamoDB: PutItem, https response error StatusCode: 400, RequestID: 0f4996e8-106a-46b7-9fbd-24ca96589f09, ConditionalCheckFailedException: Condition not satisfied
    │ Lock Info:
    │   ID:        080c1051-8b3c-6463-56d8-f0601a2e4585
    │   Path:      tfstate-develop-08082025/terraform.tfstate
    │   Operation: OperationTypeInvalid
    │   Who:       odv@matebook16s
    │   Version:   1.8.4
    │   Created:   2025-08-08 13:01:15.492002196 +0000 UTC
    │   Info:      
    │ 
    │ 
    │ Terraform acquires a state lock to protect the state from being written
    │ by multiple users at the same time. Please resolve the issue above and try
    │ again. For most commands, you can disable locking with the "-lock=false"
    │ flag, but this is not recommended.
    ```
6. Принудительно разблокируйте state. Пришлите команду и вывод.

    ```shell
    odv@matebook16s:~/projects/MY/DevOpsCourse/ter-homeworks/05/src$ terraform force-unlock 080c1051-8b3c-6463-56d8-f0601a2e4585
    Do you really want to force-unlock?
    Terraform will remove the lock on the remote state.
    This will allow local Terraform commands to modify this state, even though it
    may still be in use. Only 'yes' will be accepted to confirm.

    Enter a value: yes

    Terraform state has been successfully unlocked!

    The state has been unlocked, and Terraform commands should now be able to
    obtain a new lock on the remote state.
    ```

------
### Задание 3  

1. Сделайте в GitHub из ветки 'terraform-05' новую ветку 'terraform-hotfix'.
2. Проверье код с помощью tflint и checkov, исправьте все предупреждения и ошибки в 'terraform-hotfix', сделайте коммит.

    - [Checkov policy index - all](https://www.checkov.io/5.Policy%20Index/all.html)
     
3. Откройте новый pull request 'terraform-hotfix' --> 'terraform-05'. 
4. Вставьте в комментарий PR результат анализа tflint и checkov, план изменений инфраструктуры из вывода команды terraform plan.
5. Пришлите ссылку на PR для ревью. Вливать код в 'terraform-05' не нужно.

------
### Задание 4

1. Напишите переменные с валидацией и протестируйте их, заполнив default верными и неверными значениями. Предоставьте скриншоты проверок из terraform console. 

- type=string, description="ip-адрес" — проверка, что значение переменной содержит верный IP-адрес с помощью функций cidrhost() или regex(). Тесты:  "192.168.0.1" и "1920.1680.0.1";
- type=list(string), description="список ip-адресов" — проверка, что все адреса верны. Тесты:  ["192.168.0.1", "1.1.1.1", "127.0.0.1"] и ["192.168.0.1", "1.1.1.1", "1270.0.0.1"].

## Дополнительные задания (со звёздочкой*)

**Настоятельно рекомендуем выполнять все задания со звёздочкой.** Их выполнение поможет глубже разобраться в материале.   
Задания со звёздочкой дополнительные, не обязательные к выполнению и никак не повлияют на получение вами зачёта по этому домашнему заданию. 
------
### Задание 5*
1. Напишите переменные с валидацией:
- type=string, description="любая строка" — проверка, что строка не содержит символов верхнего регистра;
- type=object — проверка, что одно из значений равно true, а второе false, т. е. не допускается false false и true true:
```
variable "in_the_end_there_can_be_only_one" {
    description="Who is better Connor or Duncan?"
    type = object({
        Dunkan = optional(bool)
        Connor = optional(bool)
    })

    default = {
        Dunkan = true
        Connor = false
    }

    validation {
        error_message = "There can be only one MacLeod"
        condition = <проверка>
    }
}
```
------
### Задание 6*

1. Настройте любую известную вам CI/CD-систему. Если вы ещё не знакомы с CI/CD-системами, настоятельно рекомендуем вернуться к этому заданию после изучения Jenkins/Teamcity/Gitlab.
2. Скачайте с её помощью ваш репозиторий с кодом и инициализируйте инфраструктуру.
3. Уничтожьте инфраструктуру тем же способом.


------
### Задание 7*
1. Настройте отдельный terraform root модуль, который будет создавать YDB, s3 bucket для tfstate и сервисный аккаунт с необходимыми правами. 

### Правила приёма работы

Ответы на задания и необходимые скриншоты оформите в md-файле в ветке terraform-05.

В качестве результата прикрепите ссылку на ветку terraform-05 в вашем репозитории.

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




