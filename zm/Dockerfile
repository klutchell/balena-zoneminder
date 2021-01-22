
FROM balenalib/jetson-nano-ubuntu:bionic as opencv

ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV DEBIAN_FRONTEND noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG OPENCV_RELEASE=4.4.0

# opencv build dependencies (removed post-install)
ARG OPENCV_DEPENDS=" \
    build-essential \
    cmake \
    cuda-compiler-10-2 \
    cuda-toolkit-10-2 \
    python3-numpy \
    libcudnn8-dev \
    xorg-dev \
"

# opencv runtime dependencies
ARG OPENCV_RDEPENDS=" \
    cuda-libraries-10-2 \
    cuda-driver-dev-10-2 \
    libcudnn8 \
    libgtk2.0-dev \
    libavcodec-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    libdc1394-22-dev \
"

    # libgstreamer1.0-dev \
    # libgstreamer-plugins-base1.0-dev \

# cuda-command-line-tools-10-2 - CUDA command-line tools
# cuda-compiler-10-2 - CUDA compiler
# cuda-core-10-2 - CUDA core tools
# cuda-cudart-10-2 - CUDA Runtime native Libraries
# cuda-cudart-dev-10-2 - CUDA Runtime native dev links, headers
# cuda-cufft-10-2 - CUFFT native runtime libraries
# cuda-cufft-dev-10-2 - CUFFT native dev links, headers
# cuda-cuobjdump-10-2 - CUDA cuobjdump
# cuda-cupti-10-2 - CUDA profiling tools runtime libs.
# cuda-cupti-dev-10-2 - CUDA profiling tools interface.
# cuda-curand-10-2 - CURAND native runtime libraries
# cuda-curand-dev-10-2 - CURAND native dev links, headers
# cuda-cusolver-10-2 - CUDA solver native runtime libraries
# cuda-cusolver-dev-10-2 - CUDA solver native dev links, headers
# cuda-cusparse-10-2 - CUSPARSE native runtime libraries
# cuda-cusparse-dev-10-2 - CUSPARSE native dev links, headers
# cuda-documentation-10-2 - CUDA documentation
# cuda-driver-dev-10-2 - CUDA Driver native dev stub library
# cuda-gdb-10-2 - CUDA-GDB
# cuda-gdb-src-10-2 - Contains the source code for cuda-gdb
# cuda-libraries-10-2 - CUDA Libraries 10.2 meta-package
# cuda-libraries-dev-10-2 - CUDA Libraries 10.2 development meta-package
# cuda-license-10-2 - CUDA licenses
# cuda-memcheck-10-2 - CUDA-MEMCHECK
# cuda-minimal-build-10-2 - Minimal CUDA 10.2 toolkit build packages.
# cuda-misc-headers-10-2 - CUDA miscellaneous headers
# cuda-npp-10-2 - NPP native runtime libraries
# cuda-npp-dev-10-2 - NPP native dev links, headers
# cuda-nvcc-10-2 - CUDA nvcc
# cuda-nvdisasm-10-2 - CUDA disassembler
# cuda-nvgraph-10-2 - NVGRAPH native runtime libraries
# cuda-nvgraph-dev-10-2 - NVGRAPH native dev links, headers
# cuda-nvml-dev-10-2 - NVML native dev links, headers
# cuda-nvprof-10-2 - CUDA Profiler tools
# cuda-nvprune-10-2 - CUDA nvprune
# cuda-nvrtc-10-2 - NVRTC native runtime libraries
# cuda-nvrtc-dev-10-2 - NVRTC native dev links, headers
# cuda-nvtx-10-2 - NVIDIA Tools Extension
# cuda-samples-10-2 - CUDA example applications
# cuda-toolkit-10-2 - CUDA Toolkit 10.2 meta-package
# cuda-tools-10-2 - CUDA Tools meta-package

WORKDIR /usr/src/app/build

