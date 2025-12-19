resource "yandex_vpc_network" "main" {
  name = var.infra.vpc_name
}
resource "yandex_vpc_subnet" "subnets" {
  for_each = var.infra.subnets
  
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
  #route_table_id = each.value.is_public ? null : yandex_vpc_route_table.nat-instance-route.id

}

# Security groupes
# All traffic enabled on default
resource "yandex_vpc_security_group" "public_sg" {
  name       = "public"
  network_id = yandex_vpc_network.main.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# All traffic disablen on default
resource "yandex_vpc_security_group" "private_sg" {
  name       = "private"
  network_id = yandex_vpc_network.main.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }
}

# Static route to NAT instance for private subnet

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.main.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.infra.hosts["nat-gateway"].internal_ip
  }
}

locals {
  ssh_key = "${var.host_user}:${file(var.ssh_key_file)}"
}

# Instances

resource "yandex_compute_instance" "hosts" {
  for_each = var.infra.hosts
  
  name        = each.key
  platform_id = each.value.platform_id
  zone = yandex_vpc_subnet.subnets[each.value.subnet].zone

  allow_stopping_for_update = true

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }

  scheduling_policy {
    preemptible = each.value.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = each.value.disk.image_id
      size = each.value.disk.size
      type = each.value.disk.type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnets[each.value.subnet].id
    nat       = each.value.nat_enabled
    ip_address = try(each.value.internal_ip, null)
    security_group_ids = var.infra.subnets[each.value.subnet].is_public == true ? [yandex_vpc_security_group.public_sg.id] : [yandex_vpc_security_group.private_sg.id]
  }

  metadata = merge(
    each.value.metadata,
    { "ssh-keys" = local.ssh_key }
  )
}




