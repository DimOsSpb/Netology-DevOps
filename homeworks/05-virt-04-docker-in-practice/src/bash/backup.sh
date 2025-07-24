#!/bin/bash

VM_IP=158.160.114.0
VM_USER=odv
REPO_URL=https://github.com/DimOsSpb/shvirtd-example-python.git
APP_DIR=/opt/app_example
DB_NAME=example

T=$(date +"%Y-%m-%d %H:%M:%S")
DUMP_FILE="/backup/dump-$DB_NAME-$T.sql"
cd ~
source .secret/bup.env

sudo docker run \
    --rm --entrypoint "" \
    -v /opt/backup:/backup \
    --network app_example_backend \
    schnitzler/mysqldump \
    mysqldump --opt -h db -u "$DB_USER" -p"$DB_PASSWORD" \
    "--result-file=$DUMP_FILE"\
    $DB_NAME

if [ "$?" -ne 0 ]; then
    echo "Dump Error!"
else
    echo "Dump ok - $DUMP_FILE"
fi
