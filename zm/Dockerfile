
FROM alwaysai/edgeiq:jetson-0.17.1

ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/src/app

# install zoneminder and dependencies
# https://github.com/ZoneMinder/zmdockerfiles/blob/master/release/ubuntu18.04/Dockerfile
# https://zmeventnotification.readthedocs.io/en/stable/guides/install.html
# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y curl gnupg && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABE4C7F993453843F0AEB8154D0BF748776FFB04 && \
    echo deb http://ppa.launchpad.net/iconnor/zoneminder-1.34/ubuntu bionic main > /etc/apt/sources.list.d/zoneminder.list && \
    apt-get update && apt-get install --no-install-recommends -y \
        apache2 \
        wget file git \
        libapache2-mod-php \
        php-fpm \
        mariadb-client \
        zoneminder \
        gcc make \
        libcrypt-mysql-perl \
        libyaml-perl \
        libjson-perl \
        libmodule-build-perl \
        gifsicle \
        libgeos-dev \
        python3-dev \
        va-driver-all \
        vdpau-driver-all \
        libvlc-bin \
        libjpeg-dev \
        gettext-base \
        sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    a2enconf zoneminder && a2enmod rewrite cgi && \
    perl -MCPAN -e "install Net::WebSocket::Server" && \
    perl -MCPAN -e "install LWP::Protocol::https" && \
    perl -MCPAN -e "install Config::IniFiles" && \
    perl -MCPAN -e "install Net::MQTT::Simple" && \
    perl -MCPAN -e "install Net::MQTT::Simple::Auth" && \
    perl -MCPAN -e "install Getopt::Long" && \
    perl -MCPAN -e "install Crypt::Eksblowfish::Bcrypt"

# eventserver release and installer args
# https://github.com/pliablepixels/zmeventnotification/releases
ARG ZMES_RELEASE=v6.1.12
ARG INSTALL_YOLOV3=no
ARG INSTALL_TINYYOLOV3=no
ARG INSTALL_YOLOV4=no
ARG INSTALL_TINYYOLOV4=yes
ARG INSTALL_CORAL_EDGETPU=no

# install script for the EventServer and the machine learning hooks
# https://github.com/pliablepixels/zmeventnotification/blob/master/install.sh
# hadolint ignore=DL4006
RUN git clone https://github.com/pliablepixels/zmeventnotification.git . && \
    git checkout ${ZMES_RELEASE} && \
    ./install.sh --no-interactive --install-es --install-config --install-hook | tee install.log && \
    if grep -q ERROR install.log ; then exit 1 ; fi && \
    rm -rf ./*

WORKDIR /etc/zm

# Secrets configuration
# https://github.com/pliablepixels/zmeventnotification/blob/master/secrets.ini
COPY secrets.ini /etc/zm/secrets.ini.in

# Event Notification Server configuration
# https://github.com/pliablepixels/zmeventnotification/blob/master/zmeventnotification.ini
COPY zmeventnotification.ini /etc/zm/zmeventnotification.ini

# Machine Learning Hooks configuration
# https://github.com/pliablepixels/zmeventnotification/blob/master/hook/objectconfig.ini
COPY objectconfig.ini /etc/zm/objectconfig.ini

# default secrets values
# https://github.com/pliablepixels/zmeventnotification/blob/master/secrets.ini
ENV ZM_PORTAL="https://portal/zm" \
    ZM_USER="admin" \
    ZM_PASSWORD="admin" \
    ES_ADMIN_INTERFACE_PASSWORD="your_admin_interface_password" \
    ES_CERT_FILE="/path/to/cert/file.pem" \
    ES_KEY_FILE="/path/to/key/file.pem" \
    ML_USER="your_mlapi_user" \
    ML_PASSWORD="your_mlapi_password" \
    PLATEREC_ALPR_KEY="your_plate_recognizer_api_key" \
    OPENALPR_ALPR_KEY="your_openalpr_api_key" \
    ESCONTROL_INTERFACE_PASSWORD="yourescontrolpassword" \
    MQTT_ENABLE="no" \
    MQTT_SERVER="127.0.0.1" \
    MQTT_USERNAME="your_mqtt_username" \
    MQTT_PASSWORD="your_mqtt_password" \
    PUSHOVER_APP_TOKEN="your_pushover_app_token" \
    PUSHOVER_USER_KEY="your_pushover_user_key"

# set default timezone
ENV TZ UTC

# make sure the www-data user has access to /dev/nv* devices
# by adding it to the video group
RUN usermod -aG video www-data

COPY entrypoint.sh /

RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

COPY check_cuda.py check_opencv.py /etc/zm/
