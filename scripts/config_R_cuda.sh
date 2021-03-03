#!/bin/bash

set -e

## nvidia-container-runtime
NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:-"compute,utility"}
NVIDIA_REQUIRE_CUDA=${NVIDIA_REQUIRE_CUDA:-"cuda>=10.2 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411"}

## These should be exported as ENV vars too
CUDA_HOME=${CUDA_HOME:-/usr/local/cuda}
PATH={$PATH:-$PATH:$CUDA_HOME/bin}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-$LD_LIBRARY_PATH:$CUDA_HOME/lib64:$CUDA_HOME/extras/CUPTI/lib64}
NVBLAS_CONFIG_FILE=${NVBLAS_CONFIG_FILE:-/etc/nvblas.conf}

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
#ln -s /usr/local/cuda-10.2 /usr/local/cuda
ln -s $CUDA_HOME/lib64/stubs/libcuda.so $CUDA_HOME/lib64/stubs/libcuda.so.1
echo "$CUDA_HOME/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf
ldconfig

## CUDA environmental variables configuration for RStudio

## cli R inherits these, but RStudio needs to have these set in as follows:
## (From https://tensorflow.rstudio.com/tools/local_gpu.html#environment-variables)
echo "CUDA_HOME=$CUDA_HOME" >> ${R_HOME}/etc/Renviron 
echo "PATH=$PATH" >> ${R_HOME}/etc/Renviron 

if test -f /etc/rstudio/rserver.conf; then 
  sed -i '/^rsession-ld-library-path/d' /etc/rstudio/rserver.conf
  echo "rsession-ld-library-path=$LD_LIBRARY_PATH" >> /etc/rstudio/rserver.conf
fi


## nvblas configuration
touch /var/log/nvblas.log && chown :staff /var/log/nvblas.log
chmod a+rw /var/log/nvblas.log

## Configure R & RStudio to use drop-in CUDA blas
## Allow R to use CUDA for BLAS, with fallback on openblas
echo 'NVBLAS_LOGFILE /var/log/nvblas.log
NVBLAS_CPU_BLAS_LIB /usr/lib/aarch64-linux-gnu/openblas/libblas.so.3
NVBLAS_GPU_LIST ALL' > /etc/nvblas.conf

echo "NVBLAS_CONFIG_FILE=$NVBLAS_CONFIG_FILE" >> ${R_HOME}/etc/Renviron


## We don't want to set LD_PRELOAD globally
##ENV LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libnvblas.so
#
### Instead, we will set it before calling R, Rscript, or RStudio:
#mv /usr/bin/R /usr/bin/R_
#mv /usr/bin/Rscript /usr/bin/Rscript_
#
#echo '\#!/bin/sh \
#      \n LD_PRELOAD=/usr/local/cuda/lib64/libnvblas.so /usr/bin/R_ "$@"' \
#      > /usr/bin/R && \
#    chmod +x /usr/bin/R && \
#    echo '#!/bin/sh \
#          \n LD_PRELOAD=/usr/local/cuda/lib64/libnvblas.so /usr/bin/Rscript_ "$@"' \
#      > /usr/bin/Rscript && \
#    chmod +x /usr/bin/Rscript
#
#echo '#!/usr/bin/with-contenv bash \
#      \n## load /etc/environment vars first: \
#      \n for line in \$( cat /etc/environment ) ; do export $line ; done \
#      \n export LD_PRELOAD=/usr/local/cuda/lib64/libnvblas.so \
#      \n exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0' \
#      > /etc/services.d/rstudio/run


