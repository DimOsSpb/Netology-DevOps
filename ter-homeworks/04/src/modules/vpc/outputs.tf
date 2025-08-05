output "name" {
  value = yandex_vpc_network.this.name
}

output "zone" {
  value = yandex_vpc_subnet.this.zone
}

output "cidr" {
  value = yandex_vpc_subnet.this.v4_cidr_blocks
}

output "vpc_id" {
  value = yandex_vpc_network.this.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.this.id
}