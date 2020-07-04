#!/bin/bash

MYSQLD=/usr/sbin/mysqld
HTTPBIN=/usr/sbin/apache2
HTTPENV=/etc/apache2/envvars
ZMCONF=/etc/zm/zm.conf
SECRETSINI=/etc/zm/secrets.ini
ZMUPDATE=/usr/bin/zmupdate.pl
ZMPKG=/usr/bin/zmpkg.pl
ZMCREATE=/usr/share/zoneminder/db/zm_create.sql
PHPINI=/etc/php/7.2/apache2/php.ini

TZ="${TZ:-"UTC"}"
SHMEM="${SHMEM:-"50%"}"
ZM_DB_HOST="${ZM_DB_HOST:-"mariadb"}"
ZM_DB_USER="${ZM_DB_USER:-"zmuser"}"
ZM_DB_PASS="${ZM_DB_PASS:-"zmpass"}"
ZM_DB_NAME="${ZM_DB_NAME:-"zm"}"
ZM_USER="${ZM_USER:-"admin"}"
ZM_PASSWORD="${ZM_PASSWORD:-}"
ZM_PORTAL="${ZM_PORTAL:-"https://portal/zm"}"
ZM_API_PORTAL="${ZM_API_PORTAL:-"https://portal/zm/api"}"

cleanup () {
    "${HTTPBIN}" -k stop
    sleep 5
    exit 0
}

trap cleanup SIGTERM

umount -v /dev/shm
mount -v -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size="${SHMEM}" tmpfs /dev/shm

for uuid in $(blkid -sUUID -ovalue /dev/sd??)
do
    mkdir -v /media/"${uuid}" 2>/dev/null
    mount -v UUID="${uuid}" /media/"${uuid}"
    chown -v www-data:www-data /media/"${uuid}"
done

sed "s|ZM_DB_NAME=.*$|ZM_DB_NAME=${ZM_DB_NAME}|" -i "${ZMCONF}"
sed "s|ZM_DB_USER=.*$|ZM_DB_USER=${ZM_DB_USER}|" -i "${ZMCONF}"
sed "s|ZM_DB_PASS=.*$|ZM_DB_PASS=${ZM_DB_PASS}|" -i "${ZMCONF}"
sed "s|ZM_DB_HOST=.*$|ZM_DB_HOST=${ZM_DB_HOST}|" -i "${ZMCONF}"

sed "s|ZM_USER=.*$|ZM_USER=${ZM_USER}|" -i "${SECRETSINI}"
sed "s|ZM_PASSWORD=.*$|ZM_PASSWORD=${ZM_PASSWORD}|" -i "${SECRETSINI}"
sed "s|ZM_PORTAL=.*$|ZM_PORTAL=${ZM_PORTAL}|" -i "${SECRETSINI}"
sed "s|ZM_API_PORTAL=.*$|ZM_API_PORTAL=${ZM_API_PORTAL}|" -i "${SECRETSINI}"

echo "date.timezone = ${TZ}" >> "${PHPINI}"
ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
echo "${TZ}" > /etc/timezone

source "${HTTPENV}"

set -x

if ! mysqlshow -u"${ZM_DB_USER}" -p"${ZM_DB_PASS}" -h"${ZM_DB_HOST}" "${ZM_DB_NAME}" 1>/dev/null 2>&1
then
    mysql -u"${ZM_DB_USER}" -p"${ZM_DB_PASS}" -h"${ZM_DB_HOST}" < "${ZMCREATE}"
fi

"${ZMUPDATE}" -nointeractive

"${ZMUPDATE}" -f

"${HTTPBIN}" -k start

"${ZMPKG}" start

set +x

while :
do
    sleep 1
done
