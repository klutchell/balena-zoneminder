
FROM balenalib/jetson-nano-ubuntu-python:run AS zoneminder

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABE4C7F993453843F0AEB8154D0BF748776FFB04 && \
    echo deb http://ppa.launchpad.net/iconnor/zoneminder-1.34/ubuntu bionic main > /etc/apt/sources.list.d/zoneminder.list && \
    install_packages \
        apache2 mariadb-client ssmtp mailutils net-tools sudo ffmpeg zoneminder \
        php7.2 php7.2-fpm libapache2-mod-php7.2 php7.2-mysql php7.2-gd \
        libavutil-dev libvlc-dev libvlccore-dev vlc-bin vlc-plugin-base vlc-plugin-video-output && \
    a2enmod php7.2 proxy_fcgi ssl rewrite expires headers && \
    a2enconf php7.2-fpm zoneminder

FROM zoneminder AS eventserver

WORKDIR /usr/src/app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://github.com/pliablepixels/zmeventnotification/releases
ARG ZMES_RELEASE=v6.1.13
ARG INSTALL_YOLOV3=no
ARG INSTALL_TINYYOLOV3=no
ARG INSTALL_YOLOV4=no
ARG INSTALL_TINYYOLOV4=no
ARG INSTALL_CORAL_EDGETPU=no

# hadolint ignore=DL3013
RUN install_packages build-essential crudini gifsicle libcrypt-mysql-perl libyaml-perl libjson-perl libgeos-dev && \
    curl -fsSL https://github.com/pliablepixels/zmeventnotification/archive/refs/tags/${ZMES_RELEASE}.tar.gz | tar xz --strip-components=1 && \
    bash -x ./install.sh --no-interactive --install-es --install-config --install-hook && \
    echo "extension=apcu.so" > /etc/php/7.2/mods-available/apcu.ini && \
    echo "extension=mcrypt.so" > /etc/php/7.2/mods-available/mcrypt.ini && \
    perl -MCPAN -e "force install Net::WebSocket::Server" && \
    perl -MCPAN -e "force install LWP::Protocol::https" && \
    perl -MCPAN -e "force install Config::IniFiles" && \
    perl -MCPAN -e "force install Net::MQTT::Simple" && \
    perl -MCPAN -e "force install Net::MQTT::Simple::Auth" && \
    perl -MCPAN -e "force install Time::Piece" && \
    pip install --no-cache-dir opencv-python && \
    ln -sf "$(which python3)" /usr/bin/ && \
    apt-get autoremove build-essential -y && rm -rf ./*

WORKDIR /etc/zm

COPY zmeventnotification.ini objectconfig.ini secrets.ini ./

COPY init.sh /

RUN chmod a+x /init.sh

CMD [ "/init.sh" ]

ENV TZ UTC

ENV ZM_DB_HOST db
ENV ZM_DB_NAME zm
ENV ZM_DB_USER zmuser
ENV ZM_DB_PASS zmpass

ENV ML_USER mlapi
ENV ML_PASSWORD mlapi
ENV ZM_PORTAL http://zm/zm
ENV ZM_API_PORTAL http://zm/zm/api
