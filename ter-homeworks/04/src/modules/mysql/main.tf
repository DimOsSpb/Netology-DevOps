terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.8.4"
}

resource "yandex_mdb_mysql_cluster" "this" {
  name        = var.name
  environment = var.environment
  network_id  = var.network_id
  version     = var.ver

  resources {
    resource_preset_id = var.resource_preset_id
    disk_type_id       = var.disk_type
    disk_size          = var.disk_size
  }

  dynamic "host" {
    for_each = toset([for i in range(local.hosts_count) : i])
    
    content {
      zone      = local.available_subnets[host.key % length(local.available_subnets)].zone
      subnet_id = local.available_subnets[host.key % length(local.available_subnets)].id
      name      = "mysql-${tostring(host.key)}"  
    }
  }
}

locals {
  hosts_count = var.HA ? 2 : 1
  
  available_subnets = values(var.subnets)
}

data "yandex_vpc_network" "this" {
  network_id = var.network_id
}


resource "null_resource" "check_subnets_exist" {
  count = length(local.available_subnets) > 0 ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'ERROR: VPC must have at least one subnet' && exit 1"
  }
}
