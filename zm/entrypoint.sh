#!/bin/bash

cleanup () {
    /usr/sbin/apache2 -k stop
    sleep 5
    exit 0
}

trap cleanup EXIT

# create required log directories on tmpfs volumes
mkdir -v /var/log/apache2 && chown -v root:adm /var/log/apache2
mkdir -v /var/log/zm && chown -v www-data:root /var/log/zm

# take ownership of zoneminder volumes
chown -v www-data:www-data /var/cache/zoneminder/*

if [ -n "${SHMEM}" ]
then
    echo "Remounting shm with size ${SHMEM} ..."
    umount -v /dev/shm
    mount -v -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size="${SHMEM}" tmpfs /dev/shm
fi

# set the timezone from the TZ env var
echo "date.timezone = ${TZ}" >> /etc/php/7.2/apache2/php.ini
ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
echo "${TZ}" > /etc/timezone

# database configuration
cat > /etc/zm/conf.d/03-custom.conf << EOF
ZM_DB_HOST=${ZM_DB_HOST}
ZM_DB_USER=${ZM_DB_USER}
ZM_DB_PASS=${ZM_DB_PASS}
ZM_DB_NAME=${ZM_DB_NAME}
EOF

envsubst < /etc/zm/secrets.ini.in > /etc/zm/secrets.ini

while ! mysqladmin ping -h"${ZM_DB_HOST}" 2>/dev/null
do
    echo "Waiting for connection to mysql server ${ZM_DB_HOST} ..."
    sleep 5
done

echo "Initializing database ..."

cat > /usr/share/zoneminder/db/zm_user.sql <<EOSQL
CREATE USER '${ZM_DB_USER}'@'%' IDENTIFIED BY '${ZM_DB_PASS}' ;
GRANT ALL PRIVILEGES ON ${ZM_DB_NAME}.* TO '${ZM_DB_USER}'@'%' ;
FLUSH PRIVILEGES ;
EOSQL

/usr/bin/mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h"${ZM_DB_HOST}" -e "source /usr/share/zoneminder/db/zm_user.sql" || true

if ! /usr/bin/mysqlshow -u"${ZM_DB_USER}" -p"${ZM_DB_PASS}" -h"${ZM_DB_HOST}" "${ZM_DB_NAME}" 1>/dev/null
then
    /usr/bin/mysql -u"${ZM_DB_USER}" -p"${ZM_DB_PASS}" -h"${ZM_DB_HOST}" < /usr/share/zoneminder/db/zm_create.sql
fi

/usr/bin/zmupdate.pl -nointeractive
/usr/bin/zmupdate.pl -f

# shellcheck disable=SC1091
source /etc/apache2/envvars
/usr/sbin/apache2 -k start

/usr/bin/zmpkg.pl start

tail -f /dev/null
