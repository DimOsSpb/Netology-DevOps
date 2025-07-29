locals{
    vm_web_name = "${var.course_name}-${var.vm_web_platform_name}"
    vm_db_name = "${var.course_name}-${var.vm_db_platform_name}" 
    default_metadata = {
        serial-port-enable = 1
        ssh-keys           = "${var.vm_web_user}:${var.vms_ssh_root_key}"
    }
}