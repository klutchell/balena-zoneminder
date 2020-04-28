#!/bin/sh

set -e

mount -v -L ZONEMINDER /var/cache/zoneminder/events

chown www-data:www-data /var/cache/zoneminder/events
