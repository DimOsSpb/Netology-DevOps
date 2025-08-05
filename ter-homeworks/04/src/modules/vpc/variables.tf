variable "name" {
  type        = string
  default     = ""
  description = "Input variable - vpc name"
}
variable "zone" {
  type        = string
  default     = ""
  description = "Input variable - cloud zone"
}

variable "cidr" {
  type = list(string)
  default = []
  description = "Input variable - cidr"
}
















