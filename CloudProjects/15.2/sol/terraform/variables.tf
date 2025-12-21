# Yandex Cloud
#-------------

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

# Secrets
#---------------

variable "yc_sa_file" {
  description = "Path to Yandex Cloud service account key JSON"
  type        = string
  sensitive   = true
}

variable "host_user" {
  description = "User for hosts"
  type        = string
  sensitive   = true  
}

variable "ssh_key_file" {
  description = "SSH key for hosts"
  type        = string
  sensitive   = true  
}

variable "ssh_private_key_file" {
  description = "SSH key for hosts"
  type        = string
  sensitive   = true  
}


# Infrastructure
#---------------

variable "infra" {
  description = "Infrastructure description"

  type = object({

    # Define struct
    vpc_name = string

    # Subnets
    subnets = map(object({
      zone       = string
      cidr       = string
      is_public  = bool
    }))

    # Hosts

    hosts = map(object({
      platform_id   = optional(string, "standard-v3")
      cores         = optional(number, 2)
      memory        = optional(number, 2) #Gb
      core_fraction = optional(number, 20)
      preemptible   = optional(bool, true)
      nat_enabled   = optional(bool, true)
      internal_ip   = optional(string, null) 
      subnet = string
      is_nat_instance = optional(bool, false)
      security_groups = optional(list(string), [])

      disk = object({
        image_id = string
        size   = optional(number, 10)
        type   = optional(string, "network-hdd")
      })
      metadata = map(string)
    }))
  })

  default = {

    # Define values

    vpc_name = "netology-vpc"

    subnets = {
      "public-a" = {
        zone      = "ru-central1-a"
        cidr      = "192.168.10.0/24"
        is_public = true
      }
      "private-a" = {
        zone      = "ru-central1-a"
        cidr      = "192.168.20.0/24"
        is_public = false
      }
    }

    # - Host instances
    hosts = {
      "nat-gateway" = {
        subnet = "public-a"
        internal_ip = "192.168.10.254"
        disk = {
          image_id = "fd80mrhj8fl2oe87o4e1"  # NAT
          site = 5
        }
        metadata = {
          "serial-port-enable" = "1"
          "ssh-keys"           = ""
        }
      },
      "vm-pub1" = {
        subnet = "public-a"        
        disk = {
          image_id = "fd8umfn3mighedglnjue"  # Ubuntu 24.04 LTS         
        }
        metadata = {
          "serial-port-enable" = "1"
          "ssh-keys"           = ""
        }
      },
      "vm-priv1" = {
        subnet = "private-a"
        nat_enabled = true       
        disk = {
          image_id = "fd8umfn3mighedglnjue"  # Ubuntu 24.04 LTS         
        }
        metadata = {
          "serial-port-enable" = "1"
          "ssh-keys"           = ""
        }
      }         
    }


  }
}
