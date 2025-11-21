resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.subnet_name_a
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id 
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = var.vm_k8s_yandex_compute_image
}

resource "yandex_compute_instance" "platform" {
  name        = local.vm_k8s_name
  platform_id = var.vms_resources["k8s"].platform_id
  resources {
    cores         = var.vms_resources["k8s"].cores
    memory        = var.vms_resources["k8s"].memory
    core_fraction = var.vms_resources["k8s"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = 22
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources["k8s"].preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vms_resources["k8s"].nat_enabled
  }

  metadata = local.default_metadata

}
