
FROM balenalib/jetson-nano-ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install --no-install-recommends -y curl gnupg \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABE4C7F993453843F0AEB8154D0BF748776FFB04 \
    && echo deb http://ppa.launchpad.net/iconnor/zoneminder-1.34/ubuntu bionic main > /etc/apt/sources.list.d/zoneminder.list \
    && apt-get update \
    && apt-get install -y zoneminder \
    && a2enconf zoneminder \
    && a2enmod rewrite cgi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY mount.sh /

RUN curl -fsSL https://raw.githubusercontent.com/ZoneMinder/zmdockerfiles/master/utils/entrypoint.sh -o /entrypoint.sh \
    && chmod a+x /entrypoint.sh \
    && chmod a+x /mount.sh

ENTRYPOINT [ "/bin/sh", "-c", "/mount.sh && /entrypoint.sh" ]
