# output "instances_info" {
#   value = [
#     for inst in yandex_compute_instance.hosts: {
#       instance_name = inst.name
#       external_ip   = inst.network_interface[0].nat_ip_address
#       fqdn          = inst.fqdn
#     }
#   ]
# }
