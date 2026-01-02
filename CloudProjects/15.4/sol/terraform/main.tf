resource "yandex_vpc_network" "main" {
  name = var.infra.vpc_name
}
resource "yandex_vpc_subnet" "public" {
  for_each = var.infra.subnets.public
  
  name           = "public-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]

}
resource "yandex_vpc_subnet" "private" {
  for_each = var.infra.subnets.private
  
  name           = "private-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
  route_table_id = each.value.is_public ? null : yandex_vpc_route_table.internet.id

}

# --- NAT Gateway для приватных сетей - обновление, образы... -------------------

resource "yandex_vpc_gateway" "nat" {
  name = "nat-gateway"

  shared_egress_gateway {}
}
resource "yandex_vpc_route_table" "internet" {
  name       = "internet"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

# --- Security groups -------------------------------------------------------------

resource "yandex_vpc_security_group" "mysql" {
  name       = "mysql"
  network_id = yandex_vpc_network.main.id

  ingress {
    description = "Allow MySQL from K8s"
    protocol    = "TCP"
    port        = 3306
    security_group_id = yandex_vpc_security_group.k8s_nodes.id
  }
}


resource "yandex_vpc_security_group" "k8s_core" {
  name       = "k8s-core"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = concat(
      [for subnet in values(var.infra.subnets.public)  : subnet.cidr],
      [for subnet in values(var.infra.subnets.private) : subnet.cidr]
    )
  }

  # Pod CIDR
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = [var.infra.subnets.k8s.service.cidr]
    description    = "Pod - Pod / Pod - Service"
  }
  # Service CIDR
  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = [var.infra.subnets.k8s.pods.cidr]
    description    = "Pod - ClusterIP Service"
  }
  # Pod CIDR
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = [var.infra.subnets.k8s.service.cidr]
    description    = "Pod - Pod / Pod - Service"
  }
  # Service CIDR
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = [var.infra.subnets.k8s.pods.cidr]
    description    = "Pod - ClusterIP Service"
  }

  ingress {
    protocol          = "ANY"
    predefined_target = "self_security_group" # Трафик внутри этой SG 
  }
  ingress {
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }    
  egress {
    protocol          = "ANY"
    predefined_target = "self_security_group" # Трафик внутри этой SG
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "yandex_vpc_security_group" "k8s_cluster" {
  name       = "k8s-cluster"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol = "TCP"
    port = 443
    v4_cidr_blocks = [for subnet in values(var.infra.subnets.admins) : subnet.cidr]
  }
  ingress {
    protocol = "TCP"
    port = 6443
    v4_cidr_blocks = [for subnet in values(var.infra.subnets.admins) : subnet.cidr]
  }
}
resource "yandex_vpc_security_group" "k8s_nodes" {
  name       = "k8s-nodes"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol          = "TCP"
    from_port         = 30000
    to_port           = 32767
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}


locals {
  #  ssh_key = "${var.host_user}:${file(var.ssh_key_file)}"
   k8s_version     = "1.32"

}



# --- MySQL resources... ----------------------------------------------------

resource "yandex_mdb_mysql_database" "db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "netology_db"
}

resource "yandex_mdb_mysql_user" "my_user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = var.db.user
  password   = var.db.password

  permission {
    database_name = yandex_mdb_mysql_database.db.name
    roles         = ["ALL"]
  }

  permission {
    database_name = yandex_mdb_mysql_database.db.name
    roles         = ["ALL", "INSERT"]
  }

  global_permissions = ["PROCESS"]

  authentication_plugin = "SHA256_PASSWORD"
}

resource "yandex_mdb_mysql_cluster" "mysql" {
  name = "MySQL"
  version = "8.0"
  environment          = "PRESTABLE"
  network_id           = yandex_vpc_network.main.id
  deletion_protection  = true

  security_group_ids = [
    yandex_vpc_security_group.mysql.id
  ]

  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours = 23
    minutes  = 59
  }

  # https://yandex.cloud/ru/docs/managed-mysql/concepts/instance-types
  resources {
    resource_preset_id = "b1.medium" # Intel Broadwell с производительностью 50% CPU
    disk_type_id       = "network-hdd"    
    disk_size          = 20
  }

  host {
    zone            = yandex_vpc_subnet.private["a"].zone
    subnet_id       = yandex_vpc_subnet.private["a"].id
    assign_public_ip = false

  }

  host {
    zone            = yandex_vpc_subnet.private["b"].zone
    subnet_id       = yandex_vpc_subnet.private["b"].id
    assign_public_ip = false
    priority = 1

  }

}

# --- K8S cluster --------------------------------------------------------

# KMS Key
resource "yandex_kms_symmetric_key" "key" {
  name = var.infra.KMS_key.name
  description = var.infra.KMS_key.description
  default_algorithm = var.infra.KMS_key.default_algorithm
  # rotation_period   = var.infra.KMS_key.rotation_period
}

