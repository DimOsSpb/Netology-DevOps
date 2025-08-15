resource "yandex_vpc_network" "net" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "subnet" {
  name           = var.subnet_name_a
  zone           = var.zone_a
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = var.default_cidr
}

data "yandex_compute_image" "image" {
  family = var.vm_yandex_compute_image
}

// надо сделать через loop в этом ресурсе установку и "vector" 
resource "yandex_compute_instance" "platform" {
  for_each = local.host_instances

  name        = each.value.host_name
  platform_id = each.value.platform_id
  allow_stopping_for_update = true          # !!! 

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.image_id
      size = each.value.disk_size
      type = each.value.disk_type
    }
  }
  scheduling_policy {
    preemptible = each.value.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = each.value.nat_enabled
  }

  metadata = {
    serial-port-enable = 1
    # ssh-keys           = "${each.value.user_name}:${file("/home/odv/.ssh/netology.pub")}"
    user-data = data.template_file.metadata.rendered
  }
  labels = {
    service = each.value.service_name  
  }

}


