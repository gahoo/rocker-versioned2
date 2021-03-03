#!/bin/bash
set -e

## Also symlinks pandoc, pandoc-citeproc so they are available system-wide,
export PATH=/usr/local/lib/rstudio-server/bin:$PATH

## RStudio wants an /etc/R, will populate from $R_HOME/etc
mkdir -p /etc/R
echo "PATH=${PATH}" >> ${R_HOME}/etc/Renviron

## Make RStudio compatible with case when R is built from source 
## (and thus is at /usr/local/bin/R), because RStudio doesn't obey
## path if a user apt-get installs a package
R_BIN=`which R`
mkdir -p /etc/rstudio
echo "rsession-which-r=${R_BIN}" > /etc/rstudio/rserver.conf
## use more robust file locking to avoid errors when using shared volumes:
echo "lock-type=advisory" > /etc/rstudio/file-locks

## Prepare optional configuration file to disable authentication
## To de-activate authentication, `disable_auth_rserver.conf` script
## will just need to be overwrite /etc/rstudio/rserver.conf. 
## This is triggered by an env var in the user config
cp /etc/rstudio/rserver.conf /etc/rstudio/disable_auth_rserver.conf
echo "auth-none=1" >> /etc/rstudio/disable_auth_rserver.conf

## Set up RStudio init scripts
mkdir -p /etc/services.d/rstudio
echo '#!/usr/bin/with-contenv bash
## load /etc/environment vars first:
for line in $( cat /etc/environment ) ; do export $line > /dev/null; done
exec /usr/local/lib/rstudio-server/bin/rserver --server-daemonize 0' \
> /etc/services.d/rstudio/run

echo '#!/bin/bash
rstudio-server stop' \
> /etc/services.d/rstudio/finish

# If CUDA enabled, make sure RStudio knows (config_cuda_R.sh handles this anyway)
if [ ! -z "$CUDA_HOME" ]; then
  sed -i '/^rsession-ld-library-path/d' /etc/rstudio/rserver.conf
  echo "rsession-ld-library-path=$LD_LIBRARY_PATH" >> /etc/rstudio/rserver.conf
fi

# set up default user 
/rocker_scripts/default_user.sh

# install user config initiation script 
cp /rocker_scripts/userconf.sh /etc/cont-init.d/userconf
cp /rocker_scripts/pam-helper.sh /usr/local/lib/rstudio-server/bin/pam-helper

## Rocker's default RStudio settings, for better reproducibility
mkdir -p /home/rstudio/.rstudio/monitored/user-settings \
  && echo 'alwaysSaveHistory="0" \
          \nloadRData="0" \
          \nsaveAction="0"' \
          > /home/rstudio/.rstudio/monitored/user-settings/user-settings \
  && chown -R rstudio:rstudio /home/rstudio/.rstudio

## 
git config --system credential.helper 'cache --timeout=3600'

cp /usr/local/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d/rstudio-server

useradd -r rstudio-server
ln -f -s /usr/local/lib/rstudio-server/bin/rstudio-server /usr/sbin/rstudio-server
mkdir -p /var/run/rstudio-server
mkdir -p /var/lock/rstudio-server
mkdir -p /var/log/rstudio-server
mkdir -p /var/lib/rstudio-server

## add LD_PRELOAD to rsession
mv /usr/local/lib/rstudio-server/bin/rsession /usr/local/lib/rstudio-server/bin/rsession_

echo '#!/bin/sh
LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libnvblas.so NVBLAS_CONFIG_FILE=/etc/nvblas.conf /usr/local/lib/rstudio-server/bin/rsession_ "$@"' > /usr/local/lib/rstudio-server/bin/rsession

chmod +x /usr/local/lib/rstudio-server/bin/rsession
