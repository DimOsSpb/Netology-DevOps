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
  for_each = {
    for i, subnet in var.subnets : "${yandex_vpc_network.this.name}-${i}" => subnet
  }
  name           = each.key
  zone           = each.value.zone
  v4_cidr_blocks = [each.value.cidr]
  network_id     = yandex_vpc_network.this.id

  depends_on = [ yandex_vpc_network.this ]
}

