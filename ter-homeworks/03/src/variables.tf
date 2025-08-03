###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

###

variable "course_name" {
  type        = string
  default     = "netology-develop-platform"
  description = "Course name"
}

### vms platform vars

variable "vms_platform_data" {
  type = map(object({
    image       = string,
    user        = string,
    platform_id = string, 
    ssh_key_path = string,
    ssh_priv_key_path = string,   
    }))
  default = {
    default   = {
      image   = "ubuntu-2004-lts",
      user    = "ubuntu",
      platform_id = "standard-v3",
      #ssh_key_path = "~/.secret/key.json",
      ssh_key_path = "/home/odv/.ssh/netology.pub"
      ssh_priv_key_path = "/home/odv/.ssh/netology"
    }
  }
  description = "Compute Image spec"
}
variable "vms_ssh_key" {
  type        = string
  default     = ""
  description = "ssh-keygen -t ed25519"
}

variable "vm_web_platform_name" {
  type        = string
  default     = "web"
  description = "Platforms ance"
}

variable "vm_db_platform_name" {
  type        = string
  default     = "db"
  description = "Base Id of db platform"
}

variable "vms_metadata"  {
  type  = object({
      serial-port-enable = number,
      ssh-keys = string
  })
  default = {
    serial-port-enable = 1
    ssh-keys           = ""   
  }
}

data "yandex_compute_image" "ubuntu" {
    family = var.vms_platform_data.default.image
}

locals {
  vms_metadata = {
    serial-port-enable = 1
    ssh-keys = "${var.vms_platform_data.default.user}:${file(var.vms_platform_data.default.ssh_key_path)}"
  }


}