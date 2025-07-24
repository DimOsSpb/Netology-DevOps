#!/bin/bash
VM_IP=51.250.8.226
BUP_DIR=/opt/backup
SRT_DIR=~/.secret/
BIN_DIR=/usr/local/bin

scp -i ~/.ssh/netology backup.sh $USER@$VM_IP:~
ssh -i ~/.ssh/netology -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 $USER@$VM_IP \
    "sudo mkdir -p $BUP_DIR && \
    sudo chown $USER:$USER $BUP_DIR && \
    sudo mkdir -p $SRT_DIR && \
    sudo chown $USER:$USER $SRT_DIR && \
    sudo mv ~/backup.sh $BIN_DIR && 
    sudo chmod +x $BIN_DIR/backup.sh"
scp -i ~/.ssh/netology bup.env $USER@$VM_IP:$SRT_DIR


