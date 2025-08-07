variable "name" {
  type        = string
  default     = ""
  description = "Input variable - cluster name"
}

variable "environment" {
  type        = string
  default     = "PRESTABLE"
  description = "Input variable - environment"
}

variable "ver" {
  type = string
  default = "8.0"
  description = "Input variable - version"
}

variable "HA" {
  type = bool
  default = true
  description = "Input variable - HA"
}

variable "cluster_size" {
  type = number
  default = 2
  description = "Input variable - cluster_size"
}

variable "resource_preset_id" {
  type = string
  default = "s2.micro"
  description = "Input variable - resource_preset_id"
}

variable "disk_type" {
  type        = string
  default     = "network-hdd"
  description = "Input variable - disk_type"
}

variable "disk_size" {
  type        = number
  default     = 10  # min 10Gb
  description = "Input variable - disk_size in gigabytes"
}

variable "network_id" {
  type        = string
  default     = ""
  description = "Input variable - vpc id"
  
  validation {
    condition     = length(var.network_id) > 0
    error_message = "VPC not defined"
  }
}

variable "subnets" {
  type = map(object({
    id   = string
    zone = string
  }))
  description = "Input variable - vpc subnets"
}













