
resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl", {

    webs     = yandex_compute_instance.web.*,
    dbs      = yandex_compute_instance.db,
    storages = yandex_compute_instance.storage.*  

  })
  filename = "${abspath(path.module)}/hosts.ini"
}