#!/bin/bash


T=$(date +"%Y%m%d%H%M%S")

VM_IP=51.250.8.226

SOURCE_DIR=/opt/app_example

DEST_DIR=/home/odv/projects/MY/DevOpsCourse/homeworks/05-virt-04-docker-in-practice/runc

DB=db
APP=app
HAPROXY=haproxy
NGINX=nginx

DB_DIR=$DEST_DIR/$DB
APP_DIR=$DEST_DIR/$APP
HAPROXY_DIR=$DEST_DIR/$HAPROXY
NGINX_DIR=$DEST_DIR/$NGINX

CONT_HAPROXY_ID=haproxy:2.4
CONT_DB_ID=mysql:8
CONT_APP_ID=shvirtd-example-python:v1
CONT_NGINX_ID=nginx:1.21.1

PRJ_DIR=/home/odv/projects/MY/DevOpsCourse/submodules/shvirtd-example-python
SRT_DIR=~/.secret/
BIN_DIR=/usr/local/bin
CONF_NAME=config.json
CONF_NAME_B=$CONF_NAME.$T

declare -A CON=(
    [$APP]=$CONT_APP_ID
    [$DB]=$CONT_DB_ID
    [$HAPROXY]=$CONT_HAPROXY_ID
    [$NGINX]=$CONT_NGINX_ID
)

declare -A DIRS=(
    [$APP]=$APP_DIR
    [$DB]=$DB_DIR
    [$HAPROXY]=$HAPROXY_DIR
    [$NGINX]=$NGINX_DIR
)

sudo mkdir -p $DEST_DIR && \
sudo chown $USER:$USER $DEST_DIR
cd $DEST_DIR

for serv in "${!CON[@]}"; do

    echo "-> $serv..."

    w_dir=${DIRS[$serv]}

    mkdir -p $w_dir && \
    sudo rm -fR $w_dir/rootfs && \
    mkdir -p $w_dir/rootfs && \

    c_id=${CON[$serv]}
    

    cd "$w_dir" ||  exit 1; 
    
    docker create --name "tmp-$serv" "$c_id"
    docker export "tmp-$serv" | sudo tar -C rootfs -xf -
    docker rm "tmp-$serv" > /dev/null
    sudo chown $USER:$USER rootfs

    # Работа с конфигом
    if [ -f "$CONF_NAME" ]; then
        cp -f $CONF_NAME $CONF_NAME_B
    else
        runc spec
    fi

    if [ $serv = $NGINX ]; then
        mkdir -p $w_dir/ingress
        cp -f $PRJ_DIR/nginx/ingress/default.conf $w_dir/ingress
        cp -f $PRJ_DIR/nginx/ingress/nginx.conf $w_dir/ingress
        # sudo mkdir -p rootfs/var/cache/nginx/client_temp
        # sudo chown 101:101 rootfs/var/cache/nginx/client_temp 
        # sudo mkdir -p rootfs/var/cache/nginx/proxy_temp
        # sudo chown 101:101 rootfs/var/cache/nginx/proxy_temp                
    fi
    
    
done



if [ "$?" -ne 0 ]; then
    echo "Error!"
else
    echo "Ok - $DUMP_FILE"
fi
