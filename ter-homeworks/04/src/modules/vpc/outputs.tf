output "name" {
  value = yandex_vpc_network.this.name
}

output "cidr" {
  value = [for s in yandex_vpc_subnet.this : s.v4_cidr_blocks]
}

output "vpc_id" {
  value = yandex_vpc_network.this.id
}

output "subnet_ids" {
  value = [for s in yandex_vpc_subnet.this : s.id]
}

output "subnet_zones" {
  value = [for s in yandex_vpc_subnet.this : s.zone]
}

output "subnets" {
  value = {
    for s in yandex_vpc_subnet.this : s.name => {
      id   = s.id
      zone = s.zone
    }
  }
}