
#https://terraform-provider.yandexcloud.net//resources/compute_instance.html#optional

resource "yandex_compute_instance" "db" {
  name                 = "db"
  platform_id          = "standard-v3"
  scheduling_policy {
    preemptible          = true
  }
  resources {
    cores              = 2
    memory             = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id         = var.image_id_debian12
    }
  }

  network_interface {
    subnet_id          = var.network_id
    nat                = true
  }

  metadata = {
    #ssh-keys = "${var.admin_name}:${file(var.ssh_public_key_path)}"    # не работает, если в образе пользователя нет!
    user-data = templatefile("cloud-init.tpl", {
        uname = "${var.admin_name}"
        key  = "${file(var.ssh_public_key_path)}"
    })
  }
}

# ==================================================================
# Код ниже требует наличия уже развернутой и запущеной vm.db
# И var.mysql_host_ip с установленым действительным ip
# Т.о. если инфраструктура еще не готова, закомментировать код виже


locals {
  docker_host    = "ssh://${var.admin_name}@${var.mysql_host_ip}:22"
}

provider "docker" {
  host = local.docker_host
  ssh_opts = ["-i", var.ssh_key_path, "-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

resource "random_password" "mysql_root_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "random_password" "mysql_user_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "docker_image" "mysql" {
  name         = "mysql:8"
  keep_locally = true
}

resource "docker_container" "mysql" {
  name  = "mysql8"
  image = docker_image.mysql.image_id

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_user_password.result}",
    "MYSQL_ROOT_HOST=%"
  ]

  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }

  depends_on = [docker_image.mysql, yandex_compute_instance.db]
}
