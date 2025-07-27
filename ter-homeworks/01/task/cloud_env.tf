variable "folder_id" {
  type        = string
  description = "Cloud folder ID"
}
variable "network_id" {
  type        = string
  description = "Cloud network ID"
}
variable "image_id_debian12" {
  type        = string
  description = "Cloud debian 12 image id"
}
variable "admin_name" {
  type        = string
  description = "Cloud admin user name"
}
variable "mysql_host_ip" {
  type        = string
  description = "Адрес хоста для инициализации провайдера docker"
  default = "0.0.0.0"
}