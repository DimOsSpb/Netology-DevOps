terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.8.4"
}

resource "yandex_mdb_mysql_database" "this" {
  cluster_id = var.cluster_id
  name       = var.name
}

resource "yandex_mdb_mysql_user" "this" {
  cluster_id = var.cluster_id
  name       = var.user.name
  password   = var.user.password

  depends_on = [ yandex_mdb_mysql_database.this ]
}

