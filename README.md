# balena-zoneminder

[ZoneMinder](https://www.zoneminder.com/) is a full-featured, open source, state-of-the-art video surveillance software system.

## Getting Started

You can one-click-deploy this project to balena using the button below:

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/klutchell/balena-zoneminder)

## Manual Deployment

Alternatively, deployment can be carried out by manually creating a [balenaCloud account](https://dashboard.balena-cloud.com) and application,
flashing a device, downloading the project and pushing it via either Git or the [balena CLI](https://github.com/balena-io/balena-cli).

### Application Environment Variables

Application envionment variables apply to all services within the application, and can be applied fleet-wide to apply to multiple devices.

- `MYSQL_ROOT_PASSWORD`: Provide a root mysql password so the database
and users can be created on startup. This var is required and cannot be changed later.

## Usage

### ZoneMinder

Connect to `http://<device-ip>:80/zm` or enable the Public Device URL on the
balena Dashboard and append `/zm` to the URL to begin using ZoneMinder.

Once connected, we recommend following the Getting Started guide to set your timezone,
enable authentication, and begin adding monitors.

<https://zoneminder.readthedocs.io/en/stable/userguide/gettingstarted.html#>

### Event Notification Server

The Event Notification Server sits along with ZoneMinder and offers real time notifications,
support for push notifications as well as Machine Learning powered recognition.

Here's a link to the official docs on Key Principles:

<https://zmeventnotification.readthedocs.io/en/stable/guides/principles.html>

And the Configuration Guide:

<https://zmeventnotification.readthedocs.io/en/stable/guides/config.html>

We are using environment variables to automatically populate `secrets.ini` at runtime.
There are a number of optional fields in there so here are the minimum recommended
environment variables to get started with the Event Notification Server.

- `ZM_PORTAL`: EventServer uses the external URL of your ZoneMinder instance when pushing
notifications to mobile apps. For example, `https://<UUID>.balena-devices.com/zm/` if using the Public Device URL.
- `ZM_USER`: EventServer uses your ZoneMinder username to authenticate with your ZoneMinder portal.
- `ZM_PASSWORD`: EventServer uses your ZoneMinder password to authenticate with your ZoneMinder portal.

The full list of supported secrets can be found in [zm/secrets.ini](./zm/secrets.ini).

Both `zmeventnotification.ini` and `objectconfig.ini` have been populated with some sane
defaults but we recommend you read the docs to become familiar with the many options.

### sqldump

The `sqldump` service will run every hour and take a snapshot of the mysql database.
This snapshot is more likely to be recovered from a backup than an in-use database file.

We don't want to rely on a backup of a database that is currently in use,
so sqldump creates a snapshot that is not impacted by open database files.
On restoration if the database doesn't immediately work, we can import the sqldump file.

<https://mariadb.com/kb/en/mysqldump/#restoring>

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.
