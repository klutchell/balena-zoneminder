
FROM alwaysai/edgeiq:nano-0.15.1

ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/src/app

# install zoneminder and dependencies
# https://github.com/ZoneMinder/zmdockerfiles/blob/master/release/ubuntu18.04/Dockerfile
# https://zmeventnotification.readthedocs.io/en/stable/guides/install.html
# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
        wget file make gcc gettext-base git \
        libgeos-dev libopenblas-dev liblapack-dev libblas-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG INSTALL_YOLOV3=no
ARG INSTALL_TINYYOLOV3=no
ARG INSTALL_YOLOV4=no
ARG INSTALL_TINYYOLOV4=yes
ARG INSTALL_CORAL_EDGETPU=no

RUN git clone https://github.com/pliablepixels/mlapi . && \
    git checkout 5bc654ff2f16828ec6cf9acba1b92a40bf7ca0b9 && \
    pip3 install -r requirements.txt && ./get_models.sh

# secrets configuration
# https://github.com/pliablepixels/mlapi/blob/master/secrets.ini
COPY secrets.ini ./secrets.ini.in

# mlapi configuration
# https://github.com/pliablepixels/mlapi/blob/master/mlapiconfig.ini
COPY mlapiconfig.ini ./mlapiconfig.ini

# default secrets values
# https://github.com/pliablepixels/zmeventnotification/blob/master/secrets.ini
ENV MLAPI_SECRET_KEY="change_to_some_secret_key" \
    PLATEREC_ALPR_KEY="something" \
    OPENALPR_ALPR_KEY="something"

ENV MLAPI_USER="zmes" \
    MLAPI_PASSWORD="zmes"

COPY db.py modules/db.py

COPY entrypoint.sh /

RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
