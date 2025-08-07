

module "vpc_dev" {
  source = "./modules/vpc"
  name     = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
}

module "mysql" {
  source        = "./modules/mysql"
  name          = "sql-cluster"
  network_id    = module.vpc_dev.vpc_id
  subnets       = module.vpc_dev.subnets
  HA            = true

  depends_on = [ module.vpc_dev ]
}

module "mysql_db" {
  source        = "./modules/mysql_db"
  name = "test"
  cluster_id = module.mysql.cluster_id
  user = {
    name = "app"
    password = "password"
  }
}