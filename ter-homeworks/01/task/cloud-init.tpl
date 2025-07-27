#cloud-config
users:
  - name: ${uname}
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    ssh-authorized-keys:
      - ${key}
packages:
  - docker.io

runcmd:
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker ${uname}