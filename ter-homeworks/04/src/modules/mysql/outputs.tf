# output "name" {
#   value = yandex_vpc_network.this.name
# }

# output "zone" {
#   value = yandex_vpc_subnet.this.zone
# }

# output "cidr" {
#   value = [for s in yandex_vpc_subnet.this : s.v4_cidr_blocks]
# }

output "cluster_id" {
  value = yandex_mdb_mysql_cluster.this.id
}

# output "subnet_id" {
#   value = yandex_vpc_subnet.this.id
# }

# output "subnet_ids" {
#   value = [for s in yandex_vpc_subnet.this : s.id]
# }

# output "subnet_zones" {
#   value = [for s in yandex_vpc_subnet.this : s.zone]
# }