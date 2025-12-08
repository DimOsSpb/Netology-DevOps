locals{
    vm_k8s_name = "${var.vm_k8s_platform_name}"
    default_metadata = {
        serial-port-enable = 1
        ssh-keys           = "${var.vm_k8s_user}:${file("/home/odv/.ssh/netology.pub")}"
    }
}