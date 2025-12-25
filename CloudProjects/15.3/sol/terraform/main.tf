resource "yandex_vpc_network" "main" {
  name = var.infra.vpc_name
}
resource "yandex_vpc_subnet" "subnets" {
  for_each = var.infra.subnets
  
  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
  #route_table_id = each.value.is_public ? null : yandex_vpc_route_table.nat-instance-route.id

}

# Security groupes
# All traffic enabled on default
# resource "yandex_vpc_security_group" "public_sg" {
#   name       = "public"
#   network_id = yandex_vpc_network.main.id

#   egress {
#     protocol       = "ANY"
#     description    = "any"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     protocol       = "ANY"
#     description    = "any"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# All traffic disablen on default
# resource "yandex_vpc_security_group" "private_sg" {
#   name       = "private"
#   network_id = yandex_vpc_network.main.id

#   egress {
#     protocol       = "ANY"
#     description    = "any"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port = 0
#     to_port = 65535
#   }

#   ingress {
#     protocol       = "ANY"
#     description    = "any"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port = 0
#     to_port = 65535
#   }
# }


locals {
  # ssh_key = "${var.host_user}:${file(var.ssh_key_file)}"
  image_url = "https://storage.yandexcloud.net/${yandex_storage_bucket.b15.bucket}/${yandex_storage_object.file["jp1.jpg"].key}"

}

# KMS Key
resource "yandex_kms_symmetric_key" "bucket_key" {
  name = var.infra.KMS_backet.name
  description = var.infra.KMS_backet.description
  default_algorithm = var.infra.KMS_backet.default_algorithm
  rotation_period   = var.infra.KMS_backet.rotation_period
}

resource "yandex_storage_bucket" "b15" {
  bucket = var.infra.bucket.name
  max_size = var.infra.bucket.max_size
  anonymous_access_flags {
    read = true
    list = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }  
}

resource "yandex_storage_object" "file" {

  for_each = var.infra.bucket.objects
  
  bucket = yandex_storage_bucket.b15.bucket
  key    = each.key
  source = each.value.source
  content_type = each.value.content_type
}


# # Create Compute Instance Group
# data "yandex_iam_service_account" "sa" {
#   name = var.infra.IG.sa
# }

# resource "yandex_compute_instance_group" "group1" {
#   name                = var.infra.IG.name
#   service_account_id  = data.yandex_iam_service_account.sa.id
#   deletion_protection = false
#   instance_template {
#     hostname = "${var.infra.IG.host_name}-{instance.index}"
#     platform_id = var.infra.IG.platform_id
#     resources {
#       memory = var.infra.IG.memory
#       cores  = var.infra.IG.cores
#       core_fraction = var.infra.IG.core_fraction
#     }
#     boot_disk {
#       mode = "READ_WRITE"
#       initialize_params {
#         image_id = var.infra.IG.disk.image_id
#         size     = var.infra.IG.disk.size
#       }
#     }
#     network_interface {

#       subnet_ids = [yandex_vpc_subnet.subnets[var.infra.IG.subnet].id]
#     }
#     scheduling_policy {
#       preemptible = var.infra.IG.preemptible
#     }    

#     metadata = merge(
#       var.infra.IG.metadata,
#       { "ssh-keys" = local.ssh_key },
#       { "user-data" = templatefile(
#           "../files/cloud-init.yml.tpl",
#           {
#             image_url = local.image_url
#             ig_name = var.infra.IG.name
#             host_name = "${var.infra.IG.host_name}-{instance.index}"
#           }
#         )      
#     })
#   }

#   scale_policy {
#     fixed_scale {
#       size = var.infra.IG.scale_policy
#     }
#   }

#   allocation_policy {
#     zones = var.infra.IG.allocation_policy
#   }

#   deploy_policy {
#     max_unavailable = var.infra.IG.deploy_policy.max_unavailable
#     max_creating    = var.infra.IG.deploy_policy.max_creating
#     max_expansion   = var.infra.IG.deploy_policy.max_expansion
#     max_deleting    = var.infra.IG.deploy_policy.max_deleting
#     startup_duration = var.infra.IG.deploy_policy.startup_duration
#   }