# install cuda, cuda compiler, and some utilities
# compile and install opencv with cuda and cudnn
# https://github.com/opencv/opencv/blob/4.4.0/CMakeLists.txt
RUN sed -i 's/r32/r32.4/g' /etc/apt/sources.list.d/nvidia.list && \
    install_packages $OPENCV_DEPENDS $OPENCV_RDEPENDS && \
    curl -fsSL https://github.com/opencv/opencv/archive/${OPENCV_RELEASE}.tar.gz | \
        tar xz --strip-components=1 -C ../ && \
    curl -fsSL https://github.com/opencv/opencv_contrib/archive/${OPENCV_RELEASE}.tar.gz | \
        tar xz --strip-components=1 -C ../ opencv_contrib-${OPENCV_RELEASE}/modules && \
    cmake \
        -D CMAKE_BUILD_TYPE=RELEASE \
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
        -D HAVE_opencv_python3=ON \
        -D PYTHON_EXECUTABLE=/bin/python \
        -D BUILD_TESTS=OFF \
	    -D BUILD_PERF_TESTS=OFF \
        -D BUILD_SAMPLES=OFF \
        -D BUILD_EXAMPLES=OFF \
        -D BUILD_DOCS=OFF .. && \
    make -j "$(nproc)" && make install && ldconfig && rm -rf ./*
    # apt-get purge -y --auto-remove $OPENCV_DEPENDS

ENV LD_LIBRARY_PATH /usr/local/cuda/lib64/stubs

WORKDIR /usr/src/app

ARG ZONEMINDER_RELEASE=1.34

# install zoneminder and dependencies
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABE4C7F993453843F0AEB8154D0BF748776FFB04 && \
    echo deb http://ppa.launchpad.net/iconnor/zoneminder-${ZONEMINDER_RELEASE}/ubuntu bionic main > /etc/apt/sources.list.d/zoneminder.list && \
    install_packages \
        apache2 \
        gettext-base \
        libapache2-mod-php \
        libvlc-bin \
        mariadb-client \
        php-fpm \
        va-driver-all \
        vdpau-driver-all \
        zoneminder && \
    a2enconf zoneminder && a2enmod rewrite cgi

ARG PYTHON_RELEASE=3.9

# install newer python & pip than bionic provides
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776 && \
    echo deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu bionic main > /etc/apt/sources.list.d/deadsnakes.list && \
    install_packages \
        python${PYTHON_RELEASE} \
        python${PYTHON_RELEASE}-dev \
        python${PYTHON_RELEASE}-distutils && \
    ln -sf /usr/bin/python${PYTHON_RELEASE} /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py | python3

# zmes build dependencies (removed post-install)
ARG ZMES_DEPENDS=" \
    build-essential \
    file git wget \
    libgeos-dev \
    libmodule-build-perl \
    libjpeg-dev \
    zlib1g-dev \
"

# zmes runtime dependencies
ARG ZMES_RDEPENDS=" \
    gifsicle \
    libjson-perl \
    libyaml-perl \
    sudo \
"

# eventserver installer args
# https://github.com/pliablepixels/zmeventnotification/releases
ARG ZMES_RELEASE=v6.1.11
ARG INSTALL_YOLOV3=no
ARG INSTALL_TINYYOLOV3=no
ARG INSTALL_YOLOV4=no
ARG INSTALL_TINYYOLOV4=yes
ARG INSTALL_CORAL_EDGETPU=no

# install eventserver and machine learning hooks
# https://zmeventnotification.readthedocs.io/en/stable/guides/install.html
RUN install_packages $ZMES_DEPENDS $ZMES_RDEPENDS && \
    perl -MCPAN -e "install Crypt::MySQL" && \
    perl -MCPAN -e "install Net::WebSocket::Server" && \
    perl -MCPAN -e "install LWP::Protocol::https" && \
    perl -MCPAN -e "install Config::IniFiles" && \
    perl -MCPAN -e "install Net::MQTT::Simple" && \
    perl -MCPAN -e "install Net::MQTT::Simple::Auth" && \
    perl -MCPAN -e "install Getopt::Long" && \
    curl -fsSL https://github.com/pliablepixels/zmeventnotification/archive/${ZMES_RELEASE}.tar.gz | \
    tar xz --strip-components=1 && \
    ./install.sh --no-interactive --install-es --install-config --install-hook | tee install.log && \
    if grep -q ERROR install.log ; then exit 1 ; fi && rm -rf ./*
    # apt-get purge -y --auto-remove $ZMES_DEPENDS

WORKDIR /etc/zm

# configuration files
COPY secrets.ini /etc/zm/secrets.ini.in
COPY zmeventnotification.ini /etc/zm/zmeventnotification.ini
COPY objectconfig.ini /etc/zm/objectconfig.ini

# default secrets values
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
RUN usermod -aG video www-data

COPY init.sh /

RUN chmod a+x /init.sh

CMD [ "/init.sh" ]

COPY check_cuda.py check_opencv.py /etc/zm/
