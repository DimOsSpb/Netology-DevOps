variable "course_name" {
  type        = string
  default     = "netology-develop-platform"
  description = "Course name"
}


# vms

variable "vms_resources" {

    description = "VMS resources"

    type = map(object({
        platform_id    = string,
        cores          = number,
        memory         = number,
        core_fraction  = number,
        preemptible    = bool,
        nat_enabled    = bool
    }))

    default = {
        k8s = {
            platform_id="standard-v3",
            cores=2,
            memory=4,
            core_fraction=20,
            preemptible=true,
            nat_enabled=true   
        }
    }
}

variable "vms_metadata" {

    description = "VMS metadata"

    type = map(object({
        serial-port-enable = number
        ssh-keys           = string
    }))

    default = {}
}

variable "vm_k8s_yandex_compute_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Compute Image"
}

variable "vm_k8s_platform_name" {
  type        = string
  default     = "k8s"
  description = "Name of instance"
}

variable "vm_k8s_user" {
  type        = string
  default     = "odv"
  description = "User name"
}



