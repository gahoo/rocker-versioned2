#!/bin/bash

set -e

apt update
apt install -y -V ca-certificates lsb-release wget
wget http://172.17.0.1:9000/apache.bintray.com/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-archive-keyring-latest-$(lsb_release --codename --short).deb
apt install -y -V ./apache-arrow-archive-keyring-latest-$(lsb_release --codename --short).deb
sed 's#https://#http://172.17.0.1:9000/#g' /etc/apt/sources.list.d/apache-arrow.sources -i
apt update
apt install -y -V libarrow-dev # For C++
apt install -y -V libarrow-glib-dev # For GLib (C)
apt install -y -V libarrow-dataset-dev # For Arrow Dataset C++
apt install -y -V libarrow-flight-dev # For Flight C++
#apt install -y -V libplasma-dev # For Plasma C++
#apt install -y -V libplasma-glib-dev # For Plasma GLib (C)
apt install -y -V libgandiva-dev # For Gandiva C++
apt install -y -V libgandiva-glib-dev # For Gandiva GLib (C)
apt install -y -V libparquet-dev # For Apache Parquet C++
apt install -y -V libparquet-glib-dev # For Apache Parquet GLib (C)

install2.r arrow
rm apache-arrow-archive-keyring-latest-bionic.deb

# install pyarrow
apt install -y libarrow-python-dev
export ARROW_HOME=/usr/
export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
pip3 install --no-dependencies -i https://mirrors.aliyun.com/pypi/simple pyarrow

apt-get clean
rm -rf /var/lib/apt/lists/*
