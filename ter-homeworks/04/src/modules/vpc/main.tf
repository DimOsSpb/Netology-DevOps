terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.8.4"
}

resource "yandex_vpc_network" "this" {
  name = var.name
}

resource "yandex_vpc_subnet" "this" {
  name           = var.name
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = var.cidr
}

