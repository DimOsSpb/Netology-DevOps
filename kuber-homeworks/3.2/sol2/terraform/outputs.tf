output "master_instances_info" {
  value = [
    for inst in yandex_compute_instance.k8s_master : {
      instance_name = inst.name
      external_ip   = inst.network_interface[0].nat_ip_address
      fqdn          = inst.fqdn
    }
  ]
}
output "workers_instances_info" {
  value = [
    for inst in yandex_compute_instance.k8s_worker : {
      instance_name = inst.name
      external_ip   = inst.network_interface[0].nat_ip_address
      fqdn          = inst.fqdn
    }
  ]
}