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

variable "db" {
  type = object({
    user = string
    password = string
  })
  description = "DB secret"
  sensitive   = true
}

# Infrastructure
#---------------

variable "infra" {
  description = "Infrastructure description"

  type = object({

    vpc_name = string
    subnets = object({
      private = map(object({
        zone       = string
        cidr       = string
        is_public  = bool
      }))
      public = map(object({
        zone       = string
        cidr       = string
        is_public  = bool
      }))
      admins = map(object({
        cidr       = string
      }))
      k8s = map(object({
        cidr       = string
      }))

    })


    KMS_key = object({
      name = string
      description = optional(string)
      default_algorithm = string
      # rotation_period   = string     
    })

  })

  default = {

    # Define values

    vpc_name = "vpc-15w4"

    subnets = {
      public = {
        a = {
          zone      = "ru-central1-a"
          cidr      = "10.0.21.0/24"
          is_public = true
        }
        b = {
          zone      = "ru-central1-b"
          cidr      = "10.0.22.0/24"
          is_public = true
        }
        d = {
          zone      = "ru-central1-d"
          cidr      = "10.0.23.0/24"
          is_public = true
        }    
      }
      private = {        
        a = {
          zone      = "ru-central1-a"
          cidr      = "10.0.11.0/24"
          is_public = false
        }
        b = {
          zone      = "ru-central1-b"
          cidr      = "10.0.12.0/24"
          is_public = false
        }   
      }
      admins = {
        a1 = {
          cidr = "45.136.247.248/32"
        }
      } 
      k8s = {
        pods = {
          cidr = "10.112.0.0/16"
        }
        service = {
          cidr = "10.96.0.0/16"
        }        
      }       
    }

    KMS_key = {
      name = "key"
      description = "encription key"
      default_algorithm = "AES_128"
      #rotation_period   = "2160h" # 90 days         
    }

  }
}
