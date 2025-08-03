locals {
    res_list = concat (
        yandex_compute_instance.web,
        values(yandex_compute_instance.db)
    )
}

output "instances_info" {
  value = [
    for inst in local.res_list : {
      name = inst.name,
      id   = inst.id,
      fqdn = inst.fqdn
    }
  ]
}