
FROM balenalib/jetson-nano-ubuntu-python:bionic as buildstep

# install cuda, cuda compiler, and some utilities
RUN install_packages \
        cuda-toolkit-10-0 cuda-compiler-10-0 \
        lbzip2 xorg-dev \
        cmake wget unzip \
        libgtk2.0-dev \
        libavcodec-dev \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libdc1394-22-dev && \
    echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf && ldconfig

# python numpy is required for opencv
# hadolint ignore=DL3013
RUN pip3 install numpy

WORKDIR /usr/src/app/

ARG OPENCV_RELEASE=4.2.0

# download and unpack opencv
RUN wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_RELEASE}.zip && \
    unzip ${OPENCV_RELEASE}.zip && rm -rf ${OPENCV_RELEASE}.zip && \
    wget https://github.com/opencv/opencv/archive/${OPENCV_RELEASE}.zip && \
    unzip ${OPENCV_RELEASE}.zip && rm -rf ${OPENCV_RELEASE}.zip

WORKDIR /usr/src/app/opencv-${OPENCV_RELEASE}/build

# compile and install opencv with cuda and cudann
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D INSTALL_C_EXAMPLES=OFF \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D WITH_CUDA=ON \
        -D WITH_CUDNN=ON \
        -D OPENCV_DNN_CUDA=ON \
        -D ENABLE_FAST_MATH=1 \
        -D CUDA_FAST_MATH=1 \
        -D CUDA_ARCH_BIN=5.3 \
        -D WITH_CUBLAS=1 \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_RELEASE}/modules \
        -D HAVE_opencv_python3=ON \
        -D PYTHON_EXECUTABLE=/bin/python \
        -D BUILD_SAMPLES=OFF \
        -D BUILD_EXAMPLES=OFF \
        -D BUILD_DOCS=OFF .. && \
    make -j "$(nproc)" && make install && ldconfig && \
    rm -rf ./*

FROM balenalib/jetson-nano-ubuntu-python:bionic as final

# copy minimum cuda runtime libraries
COPY --from=buildstep /usr/lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu

# copy opencv runtime libraries
COPY --from=buildstep /usr/local/lib /usr/local/lib

WORKDIR /usr/src/app

# download and install bsp binaries for L4T 32.4.2
# https://github.com/balena-io-playground/jetson-nano-sample-new/blob/master/OPENCV/Dockerfile
# hadolint ignore=SC2016
RUN install_packages wget tar lbzip2 python3 libegl1 && \
    wget https://developer.nvidia.com/embedded/L4T/r32_Release_v4.2/t210ref_release_aarch64/Tegra210_Linux_R32.4.2_aarch64.tbz2 && \
    tar xf Tegra210_Linux_R32.4.2_aarch64.tbz2 --strip-components=1 && \
    sed -i 's/config.tbz2\"/config.tbz2\" --exclude=etc\/hosts --exclude=etc\/hostname/g' apply_binaries.sh && \
    sed -i 's/install --owner=root --group=root \"${QEMU_BIN}\" \"${L4T_ROOTFS_DIR}\/usr\/bin\/\"/#install --owner=root --group=root \"${QEMU_BIN}\" \"${L4T_ROOTFS_DIR}\/usr\/bin\/\"/g' nv_tegra/nv-apply-debs.sh && \
    sed -i 's/LC_ALL=C chroot . mount -t proc none \/proc/ /g' nv_tegra/nv-apply-debs.sh && \
    sed -i 's/umount ${L4T_ROOTFS_DIR}\/proc/ /g' nv_tegra/nv-apply-debs.sh && \
    sed -i 's/chroot . \//  /g' nv_tegra/nv-apply-debs.sh && \
    ./apply_binaries.sh -r / --target-overlay && \
    echo "/usr/lib/aarch64-linux-gnu/tegra" > /etc/ld.so.conf.d/nvidia-tegra.conf && ldconfig && \
    rm -rf ./*

# install zoneminder and dependencies
# https://github.com/ZoneMinder/zmdockerfiles/blob/master/release/ubuntu18.04/Dockerfile
RUN install_packages curl gnupg && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABE4C7F993453843F0AEB8154D0BF748776FFB04 && \
    echo deb http://ppa.launchpad.net/iconnor/zoneminder-1.34/ubuntu bionic main > /etc/apt/sources.list.d/zoneminder.list && \
    install_packages \
        apache2 \
        wget file \
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
        gettext-base && \
    a2enconf zoneminder && a2enmod rewrite cgi

WORKDIR /usr/src/app

# install module dependencies for eventserver
# https://zmeventnotification.readthedocs.io/en/stable/guides/install.html
RUN perl -MCPAN -e "install Net::WebSocket::Server" && \
    perl -MCPAN -e "install LWP::Protocol::https" && \
    perl -MCPAN -e "install Config::IniFiles" && \
    perl -MCPAN -e "install Net::MQTT::Simple" && \
    perl -MCPAN -e "install Net::MQTT::Simple::Auth" && \
    perl -MCPAN -e "install Getopt::Long" && \
    perl -MCPAN -e "install Crypt::Eksblowfish::Bcrypt"

# eventserver release and installer args
# https://github.com/pliablepixels/zmeventnotification/releases
ARG ZMES_RELEASE=v6.0.6
ARG INSTALL_YOLOV3=no
ARG INSTALL_TINYYOLOV3=yes
ARG INSTALL_YOLOV4=no
ARG INSTALL_TINYYOLOV4=no
ARG INSTALL_CORAL_EDGETPU=no

# install script for the EventServer and the machine learning hooks
# https://github.com/pliablepixels/zmeventnotification/blob/master/install.sh
# hadolint ignore=DL4006
RUN wget https://github.com/pliablepixels/zmeventnotification/archive/${ZMES_RELEASE}.tar.gz && \
    tar xf ${ZMES_RELEASE}.tar.gz --strip-components=1 && \
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

# default database env vars
ENV ZM_DB_HOST db
ENV ZM_DB_NAME zm
ENV ZM_DB_USER zmuser
ENV ZM_DB_PASS zmpass

# default secrets values
# https://github.com/pliablepixels/zmeventnotification/blob/master/secrets.ini
ENV ZM_USER user
ENV ZM_PASSWORD password
ENV ES_ADMIN_INTERFACE_PASSWORD your_admin_interface_password
ENV ZM_PORTAL https://portal/zm
ENV ZM_API_PORTAL ${ZM_PORTAL}/api
ENV ZMES_PICTURE_URL ${ZM_PORTAL}/index.php?view=image&eid=EVENTID&fid=objdetect&width=600
ENV ES_CERT_FILE /path/to/cert/file.pem
ENV ES_KEY_FILE /path/to/key/file.pem
ENV ML_USER your_mlapi_user
ENV ML_PASSWORD your_mlapi_password
ENV PLATEREC_ALPR_KEY your_plate_recognizer_api_key
ENV OPENALPR_ALPR_KEY your_openalpr_api_key
ENV ESCONTROL_INTERFACE_PASSWORD yourescontrolpassword
ENV MQTT_USERNAME your_mqtt_username
ENV MQTT_PASSWORD your_mqtt_password
ENV PUSHOVER_APP_TOKEN your_pushover_app_token
ENV PUSHOVER_USER_KEY your_pushover_user_key

ENV UDEV=1
ENV LD_LIBRARY_PATH=/usr/local/lib

COPY entrypoint.sh /

RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
