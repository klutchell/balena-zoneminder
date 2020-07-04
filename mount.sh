#!/bin/sh

umount -v /dev/shm
mount -v -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size="${SHMEM:-"50%"}" tmpfs /dev/shm

for uuid in $(blkid -sUUID -ovalue /dev/sd??)
do
    mkdir -v /media/"${uuid}" 2>/dev/null
    mount -v UUID="${uuid}" /media/"${uuid}"
    chown -v www-data:www-data /media/"${uuid}"
done

exit 0