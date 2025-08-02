resource "null_resource" "run_ansible" {

  depends_on = [
    local_file.hosts_templatefile,
    yandex_compute_instance.web,
    yandex_compute_instance.db,
    yandex_compute_instance.storage
  ]

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i ${local_file.hosts_templatefile.filename} ${path.module}/test.yml --private-key ${var.vms_platform_data.default.ssh_priv_key_path}
    EOT
  }

  # Можно использовать triggers для перезапуска
  triggers = {
    always_run = timestamp()
  }
}