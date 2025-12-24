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

    # Instance group

    IG = object({
      name = string
      sa = string
      scale_policy = number
      allocation_policy = list(string)
      deploy_policy = object({
        max_unavailable = number
        max_creating    = number
        max_expansion   = number
        max_deleting    = number 
        startup_duration = number       
      })
      health_check = object({
        interval = number
        timeout  = number
        healthy_threshold   = number
        unhealthy_threshold = number

        http_options = object ({
          port = string
          path = string
        })
      })
      lb_health_check = object({
        interval = number
        timeout  = number
        healthy_threshold   = number
        unhealthy_threshold = number

        http_options = object ({
          port = string
          target_port = string
          path = string
        })
      })
      host_name = string
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
    })

    # Backets
    buckets = map(object({
      max_size = number
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

    IG = {
      name = "inst-gr1"
      sa = "sa-terraform"
      subnet = "public-a"
      host_name = "lamp"
      disk = {
        image_id = "fd827b91d99psvq5fjit"  # LAMP
        size = 10
      }
      metadata = {
        "serial-port-enable" = "1"
        "ssh-keys"           = ""
      }
      allocation_policy = ["ru-central1-a"]
      scale_policy = 3
      deploy_policy = {
        max_unavailable = 2
        max_creating    = 2
        max_expansion   = 2
        max_deleting    = 2
        startup_duration = 60       
      }  
      health_check = {
        interval = 4
        timeout  = 3
        healthy_threshold   = 3
        unhealthy_threshold = 3

        http_options = {
          port = 80
          path = "/"
        }
      }  
      lb_health_check = {
        interval = 4
        timeout  = 3
        healthy_threshold   = 3
        unhealthy_threshold = 3

        http_options = {
          port = 80
          target_port = 80
          path = "/"
        }
      }              
    }


    buckets = {
      "netology-hw15" = {
        max_size = 1073741824 #1Gib - max for free
      }
    }

  }
}
