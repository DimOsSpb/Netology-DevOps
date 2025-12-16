# 
# CLOUD VARS
# ___________

variable "cloud_id" {
  type        = string
  default     = "b1g1baggs5tn33esd3gd"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gg3ad99mhgfm5qo1tt"
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
  description = "VPC network & subnet name"
}
variable "subnet_name" {
  type        = string
  default     = "develop_a"
  description = "VPC network & subnet name"
}

variable "yc_sa_file" {
  description = "Path to Yandex Cloud service account key JSON"
  type        = string
  sensitive   = true
}

#
# K8S CONFIG VARS
# _______________


variable "k8s_config" {
  description = "Full Kubernetes cluster configuration"

  type = object({
    # 
    # Глобальные параметры кластера
    # ──────────────────────────────
    name                    = string
    k8s_cluster_release     = string
    k8s_cluster_version     = string
    k8s_package_version     = string
    kubectl_version         = string
    helm_version            = string    
    pod_cidr                = string
    cri                     = string
    cni_plugin              = string
    control_plane_endpoint  = string

    cluster_init = bool
    admin_host_user = string
    config_folder = string

    # 
    # Группы нод
    # ───────────
    masters = object({
      instances     = number
      platform_id   = string
      cores         = number
      memory        = number
      core_fraction = number
      preemptible   = bool
      nat_enabled   = bool

      disk = object({
        family = string
        size   = number
        type   = string
      })

      metadata = map(string)
    })

    workers = object({
      instances     = number
      platform_id   = string
      cores         = number
      memory        = number
      core_fraction = number
      preemptible   = bool
      nat_enabled   = bool

      disk = object({
        family = string
        size   = number
        type   = string
      })

      metadata = map(string)
    })
  })

  default = {
    # 
    # Глобальные параметры
    # ────────────────────
    name = "NetologyK8S-1"
    k8s_cluster_release = "1.34"
    k8s_cluster_version  = "1.34.2"
    k8s_package_version  = "1.34.2-1.1"
    kubectl_version = "1.34.2"
    helm_version = "3.12.0"
    pod_cidr     = "10.244.0.0/16"
    cri          = "containerd"
    cni_plugin   = "calico"
    control_plane_endpoint = ""

    cluster_init = true
    admin_host_user = "odv"
    config_folder = "~/.kube"
    # 
    # Мастера
    # ────────
    masters = {
      instances     = 1
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 4 #Gb
      core_fraction = 20
      preemptible   = true
      nat_enabled   = true
      disk = {
        family = "ubuntu-2204-lts"
        size   = 20
        type   = "network-hdd"
      }
      metadata = {
        "serial-port-enable" = "1"
        "ssh-keys"           = ""
      }
    }

    # 
    # Воркеры
    # ────────
    workers = {
      instances     = 2
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 4
      core_fraction = 20
      preemptible   = true
      nat_enabled   = true
      disk = {
        family = "ubuntu-2204-lts"
        size   = 20
        type   = "network-hdd"
      }
      metadata = {
        "serial-port-enable" = "1"
        "ssh-keys"           = ""
      }
    }
  }
}



variable "k8s_ssh_key_file" {
  description = "SSH key for all nodes"
  type        = string
  sensitive   = true  
}

variable "k8s_ssh_private_key_file" {
  description = "SSH key for all nodes"
  type        = string
  sensitive   = true  
}