resource "yandex_kms_symmetric_key_iam_binding" "kms_binding" {
  symmetric_key_id = yandex_kms_symmetric_key.key.id
  role   = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${yandex_iam_service_account.k8s.id}"
  ]
}

resource "yandex_iam_service_account" "k8s" {
  name = "k8s-sa"
}
resource "yandex_resourcemanager_folder_iam_member" "k8s_roles" {
  for_each = toset([
    "k8s.clusters.agent",
    "kms.keys.encrypterDecrypter",
    "load-balancer.admin",
    "vpc.admin",
    "logging.writer",
    "editor"
    # "container-registry.images.puller"
    
  ])

  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s.id}"
}
resource "time_sleep" "wait_iam" {
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_roles,
    yandex_kms_symmetric_key.key
  ]
  create_duration = "20s"
}

resource "yandex_kubernetes_cluster" "k8s" {
  name       = "k8s"
  release_channel = "STABLE" 
  network_id = yandex_vpc_network.main.id
  network_policy_provider = "CALICO"
  service_account_id      = yandex_iam_service_account.k8s.id
  node_service_account_id = yandex_iam_service_account.k8s.id

  cluster_ipv4_range = var.infra.subnets.k8s.pods.cidr
  service_ipv4_range = var.infra.subnets.k8s.service.cidr

  kms_provider {
    key_id = yandex_kms_symmetric_key.key.id
  }  

  master {
      version = local.k8s_version  
      public_ip = true
      security_group_ids = [
        yandex_vpc_security_group.k8s_core.id,
        yandex_vpc_security_group.k8s_cluster.id
      ]
      
      master_logging {
        enabled                    = true
        # log_group_id               = yandex_logging_group.log_group_resoruce_name.id
        kube_apiserver_enabled     = true
        cluster_autoscaler_enabled = true
        events_enabled             = true
        audit_enabled              = true
      }  
      
      regional {
      region = "ru-central1"
      
      location {
        zone      = yandex_vpc_subnet.public["a"].zone
        subnet_id = yandex_vpc_subnet.public["a"].id
      }
      location {
        zone      = yandex_vpc_subnet.public["b"].zone
        subnet_id = yandex_vpc_subnet.public["b"].id
      }
      location {
        zone      = yandex_vpc_subnet.public["d"].zone
        subnet_id = yandex_vpc_subnet.public["d"].id
      }
    }
  }
  depends_on = [
    time_sleep.wait_iam
  ]

}


resource "yandex_kubernetes_node_group" "k8s_nodes_a" {
  name               = "k8s-nodes-a"
  version     = local.k8s_version
  cluster_id         = yandex_kubernetes_cluster.k8s.id

  instance_template {
    platform_id = "standard-v2"
    network_interface {
        nat        = false
        subnet_ids = [yandex_vpc_subnet.private["a"].id]
        security_group_ids = [
          yandex_vpc_security_group.k8s_core.id,
          yandex_vpc_security_group.k8s_nodes.id,
        ]
    }
    resources {
      core_fraction = 20
      memory = 4
      cores  = 2
    }
    scheduling_policy {
      preemptible = false
    }    
    boot_disk {
      type = "network-hdd"
      size = 35
    }
  }
  scale_policy {
    auto_scale {
      initial = 2
      min       = 2
      max       = 3
    }
  }
  allocation_policy {
    location {
      zone = yandex_vpc_subnet.private["a"].zone 
    }
  }

  depends_on = [
    yandex_kubernetes_cluster.k8s
  ]
}
resource "yandex_kubernetes_node_group" "k8s_nodes_b" {
  name               = "k8s-nodes-b"
  version     = local.k8s_version
  cluster_id         = yandex_kubernetes_cluster.k8s.id

  instance_template {
    platform_id = "standard-v2"
    network_interface {
        nat        = false
        subnet_ids = [yandex_vpc_subnet.private["b"].id]
        security_group_ids = [
          yandex_vpc_security_group.k8s_core.id,
          yandex_vpc_security_group.k8s_nodes.id,
        ]
    }
    resources {
      core_fraction = 20
      memory = 4
      cores  = 2
    }
    scheduling_policy {
      preemptible = false
    }    
    boot_disk {
      type = "network-hdd"
      size = 35
    }
  }
  scale_policy {
    auto_scale {
      initial = 1
      min       = 1
      max       = 3
    }
  }
  allocation_policy {
    location {
      zone = yandex_vpc_subnet.private["b"].zone 
    }
  }

  depends_on = [
    yandex_kubernetes_cluster.k8s
  ]
}

# --- MYSQL FQDN -> манифест -----------------------------------------------

resource "local_file" "mysqladmin_yaml" {
  content  = templatefile("${path.module}/mysqladmin.yml.tpl", {
    service_fqdn = yandex_mdb_mysql_cluster.mysql.host[0].fqdn
  })
  filename = "${path.module}/../k8s-manifests/mysqladmin.yml"
  depends_on = [
    yandex_mdb_mysql_cluster.mysql
  ]
}

