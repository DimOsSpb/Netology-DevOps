# Домашнее задание к занятию «Вычислительные мощности. Балансировщики нагрузки»  
---
>## Задание 1. Yandex Cloud 
>
>**Что нужно сделать**
>
>1. Создать бакет Object Storage и разместить в нём файл с картинкой:
>
> - Создать бакет в Object Storage с произвольным именем (например, _имя_студента_дата_).
> - Положить в бакет файл с картинкой.
> - Сделать файл доступным из интернета.
> 
>2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и веб-страницей, содержащей ссылку на картинку из бакета:
>
> - Создать Instance Group с тремя ВМ и шаблоном LAMP. Для LAMP рекомендуется использовать `image_id = fd827b91d99psvq5fjit`.
> - Для создания стартовой веб-страницы рекомендуется использовать раздел `user_data` в [meta_data](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata).
> - Разместить в стартовой веб-странице шаблонной ВМ ссылку на картинку из бакета.
> - Настроить проверку состояния ВМ.
> 
>3. Подключить группу к сетевому балансировщику:
>
> - Создать сетевой балансировщик.
> - Проверить работоспособность, удалив одну или несколько ВМ.
>4. (дополнительно)* Создать Application Load Balancer с использованием Instance group и проверкой состояния.

---
## Решение


---

### Полезные документы:

#### Yandex Cloud
- [Compute instance group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance_group).
- [Network Load Balancer](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer).
- [Группа ВМ с сетевым балансировщиком](https://cloud.yandex.ru/docs/compute/operations/instance-groups/create-with-balancer).

#### AWS
- [S3 bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [Launch Template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template).
- [Autoscaling group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group).
- [Launch configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration).