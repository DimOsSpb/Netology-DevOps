
variable "db_vms" {
    type = list(object({
        name     = string,
        cpu         = number,
        ram         = number,
        disk_size = number,
    }))
    default = [
        {
        name     = "main",
        cpu         = 4,
        ram         = 8,
        disk_size   = 30
        },
        {
        name     = "replica",
        cpu         = 2,
        ram         = 4,
        disk_size   = 20
        }
    ]
}

resource "yandex_compute_instance" "db" {
    for_each = { for item in var.db_vms : item.name => item }

    name = "${var.course_name}-db-${each.value.name}"

    platform_id = var.vms_platform_data.default.platform_id
    zone        = var.default_zone

    resources {
        cores  = each.value.cpu
        memory = each.value.ram
    }

    boot_disk {
        initialize_params {
        image_id = data.yandex_compute_image.ubuntu.image_id
        size     = each.value.disk_size
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.develop.id
        security_group_ids = [yandex_vpc_security_group.example.id]
        nat       = true
    }

    scheduling_policy {
        preemptible = true  # Для БД плохо, но у нас тест
    }

    metadata = local.vms_metadata
}