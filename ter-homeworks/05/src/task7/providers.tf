terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    random = {
      source  = "hashicorp/random"
      version = "> 3.5"
    }
  }
  required_version = "~>1.8.4"
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1g1baggs5tn33esd3gd/etn3pbe89i9b259nqm5k"
    }
    bucket = "tfstate-develop-${random_string.unique_id.result}"
    region = "ru-central1"
    key = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  
    
    dynamodb_table = "tfstate-develop"
    
  }
}

provider "yandex" {
  #token     = var.token
  service_account_key_file = file("/home/odv/.secret/ya-tf-sa.json")
  
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}