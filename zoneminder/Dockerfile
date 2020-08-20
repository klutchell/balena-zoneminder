
FROM alwaysai/edgeiq:nano-0.14.2

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
        mariadb-client \
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
        gifsicle \
        libgeos-dev \
        python3-dev \
        crudini \
    && a2enconf zoneminder \
    && a2enmod rewrite cgi \
    && perl -MCPAN -e "install Net::WebSocket::Server" \
	&& perl -MCPAN -e "install LWP::Protocol::https" \
	&& perl -MCPAN -e "install Config::IniFiles" \
	&& perl -MCPAN -e "install Net::MQTT::Simple" \
	&& perl -MCPAN -e "install Net::MQTT::Simple::Auth" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/es

ENV INSTALL_YOLOV3 no
ENV INSTALL_YOLOV4 no
ENV INSTALL_TINYYOLOV3 yes

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

RUN curl -fsSL https://github.com/pliablepixels/zmeventnotification/archive/v5.15.6.tar.gz | tar xvz --strip-components=1 \
    && ./install.sh --no-interactive --install-es --install-config --install-hook | tee install.log \
    && if grep -q ERROR install.log ; then exit 1 ; fi \
    && rm -rf ./*

WORKDIR /etc/zm

COPY entrypoint.sh /

RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
