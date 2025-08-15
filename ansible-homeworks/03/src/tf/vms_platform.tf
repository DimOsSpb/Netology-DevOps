variable "course_name" {
  type        = string
  default     = "netology-develop-platform"
  description = "Course name"
}


# vm_web

locals {
  host_instances = merge([
    for service_name, service in var.services : {
      for idx, host in service.hosts :  
        "${service_name}-${idx}" => merge(host, {
        host_name    = "${service_name}-${idx + 1}"  
        service_name = service_name
        node_index   = idx  
      })
    }
  ]...)
}

variable "services" {

  description = "VMS resources"

  type = map(object({
      
      hosts = list(object({
        platform_id    = string,
        cores          = number,
        memory         = number,
        disk_size      = number,                    # Размер системного диска в ГБ
        disk_type      = string,
        core_fraction  = number,
        preemptible    = bool,
        nat_enabled    = bool
    }))
  }))

  default = {
    clickhouse = {
      hosts = [
        {
          platform_id = "standard-v3",
          platform_name = "clickhouse"
          platform_id = "standard-v3",
          disk_size     = 10,                     
          disk_type     = "network-hdd",
          cores=2,
          memory=2,
          core_fraction=20,
          preemptible=true,
          nat_enabled=true
        }
      ]   
    },
    lighthouse = {
      hosts = [
        {
          platform_name = "lighthouse"
          platform_id = "standard-v3",
          disk_size     = 10,                     
          disk_type     = "network-hdd",
          cores=2,
          memory=2,
          core_fraction=20,
          preemptible=true,
          nat_enabled=true
        }  
      ] 
    },
    vector = {
      hosts = [
        {
          platform_name = "vector"
          platform_id = "standard-v3",
          disk_size     = 10,                     
          disk_type     = "network-hdd",
          cores=2,
          memory=2,
          core_fraction=20,
          preemptible=true,
          nat_enabled=true
        }
      ]
    }
  }
}

variable "vm_yandex_compute_image" {
  type        = string
  default     = "debian-12"
  description = "Compute Image"
}

data template_file "metadata" {
  template = file("${path.module}/cloud-config.yaml")

  vars = {
    username           = "odv"
    ssh_public_key     = file("/home/odv/.ssh/netology.pub")

  }
}

locals {
  instances_info = [
    for inst in yandex_compute_instance.platform : {
      service_name  = inst.labels.service
      instance_name = inst.name
      external_ip   = try(inst.network_interface[0].nat_ip_address, "")
    }
  ]
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    instances = local.instances_info 
  })
  filename = "${abspath("${path.module}/../playbook/inventory/prod.yml")}"
}