#   # --- Only one LB ( NLB or ALB ) may be used -------------!!!

#   # load_balancer {
#   #   target_group_name = "${var.infra.IG.name}-nlb-tg"
#   # }

#   application_load_balancer {
#     target_group_name = "${var.infra.IG.name}-alb-tg"
#   }
 
#   health_check {
#     interval = var.infra.IG.health_check.interval
#     timeout  = var.infra.IG.health_check.timeout
#     healthy_threshold   = var.infra.IG.health_check.healthy_threshold
#     unhealthy_threshold = var.infra.IG.health_check.unhealthy_threshold
#     http_options {
#       port = var.infra.IG.health_check.http_options.port
#       path = var.infra.IG.health_check.http_options.path
#     }
#   }
# }

# --- NLB -------------------------------------------

# resource "yandex_lb_network_load_balancer" "lb" {
#   name = "${var.infra.IG.name}-nlb"

#   listener {
#     name        = "http"
#     port        = var.infra.IG.health_check.http_options.port

#     external_address_spec {
#       ip_version = "ipv4"
#     }
#   }

#   attached_target_group {
#     target_group_id = yandex_compute_instance_group.group1.load_balancer[0].target_group_id

#     healthcheck {
#       name = "http-check"

#       http_options {
#         port = var.infra.IG.health_check.http_options.port
#         path = var.infra.IG.health_check.http_options.path
       
#       }
#       interval            = var.infra.IG.lb_health_check.interval
#       timeout             = var.infra.IG.lb_health_check.timeout
#       healthy_threshold   = var.infra.IG.lb_health_check.healthy_threshold
#       unhealthy_threshold = var.infra.IG.lb_health_check.unhealthy_threshold      
#     }
#   }
# }


# # --- ALB -----------------------------------------------

# # ALB Backend Group

# resource "yandex_alb_backend_group" "abg" {
#   name      = "abg-1"
#   http_backend {
#     name = "http"
#     port = var.infra.IG.health_check.http_options.port
#     target_group_ids = [yandex_compute_instance_group.group1.application_load_balancer[0].target_group_id]
#     load_balancing_config {
#       #panic_threshold = 50
#       mode = "ROUND_ROBIN"
#     }
#     healthcheck {
#       healthcheck_port = var.infra.IG.health_check.http_options.port
#       interval = "${var.infra.IG.health_check.interval}s"
#       timeout  = "${var.infra.IG.health_check.timeout}s"
#       healthy_threshold   = var.infra.IG.lb_health_check.healthy_threshold
#       unhealthy_threshold = var.infra.IG.lb_health_check.unhealthy_threshold        
#       http_healthcheck {
#         path = "/"
#       }
#     }    
#   }
# }

# # Router
# resource "yandex_alb_http_router" "main" {
#   name = "${var.infra.IG.name}-alb-router"
# }

# # Virtual Host
# resource "yandex_alb_virtual_host" "api_host" {
#   name           = "api-host"
#   http_router_id = yandex_alb_http_router.main.id
#   #authority      = ["api.example.com"]
  
#   route {
#     name = "rh1"
#     http_route {
#       http_match {
#         path { exact = "/" }
#       }
#       http_route_action {
#         backend_group_id = yandex_alb_backend_group.abg.id
#       }
#     }
#   }
# }

# # ALB
# resource "yandex_alb_load_balancer" "alb" {
#   name = "${var.infra.IG.name}-alb"
#   network_id = yandex_vpc_network.main.id

#   allocation_policy {
#     location {
#       zone_id   = yandex_vpc_subnet.subnets[var.infra.IG.subnet].zone
#       subnet_id = yandex_vpc_subnet.subnets[var.infra.IG.subnet].id
#     }
#   }

#   listener {
#     name = "http-listener"
#     endpoint {
#       address {
#         external_ipv4_address {
#         }
#       }      
#       ports = [var.infra.IG.lb_health_check.http_options.port]
#     }
#     http {
#       handler {
#         http_router_id = yandex_alb_http_router.main.id
#       }
#     }
#   }
# }

