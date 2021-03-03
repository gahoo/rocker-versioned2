#!/bin/bash

set -e

export MAKEFLAGS="-j"`nproc`
# Step 2: Setting Up the Ubuntu Docker Container
apt update && apt upgrade -y
apt install git \
    wget \
    libssl-dev \
    autoconf \
    flex \
    bison \
    llvm-8 \
    clang \
    cmake \
    python3-pip \
    libcurl4-openssl-dev \
    libjemalloc-dev \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-regex-dev  \
    python3-dev -y

# newer version required
#    libgrpc-dev \
#    libgrpc++-dev \

apt-get clean
rm -rf /var/lib/apt/lists/*

# Step 4: Installing Remaining Apache Arrow Dependencies
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ cython
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ wheel
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ setuptools_scm
#pip3 install -i https://mirrors.aliyun.com/pypi/simple/ numpy
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ http://172.17.0.1:9000/wheels/numpy-1.19.5-cp36-cp36m-linux_aarch64.whl
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ http://172.17.0.1:9000/wheels/pandas-1.1.5-cp36-cp36m-linux_aarch64.whl
#pip3 install -i https://mirrors.aliyun.com/pypi/simple/ six pandas pytest hypothesis grpcio
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ pytest hypothesis
