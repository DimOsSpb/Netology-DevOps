variable "name" {
  type        = string
  default     = ""
  description = "Input variable - vpc name"
}

variable "subnets" {
  type = list(object({
    zone = string,
    cidr = string
  })) 
  description = "Input variable - subnets"
}

















