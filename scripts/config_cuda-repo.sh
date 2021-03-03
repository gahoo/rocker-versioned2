#/bin/bash

set -e

SOC=${SOC:-t194}
apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 wget curl ca-certificates && \
    wget http://172.17.0.1:9000/repo.download.nvidia.com/jetson/jetson-ota-public.asc -O /etc/apt/trusted.gpg.d/jetson-ota-public.asc && \
    chmod 644 /etc/apt/trusted.gpg.d/jetson-ota-public.asc && \
    echo "deb http://172.17.0.1:9000/cn-repo.download.nvidia.com/jetson/common r32.4 main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    echo "deb http://172.17.0.1:9000/cn-repo.download.nvidia.com/jetson/${SOC} r32.4 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    mkdir -p /opt/nvidia/l4t-packages/ && \
    touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall

