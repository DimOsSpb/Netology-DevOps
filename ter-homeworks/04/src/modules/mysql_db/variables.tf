variable "name" {
  type        = string
  default     = ""
  description = "Input variable - db name"
  validation {
    condition     = length(var.name) > 0
    error_message = "Database name must not be empty"
  }
}

variable "cluster_id" {
  type        = string
  default     = ""
  description = "Input variable - mysql cluster id"
    validation {
    condition     = length(var.cluster_id) > 0
    error_message = "MySql cluster id must not be empty"
  }
}

variable "user" {
  type = object({
    name = string
    password = string
  })
  default = {
    name = "user"
    password = "password"
  }
  description = "Input variable - user"
}















