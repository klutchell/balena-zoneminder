#!/bin/sh

set -eu

while :
do
    sleep 1h
    mysqldump --single-transaction \
        -h db -u root -p"${MYSQL_ROOT_PASSWORD}" \
        --all-databases > "/var/lib/mysql/backup.sql"
done