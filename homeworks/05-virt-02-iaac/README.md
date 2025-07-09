# Задача 1: Настройка среды для IaaC в работе с виртуальными машинами.
## Инструменты:
### Vagrant

- Установим платформу виртуализации. На лекции и в задании предлагается установить VirtualBox, но учитывая, что на моем ноутбуке двойная загрузка систем и одна из них Windows 11, которая требует включенной в bios SecureBoot, а модули VirtualBox не подписаны, я решил поставить нативную систему виртуализации KVM/QUEMU Libvirt для Debian 12 - системы в которой я работаю (Это вторая система установленная на мой ноутбук). Думаю это только поможет лучше освоить Vagrant, т.к. суть решения не меняется, но я оспою больше материала.

- Установим Vagrant загрузив его по [ссылке](https://hashicorp-releases.yandexcloud.net/vagrant/) из задания, проверим версию - Vagrant 2.3.4 - что надо.

       odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-02-iaac$ vagrant --version
       Vagrant 2.3.4

- Аналогично по [ссылке из задания](https://hashicorp-releases.yandexcloud.net/packer/) установим packer и по инструкции в задании - плагин для яндекс облака - **packer-plugin-yandex_v1.1.3_x5**

        odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-02-iaac$ packer --version
        Packer v1.13.1

        odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-02-iaac$ packer plugins installed
        /home/odv/.config/packer/plugins/github.com/hashicorp/yandex/packer-plugin-yandex_v1.1.3_x5.0_linux_amd64

- Установим и настроим интерфейс командной строки [Yandex Cloud (CLI)](https://github.com/netology-code/virtd-homeworks/tree/shvirtd-1/05-virt-02-iaac#%D0%B7%D0%B0%D0%B4%D0%B0%D1%87%D0%B0-1) 

        odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-02-iaac$ yc --version
        Yandex Cloud CLI 0.153.0 linux/amd64

- Для KVM/QUEMU Libvirt установим плагин для vagrant используя --plugin-source https://rubygems.org, т.к. в моем случае стандартный ресурс не доступен, этот альтернативный: 

        vagrant plugin install --plugin-clean-sources --plugin-source https://rubygems.org vagrant-libvirt

- Решение различных вопросов :

    ** 1. Недоступности ресурсов - ошибка загрузки образа:**

        vagrant box add generic/ubuntu2004
        ==> box: Loading metadata for box 'generic/ubuntu2004'
            box: URL: https://vagrantcloud.com/api/v2/vagrant/generic/ubuntu2004
        This box can work with multiple providers! The providers that it
        can work with are listed below. Please review the list and choose
        the provider you will be working with.

        1) hyperv
        2) libvirt
        3) parallels
        4) qemu
        5) virtualbox
        6) vmware_desktop

        Enter your choice: 2
        ==> box: Adding box 'generic/ubuntu2004' (v4.3.12) for provider: libvirt
            box: Downloading: https://vagrantcloud.com/generic/boxes/ubuntu2004/versions/4.3.12/providers/libvirt/amd64/vagrant.box
        An error occurred while downloading the remote file. The error

    Получим vagrant.box любым способом, например через vpn загрузив по ссылке https://vagrantcloud.com/generic/boxes/ubuntu2004/versions/4.3.12/providers/libvirt/amd64/vagrant.box получим 5f33ec97-fe84-11ef-a1ab-7a05e6a293ee - далее загрузим образ назвав его ubuntu-20.04 использую команду:

        vagrant box add --name ubuntu-20.04 5f33ec97-fe84-11ef-a1ab-7a05e6a293ee --provider=libvirt --force

- Для работы с libvirt без root, настроим права, т.к. например virsh list --all без прав root или sudo, не покажет домены.

        sudo usermod -a -G libvirt,kvm $(whoami)
        # Relogin or run
        newgrp libvirt
    
    Здесь -c qemu:///system позволяет без root видеть домены.

        virsh -c qemu:///system list --all
        #Или
        sudo virsh list --all
