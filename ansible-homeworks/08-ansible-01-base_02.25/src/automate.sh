#!/bin/bash

wait_container_ready() {
    local cid=$1
    until docker exec $cid true >/dev/null 2>&1; do
        echo .
        sleep 0.5
    done
}

centos_id=$(docker run -dit --name centos7 centos:centos7 /bin/bash) || exit 1
wait_container_ready $centos_id

ubuntu_id=$(docker run -dit --name ubuntu ubuntu-python /bin/bash) || exit 1
wait_container_ready $ubuntu_id

fedora_id=$(docker run -dit --name fedora pycontribs/fedora:latest /bin/bash) || exit 1
wait_container_ready $fedora_id

ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass

#docker stop $centos_id $ubuntu_id $fedora_id >/dev/null 2>&1;

# Чтобы не удалять руками
docker rm -f $centos_id $ubuntu_id $fedora_id >/dev/null 2>&1; 