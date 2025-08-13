output "instances_info" {
  value = [
    for inst in yandex_compute_instance.platform : {
      instance_name = inst.name
      external_ip   = try(inst.network_interface[0].nat_ip_address, "")
      fqdn          = inst.fqdn
    }
  ]
}