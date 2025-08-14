variable "course_name" {
  type        = string
  default     = "netology-develop-platform"
  description = "Course name"
}


# vm_web

variable "vms_resources" {

    description = "VMS resources"

    type = map(object({
        platform_id    = string,
        platform_name    = string,
        
        cores          = number,
        memory         = number,
        disk_size      = number,                    # Размер системного диска в ГБ
        disk_type      = string,
        core_fraction  = number,
        preemptible    = bool,
        nat_enabled    = bool
    }))

    default = {
        clickhouse = {
            platform_name = "clickhouse"
            platform_id = "standard-v3",
            disk_size     = 10,                     
            disk_type     = "network-hdd",
            cores=2,
            memory=1,
            core_fraction=20,
            preemptible=true,
            nat_enabled=true   
        },
        vector = {
            platform_name = "vector"
            platform_id = "standard-v3",
            disk_size     = 10,                     
            disk_type     = "network-hdd",
            cores=2,
            memory=1,
            core_fraction=20,
            preemptible=true,
            nat_enabled=true   
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
