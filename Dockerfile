
FROM balenalib/raspberrypi4-64-ubuntu:bionic

ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        gnupg \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABE4C7F993453843F0AEB8154D0BF748776FFB04 \
    && echo deb http://ppa.launchpad.net/iconnor/zoneminder-1.34/ubuntu bionic main > /etc/apt/sources.list.d/zoneminder.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        apache2 \
        file \
        libapache2-mod-php \
        php-fpm \
        mariadb-server \
        va-driver-all \
        vdpau-driver-all \
        libvlc-bin \
        zoneminder \
        gcc \
        make \
        libcrypt-mysql-perl \
        libyaml-perl \
        libjson-perl \
        libmodule-build-perl \
        python3-pip \
        wget \
    && a2enconf zoneminder \
    && a2enmod rewrite cgi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/es

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

RUN curl -fsSL https://github.com/pliablepixels/zmeventnotification/archive/v5.13.3.tar.gz -o es.tar.gz \
    && tar xzf es.tar.gz --strip-components=1 \
    && perl -MCPAN -e "install Net::WebSocket::Server" \
	&& perl -MCPAN -e "install LWP::Protocol::https" \
	&& perl -MCPAN -e "install Config::IniFiles" \
	&& perl -MCPAN -e "install Net::MQTT::Simple" \
	&& perl -MCPAN -e "install Net::MQTT::Simple::Auth" \
    && echo "verbose = off" >> ~/.wgetrc \
    && ./install.sh --no-interactive --install-es --install-config --no-install-hook | tee install.log \
    && if grep -q ERROR install.log ; then exit 1; fi \
    && rm -rf ./*

COPY mount.sh entrypoint.sh /

RUN chmod a+x /entrypoint.sh /mount.sh

ENTRYPOINT [ "/bin/sh", "-c", "/mount.sh && /entrypoint.sh" ]
