variable "yc_service_account_key_path" {
  type        = string
  sensitive   = true
  description = "Path to the service account key file."
}
variable "ssh_public_key_path" {
  type        = string
  sensitive   = true
  description = "Path to the public ssh key file."
}
variable "ssh_key_path" {
  type        = string
  sensitive   = true
  description = "Path to the ssh key file."
}