resource "yandex_vpc_network" "k8s_network" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = var.subnet_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.k8s_network.id 
  v4_cidr_blocks = var.default_cidr
}


locals {
  user = "ubuntu"
  master = var.k8s_config.masters
  worker = var.k8s_config.workers  
  k8s_ssh_key = "${local.user}:${file(var.k8s_ssh_key_file)}"
  masters_ips = [for m in yandex_compute_instance.k8s_master : m.network_interface[0].nat_ip_address]
  workers_ips = [for w in yandex_compute_instance.k8s_worker : w.network_interface[0].nat_ip_address]
  masters_internal_ips = [for m in yandex_compute_instance.k8s_master : m.network_interface[0].ip_address]
  workers_internal_ips = [for w in yandex_compute_instance.k8s_worker : w.network_interface[0].ip_address]

}

data "yandex_compute_image" "ubuntu" {
  family = local.master.disk.family
}

# Masters

resource "yandex_compute_instance" "k8s_master" {
  count       = local.master.instances
  name        = "master-${count.index + 1}"

  platform_id = local.master.platform_id

  resources {
    cores         = local.master.cores
    memory        = local.master.memory
    core_fraction = local.master.core_fraction
  }

  scheduling_policy {
    preemptible = local.master.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = local.master.disk.size
      type         = local.master.disk.type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s_subnet.id
    nat       = local.master.nat_enabled
  }

  metadata = merge(
    local.master.metadata,
    { "ssh-keys" = local.k8s_ssh_key }
  )
}

# Workers

resource "yandex_compute_instance" "k8s_worker" {
  count       = local.worker.instances
  name        = "worker-${count.index + 1}"

  platform_id = local.worker.platform_id

  resources {
    cores         = local.worker.cores
    memory        = local.worker.memory
    core_fraction = local.worker.core_fraction
  }

  scheduling_policy {
    preemptible = local.worker.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = local.worker.disk.size
      type         = local.worker.disk.type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s_subnet.id
    nat       = local.worker.nat_enabled
  }

  metadata = merge(
    local.worker.metadata,
    { "ssh-keys" = local.k8s_ssh_key }
  )
}



resource "local_file" "ansible_inventory_yaml" {
  content  = templatefile("${path.module}/inventory.yml.tpl", {
    ssh_user = local.user
    ssh_private_key_file = var.k8s_ssh_private_key_file
    masters = local.masters_ips
    workers = local.workers_ips
    masters_ips = local.masters_ips
    workers_ips = local.workers_ips
    masters_internal_ips = local.masters_internal_ips
    workers_internal_ips = local.workers_internal_ips
  })
  filename = "${path.module}/../kubespray/inventory/ha-cluster/hosts.yaml"
}

# resource "local_file" "ansible_vars_all" {
#   content  = templatefile("${path.module}/all.yml.tpl", {
#     cluster_name = var.k8s_config.name
#     cluster_init = var.k8s_config.cluster_init
#     k8s_cluster_release = var.k8s_config.k8s_cluster_release
#     k8s_cluster_version = var.k8s_config.k8s_cluster_version
#     k8s_package_version = var.k8s_config.k8s_package_version
#     kubectl_version = var.k8s_config.kubectl_version
#     helm_version = var.k8s_config.helm_version
#     pod_cidr = var.k8s_config.pod_cidr
#     cri = var.k8s_config.cri  
#     admin_host_user = var.k8s_config.admin_host_user
#     config_folder = var.k8s_config.config_folder

#   })
#   filename = "${path.module}/../ansible/group_vars/all.yml"
# }

# resource "null_resource" "ansible_provision" {
#   depends_on = [
#     yandex_compute_instance.k8s_master,
#     yandex_compute_instance.k8s_worker,
#     local_file.ansible_inventory_yaml
#   ]
  
#   triggers = {
#     always_run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "ansible-playbook -i ../ansible/inventory.yml ../ansible/site.yml -K"
#   }
# }
