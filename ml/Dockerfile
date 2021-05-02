
FROM alwaysai/edgeiq:nano-0.15.1

ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV DEBIAN_FRONTEND noninteractive

# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
    crudini libev-dev libevdev2 libgeos-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /models/tinyyolov4

RUN curl -fsSL https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.weights -O  && \
	curl -fsSL https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4-tiny.cfg -O && \
	curl -fsSL https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names -O

WORKDIR /usr/src/app

ARG MLAPI_RELEASE=v2.2.18

RUN curl -fsSL https://github.com/pliablepixels/mlapi/archive/refs/tags/${MLAPI_RELEASE}.tar.gz | tar xz --strip-components 1 && \
    pip3 install --no-cache-dir -r requirements.txt

COPY check_cuda.py check_opencv.py mlapiconfig.ini secrets.ini ./

COPY init.sh /

RUN chmod a+x /init.sh

CMD [ "/init.sh" ]

ENV TZ UTC

ENV ML_USER mlapi
ENV ML_PASSWORD mlapi
ENV ZM_PORTAL http://zm/zm
ENV ZM_API_PORTAL http://zm/zm/api