##  LINKS 
- [Vagrant-libvirt Documentation](https://vagrant-libvirt.github.io/vagrant-libvirt/configuration.html#private-network-options)
- [Vagrant - Documentation](https://developer.hashicorp.com/vagrant/docs)
---

# Задача 2: Создание виртуальной машины с помощью Vagrant, с автоматической установкой Docker и Docker compose

- В каталоге с [Vagrantfilе из задания](https://github.com/netology-code/virtd-homeworks/blob/shvirtd-1/05-virt-02-iaac/docker/Vagrantfile) который мы [модифицировали под libvirt](docker/vagrantfile), запустим "vagrant up". После создания вм, зайдем в нее - "vagrant ssh".
    - Внесем пользователя в группу docker
        sudo usermod -aG docker $USER
        newgrp docker
    - Проверим, что цель достигнута:

            vagrant@server1:~$ docker version && docker compose version

            Client: Docker Engine - Community
            Version:           28.1.1
            API version:       1.49
            Go version:        go1.23.8
            Git commit:        4eba377
            Built:             Fri Apr 18 09:52:18 2025
            OS/Arch:           linux/amd64
            Context:           default

            Server: Docker Engine - Community
            Engine:
            Version:          28.1.1
            API version:      1.49 (minimum version 1.24)
            Go version:       go1.23.8
            Git commit:       01f442b
            Built:            Fri Apr 18 09:52:18 2025
            OS/Arch:          linux/amd64
            Experimental:     false
            containerd:
            Version:          1.7.27
            GitCommit:        05044ec0a9a75232cad458027ca83437aae3f4da
            runc:
            Version:          1.2.5
            GitCommit:        v1.2.5-0-g59923ef
            docker-init:
            Version:          0.19.0
            GitCommit:        de40ad0
            Docker Compose version v2.35.1
---
 
# Задача 3: Создание образа виртуальной машины на yandex cloud через Packer с автоматической установкой Docker и Docker compose, проверка на облаке создания вм из этого образа.

- [mydebian.json](docker/mydebian.json)

        odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-02-iaac/docker$ packer build mydebian.json 
        yandex: output will be in this color.

        ==> yandex: Creating temporary RSA SSH key for instance...
        ==> yandex: Using as source image: fd8takdiqledn4t29vuj (name: "debian-11-v20250630", family: "debian-11")
        ==> yandex: Use provided subnet id e9ba5mmqqj76kb3q4m4e
        ==> yandex: Creating disk...
        ==> yandex: Creating instance...
        ==> yandex: Waiting for instance with id fhm4b02isiesops6gko5 to become active...
        ==> yandex: Detected instance IP: 46.21.247.16
        ==> yandex: Using SSH communicator to connect: 46.21.247.16
        ==> yandex: Waiting for SSH to become available...
        ==> yandex: Connected to SSH!
        ==> yandex: Provisioning with shell script: /tmp/packer-shell1575237201
        ==> yandex: Get:1 http://mirror.yandex.ru/debian bullseye InRelease [116 kB]
        ==> yandex: Get:2 http://mirror.yandex.ru/debian bullseye-updates InRelease [44.0 kB]

        ....

        ==> yandex: Processing triggers for libc-bin (2.31-13+deb11u13) ...
        ==> yandex: Stopping instance...
        ==> yandex: Deleting instance...
        ==> yandex: Instance has been deleted!
        ==> yandex: Creating image: debian-11-docker
        ==> yandex: Waiting for image to complete...
        ==> yandex: Success image create...
        ==> yandex: Destroying boot disk...
        ==> yandex: Disk has been deleted!
        Build 'yandex' finished after 3 minutes 49 seconds.

        ==> Wait completed after 3 minutes 49 seconds

        ==> Builds finished. The artifacts of successful builds are:
        --> yandex: A disk image was created: debian-11-docker (id: fd8dee9n0d0ueiis0egh) with family name 
        odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-02-iaac/docker$ yc compute image list
        +----------------------+------------------+--------+----------------------+--------+
        |          ID          |       NAME       | FAMILY |     PRODUCT IDS      | STATUS |
        +----------------------+------------------+--------+----------------------+--------+
        | fd8dee9n0d0ueiis0egh | debian-11-docker |        | f2eh2keamkps7ekhfjge | READY  |
        +----------------------+------------------+--------+----------------------+--------+



        odv@matebook16s:~/projects/MY/DevOpsCourse/homeworks/05-virt-02-iaac/docker$ ssh debian@158.160.56.168
        The authenticity of host '158.160.56.168 (158.160.56.168)' can't be established.
        ED25519 key fingerprint is SHA256:+IfEueX6q2IwIuYuXOQoi+2M3mHRwzEyHm2R7SHh3Cw.
        This key is not known by any other names.
        Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
        Warning: Permanently added '158.160.56.168' (ED25519) to the list of known hosts.
        Linux netology-iaac 5.10.0-19-amd64 #1 SMP Debian 5.10.149-2 (2022-10-21) x86_64

        The programs included with the Debian GNU/Linux system are free software;
        the exact distribution terms for each program are described in the
        individual files in /usr/share/doc/*/copyright.

        Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
        permitted by applicable law.


        debian@netology-iaac:~$ docker version && docker compose version
        Client: Docker Engine - Community
        Version:           28.3.1
        API version:       1.51
        Go version:        go1.24.4
        Git commit:        38b7060
        Built:             Wed Jul  2 20:56:41 2025
        OS/Arch:           linux/amd64
        Context:           default

        Server: Docker Engine - Community
        Engine:
        Version:          28.3.1
        API version:      1.51 (minimum version 1.24)
        Go version:       go1.24.4
        Git commit:       5beb93d
        Built:            Wed Jul  2 20:56:41 2025
        OS/Arch:          linux/amd64
        Experimental:     false
        containerd:
        Version:          1.7.27
        GitCommit:        05044ec0a9a75232cad458027ca83437aae3f4da
        runc:
        Version:          1.2.5
        GitCommit:        v1.2.5-0-g59923ef
        docker-init:
        Version:          0.19.0
        GitCommit:        de40ad0
        Docker Compose version v2.38.1

        debian@netology-iaac:~$ htop --version 
        htop 3.0.5

        debian@netology-iaac:~$ tmux --version
        usage: tmux [-2CluvV] [-c shell-command] [-f file] [-L socket-name]
                    [-S socket-path] [command [flags]]

## Замечания:

- Обнаружил на почте сообщения от gihub о наличии секретов (ключей) в репозитории. Действительно, нашел через "git log -p" в .vagrant файлик с ключом доступа к вм по ssh - почистил из истории, и добавил в .gitignore весь каталог :

        git filter-branch --tree-filter "rm -fR homeworks/05-virt-02-iaac/docker/.vagrant/" HEAD
        git push --all --force

