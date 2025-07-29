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
        cores          = number,
        memory         = number,
        core_fraction  = number,
        preemptible    = bool,
        nat_enabled    = bool
    }))

    default = {
        web = {
            platform_id="standard-v3",
            cores=2,
            memory=1,
            core_fraction=20,
            preemptible=true,
            #nat_enabled=true   # Для задания 9* убрали
            nat_enabled=false   # Для задания 9* установили
        },
        db = {
            platform_id="standard-v3",            
            cores=2,
            memory=2,
            core_fraction=20,
            preemptible=true,
            #nat_enabled=true   # Для задания 9* убрали
            nat_enabled=false   # Для задания 9* установили
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

variable "vm_web_yandex_compute_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Compute Image"
}

variable "vm_web_platform_name" {
  type        = string
  default     = "web"
  description = "Name of instance"
}

variable "vm_web_user" {
  type        = string
  default     = "ubuntu"
  description = "User name"
}

# variable "vm_web_serial_console_enable" {
#   type        = number
#   default     = 1
#   description = "Enable serial console access"
# }

# vm_db

variable "vm_db_platform_name" {
  type        = string
  default     = "db"
  description = "Id of platform"
}

variable "vm_db_platform_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "Zome of instance"
}

# variable "vm_db_user" {
#   type        = string
#   default     = "ubuntu"
#   description = "User name"
# }

# variable "vm_db_serial_console_enable" {
#   type        = number
#   default     = 1
#   description = "Enable serial console access"
# }