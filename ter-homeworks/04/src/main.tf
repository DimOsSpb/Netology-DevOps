# resource "yandex_vpc_network" "develop" {
#   name = var.vpc_name
# }
# resource "yandex_vpc_subnet" "develop" {
#   name           = var.vpc_name
#   zone           = var.default_zone
#   network_id     = yandex_vpc_network.develop.id
#   v4_cidr_blocks = var.default_cidr
# }

module "vpc" {
  source = "./modules/vpc"
  name = var.vpc_name
  zone = var.default_zone
  cidr = var.default_cidr
  

}

module "vm-marketing" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  #env_name       = var.projects_data.projects[0]
  network_id     = module.vpc.vpc_id
  subnet_zones   = [var.default_zone]
  subnet_ids     = [module.vpc.subnet_id]
  instance_name  = var.projects_data.projects[0]
  instance_count = 1
  image_family   = data.yandex_compute_image.ubuntu.family
  public_ip      = true

  metadata =  {
    serial-port-enable = 1,
    user-data = data.template_file.metadata.rendered
  }


  labels = {
    project     = var.projects_data.projects[0]
  }
}

module "vm-analytics" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  #env_name       = var.projects_data.projects[1]
  network_id     = module.vpc.vpc_id
  subnet_zones   = [var.default_zone]
  subnet_ids     = [module.vpc.subnet_id]
  instance_name  = var.projects_data.projects[1]
  instance_count = 1
  image_family   = data.yandex_compute_image.ubuntu.family
  public_ip      = true

  metadata =  {
    serial-port-enable = 1,
    user-data = data.template_file.metadata.rendered
  }


  labels = {
    project     = var.projects_data.projects[1]
  }
}