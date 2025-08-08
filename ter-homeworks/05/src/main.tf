# resource "yandex_vpc_network" "develop" {
#   name = var.vpc_name
# }
# resource "yandex_vpc_subnet" "develop" {
#   name           = var.vpc_name
#   zone           = var.default_zone
#   network_id     = yandex_vpc_network.develop.id
#   v4_cidr_blocks = var.default_cidr
# }


module "vpc_prod" {
  source = "./modules/vpc"
  name     = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-d", cidr = "10.0.3.0/24" },   # ru-central1-c - НЕТ!
  ]
}

module "vpc_dev" {
  source = "./modules/vpc"
  name     = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
}

module "vm-marketing" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=4d05fab828b1fcae16556a4d167134efca2fccf2" # commit hash ver 1.0.0
  env_name       = "prod"
  network_id     = module.vpc_prod.vpc_id
  subnet_zones   = [module.vpc_prod.subnet_zones[0]]
  subnet_ids     = [module.vpc_prod.subnet_ids[0]]
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

  depends_on = [ module.vpc_prod ]
}

module "vm-analytics" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=4d05fab828b1fcae16556a4d167134efca2fccf2"
  env_name       = "prod"
  network_id     = module.vpc_prod.vpc_id
  subnet_zones   = [module.vpc_prod.subnet_zones[0]]
  subnet_ids     = [module.vpc_prod.subnet_ids[0]]
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

  depends_on = [ module.vpc_prod ]
}