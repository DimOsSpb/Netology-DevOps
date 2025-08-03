resource "yandex_compute_disk" "disks" {
    count = 3  
    name        = "${var.course_name}-vdisk${count.index}"
    zone = var.default_zone
    size = 1                    # Размер в Гб
    type       = "network-hdd"
    lifecycle {
        prevent_destroy = true  #Защита от случайного удаления
    }
}

resource "yandex_compute_instance" "storage" {
 
    name        = "${var.course_name}-storage"
    platform_id = var.vms_platform_data.default.platform_id
    zone = var.default_zone
    resources {
        cores         = 2
        memory        = 1
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
        image_id = data.yandex_compute_image.ubuntu.image_id
        }
    }
    scheduling_policy {
        preemptible = true
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.develop.id
        security_group_ids = [yandex_vpc_security_group.example.id]
        nat       = true
    }

    metadata = local.vms_metadata

    depends_on = [
        yandex_compute_disk.disks
    ]

    dynamic "secondary_disk" {
        for_each = {for index, disk in yandex_compute_disk.disks : index => disk}
        content {
            disk_id = secondary_disk.value.id
        }
    }
  

}