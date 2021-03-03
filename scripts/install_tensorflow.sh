#!/bin/bash
set -e

export MAKEFLAGS="-j"`nproc`
TENSORFLOW_VERSION=${1:-${TENSORFLOW_VERSION:-default}}
KERAS_VERSION=${2:-${KERAS_VERSION:-default}}

## Install python dependency
#/rocker_scripts/install_python.sh
apt-get update && apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ -U pip testresources setuptools==49.6.0
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ -U numpy==1.16.1 future==0.18.2 mock==3.0.5 h5py==2.10.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host 172.17.0.1 --pre --extra-index-url http://172.17.0.1:9000/developer.download.nvidia.com/compute/redist/jp/v44 tensorflow
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ keras

## To support different version of TF, install to different virtualenvs
TENSORFLOW_VENV=$PYTHON_VENV_PATH
install2.r --error --skipinstalled keras
#Rscript -e "keras::install_keras(version = \"$KERAS_VERSION\", \
#                                 tensorflow = \"$TENSORFLOW_VERSION\", \
#                                 envname =\"$TENSORFLOW_VENV\")"

rm -r /tmp/downloaded_packages

chown -R 1000:1000 /opt/venv
chmod -R 777 /opt/venv

