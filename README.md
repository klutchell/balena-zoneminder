# balena-zoneminder

[ZoneMinder](https://www.zoneminder.com/) is a full-featured, open source, state-of-the-art video surveillance software system.

## Requirements

- Jetson Nano with 16GB+ microSD card

## Getting Started

You can one-click-deploy this project to balena using the button below:

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/klutchell/balena-zoneminder)

## Manual Deployment

Alternatively, deployment can be carried out by manually creating a [balenaCloud account](https://dashboard.balena-cloud.com) and application,
flashing a device, downloading the project and pushing it via either Git or the [balena CLI](https://github.com/balena-io/balena-cli).

### Application Environment Variables

Application envionment variables apply to all services within the application, and can be applied fleet-wide to apply to multiple devices.

- `MYSQL_ROOT_PASSWORD`: Provide a root mysql password so the database and users can be created on startup.
This variable is required and cannot be changed later.
- `TZ`: Inform services of your local timezone.
See [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for a full list of available options.

## Usage

### ZoneMinder

Connect to `http://<device-ip>:80/zm` or enable the Public Device URL on the
balena Dashboard and append `/zm` to the URL to begin using ZoneMinder.

Once connected, we recommend following the Getting Started guide to enable authentication,
and begin adding monitors.

<https://zoneminder.readthedocs.io/en/stable/userguide/gettingstarted.html>

The `TIMEZONE` is being controlled via the `TZ` environment variable so you can leave
the Options value as `Unset - use value in php.ini` to avoid conflicts.

### Event Notification Server

The Event Notification Server sits along with ZoneMinder and offers real time notifications,
support for push notifications as well as Machine Learning powered recognition.

Event Notification Server FAQ:

<https://zmeventnotification.readthedocs.io/en/stable/guides/es_faq.html>

Machine Learning Hooks FAQ:

<https://zmeventnotification.readthedocs.io/en/stable/guides/hooks_faq.html>

We are using environment variables to automatically populate `secrets.ini` at runtime.
There are a number of optional fields in there so here are the minimum recommended
environment variables to get started with the Event Notification Server.

- `ZM_PORTAL`: EventServer uses the external URL of your ZoneMinder instance when pushing
notifications to devices. For example, `https://<UUID>.balena-devices.com/zm/` if using the Public Device URL.
- `ZM_USER`: EventServer uses your ZoneMinder username to authenticate with your ZoneMinder portal.
- `ZM_PASSWORD`: EventServer uses your ZoneMinder password to authenticate with your ZoneMinder portal.

The full list of supported secrets can be found in [zm/secrets.ini](./zm/secrets.ini).

Both `zmeventnotification.ini` and `objectconfig.ini` have been populated with some sane
defaults but we recommend you read the docs to become familiar with the many options.

Once you are satisfied with the configuration you can configure ES to be autostarted
by going to `Options->Systems` and enable `OPT_USE_EVENTNOTIFICATION` and you are all set.

<https://zmeventnotification.readthedocs.io/en/stable/guides/install.html#making-sure-the-es-gets-auto-started-when-zm-starts>

### sqldump

The `sqldump` service will run every hour and take a snapshot of the mysql database.
This snapshot is more likely to be recovered from a backup than an in-use database file.

We don't want to rely on a backup of a database that is currently in use,
so sqldump creates a snapshot that is not impacted by open database files.
On restoration if the database doesn't immediately work, we can import the sqldump file.

<https://mariadb.com/kb/en/mysqldump/#restoring>

## Debugging

There are a couple python scripts in the image that can print
useful CUDA and OpenCV information.

```bash
python3 /etc/zm/check_cuda.py
python3 /etc/zm/check_opencv.py
```

`tegrastats` is also available in the image for debugging:

```bash
tegrastats

RAM 1816/3961MB (lfb 5x2MB) SWAP 115/990MB (cached 31MB) CPU [15%@1479,15%@1479,14%@1479,100%@1479] EMC_FREQ 0% GR3D_FREQ 0% PLL@19C CPU@19C PMIC@100C GPU@21C AO@24C thermal@20.25C POM_5V_IN 2515/2515 POM_5V_GPU 0/0 POM_5V_CPU 1054/1054
```

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

## Acknowledgements

ZoneMinder is a free, open source program which is maintained by a very small group of developers, for free, in their spare time.

<https://zoneminder.com/contact/>

Event Notification Server and some of the associated components are authored and maintained by @pliablepixels.

<https://github.com/pliablepixels/zmeventnotification>
