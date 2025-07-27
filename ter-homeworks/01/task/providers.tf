terraform {
  required_providers {
    yandex = {
      source = "registry.terraform.io/yandex-cloud/yandex"
      version = "~> 0.87"
    }
    docker = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = "3.6.2"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-a"
  folder_id = var.folder_id
  service_account_key_file = var.yc_service_account_key_path
}
