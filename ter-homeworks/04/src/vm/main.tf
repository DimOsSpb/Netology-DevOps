
data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate" # Здесь укажем remote state
  }
}

resource "yandex_compute_instance" "vm" {
  name        = "my-vm"
  platform_id = "standard-v3"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8e4gcflhhc7odvbuss"
    }
  }

  network_interface {
    subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id # Берем из state ../vpc/terraform.tfstate
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/netology.pub")}"
  }
}
