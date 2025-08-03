terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.8.4"
}

provider "yandex" {
  # token                    = "do not use!!!"
  cloud_id  = "b1g1baggs5tn33esd3gd"
  folder_id = "b1gg3ad99mhgfm5qo1tt"
  service_account_key_file = file("~/.secret/key.json")
  zone                     = "ru-central1-a" #(Optional) 
}
