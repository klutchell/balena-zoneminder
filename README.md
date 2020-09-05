# balena-zoneminder

[zoneminder](https://www.zoneminder.com/) stack for balenaCloud

## Requirements

- NVIDIA Jetson NANO or similar x64 device supported by BalenaCloud
- USB storage device for events

## Getting Started

You can one-click-deploy this project to balena using the button below:

[![](https://balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy)

## Manual Deployment

Alternatively, deployment can be carried out by manually creating a [balenaCloud account](https://dashboard.balena-cloud.com) and application, flashing a device, downloading the project and pushing it via either Git or the [balena CLI](https://github.com/balena-io/balena-cli).

### Application Environment Variables

Application envionment variables apply to all services within the application, and can be applied fleet-wide to apply to multiple devices.

|Name|Example|Purpose|
|---|---|---|
|`TZ`|`America/Toronto`|(optional) inform services of the [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) in your location|
|`MYSQL_ROOT_PASSWORD`|`topsecret`|(required) provide a root password for the mysql database|
|`ZM_USER`|`admin`|the username used to log into your ZM web console (set in dashboard first)|
|`ZM_PASSWORD`|`supersecret`|the password for your ZM web console (set in dashboard first)|
|`ZM_PORTAL`|`http://zm.192.168.8.3.nip.io/zm`|the URL for your ZM instance|
|`ZM_API_PORTAL`|`http://zm.192.168.8.3.nip.io/zm/api`|the URL for your ZM API instance|

## Usage

## create database credentials

Connect to the `mariadb` Terminal and run the following:

```bash
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'zmuser'@'%' IDENTIFIED BY 'zmpass';"
```

Make sure `zmuser` and `zmpass` match the values provided for `ZM_DB_USER` and `ZM_DB_PASS` in `docker-compose.yml`.

## connect to dashboard

Once the database credentials are created you can restart the `zoneminder` service and connect to the dashboard to start adding monitors and storage.

<http://mydevice.local:80/zm>

### prepare external storage

Connect to the `Host OS` Terminal and run the following:

```bash
# g - create a new empty GPT partition table
# n - add a new partition
# 1 - partition number 1
# default - start at beginning of disk
# default - extend partition to end of disk
# y - overwrite existing filesystem
# w - write the partition table
printf "g\nn\n1\n\n\ny\nw\n" | fdisk /dev/sda
mkfs.ext4 /dev/sda1 -L ZONEMINDER
```

Restart the `zoneminder` service and the new partition with `LABEL=ZONEMINDER` will be mounted at `/var/cache/zoneminder/events`.

### enable duplicati

Connect to `http://<device-ip>:8200` and configure a new backup using any online service you prefer as the Destination and `/source` as Source Data.

## Development

```bash
# cross build for aarch64 on an amd64 or i386 workstation with Docker
export DOCKER_CLI_EXPERIMENTAL=enabled
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --use --driver docker-container
docker buildx build . --platform linux/arm64 --load --progress plain -t zoneminder
```

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

## Author

Kyle Harding <https://klutchell.dev>

[![](https://cdn.buymeacoffee.com/buttons/default-orange.png)](https://www.buymeacoffee.com/klutchell)

## Acknowledgments

- <https://zoneminder.com/>
- <https://hub.docker.com/_/mariadb/>
- <https://hub.docker.com/r/linuxserver/duplicati>

## References

- <https://zoneminder.readthedocs.io/en/stable/installationguide/easydocker.html>
- <https://zmeventnotification.readthedocs.io/en/stable/guides/install.html>
- <https://github.com/ZoneMinder/zmdockerfiles>
- <https://github.com/dlandon/zoneminder>

## License

[MIT License](./LICENSE)
