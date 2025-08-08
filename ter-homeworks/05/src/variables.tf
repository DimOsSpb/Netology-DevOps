###cloud vars
# variable "token" {
#   type        = string
#   description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
# }

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

# variable "default_cidr" {
#   type        = list(string)
#   default     = ["10.0.1.0/24"]
#   description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
# }

# variable "vpc_name" {
#   type        = string
#   default     = "develop"
#   description = "VPC network&subnet name"
# }

### 

variable "vms_platform_data" {
  type = object({
    user    = string,
    platform_id = string,
    ssh_key_path = string,
    ssh_priv_key_path = string,
    packages = list(string),
  })
  default = {
    user    = "ubuntu",
    platform_id = "standard-v3",
    ssh_key_path = "/home/odv/.ssh/netology.pub",
    ssh_priv_key_path = "/home/odv/.ssh/netology",
    packages = ["nginx"],

  }
}

variable "projects_data" {
  type = object({
    prefix = string,
    name_db = string,
    name_web = string,
    projects = list(string),  
  
  })
  default = {
    prefix  = "netology-develop-platform",
    name_db = "db",
    name_web  = "web",
    projects = ["marketing","analytics"]
  }
}

   
data "yandex_compute_image" "ubuntu" {
    family = "ubuntu-2404-lts"
}

data template_file "metadata" {
  template = file("${path.module}/cloud-config.yaml")

  vars = {
    username           = var.vms_platform_data.user
    ssh_public_key     = file(var.vms_platform_data.ssh_key_path)
    packages           = jsonencode(var.vms_platform_data.packages)
  }
}













