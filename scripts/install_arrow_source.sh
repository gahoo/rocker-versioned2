#!/bin/bash

set -e

export MAKEFLAGS="-j"`nproc`
# Step 3: Cloning Apache Arrow From GitHub
wget http://172.17.0.1:9000/github.com/apache/arrow/archive/apache-arrow-3.0.0.tar.gz
tar -xf apache-arrow-3.0.0.tar.gz
cd arrow-apache-arrow-3.0.0/

wget http://172.17.0.1:9000/github.com/apache/parquet-testing/archive/master.zip
unzip master.zip
mv parquet-testing-master cpp/submodules/parquet-testing
rm master.zip
export PARQUET_TEST_DATA="${PWD}/cpp/submodules/parquet-testing/data"
export ARROW_TEST_DATA="${PWD}/testing/data"

cd cpp
sed 's#https://#http://172.17.0.1:9000/#g' ./thirdparty/versions.txt ./cmake_modules/ThirdpartyToolchain.cmake -i

# Step 5: Building Apache Arrow C++ Library
export ARROW_HOME=/usr/local/arrow
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ARROW_HOME/lib:/usr/lib/aarch64-linux-gnu/tegra/
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
-DARROW_DEPENDENCY_SOURCE=BUNDLED \
-DARROW_CSV=ON \
-DARROW_JSON=ON \
-DCMAKE_INSTALL_LIBDIR=lib \
-DARROW_FILESYSTEM=ON \
-DARROW_S3=ON \
-DARROW_FLIGHT=ON \
-DARROW_GANDIVA=ON \
-DARROW_ORC=ON \
-DARROW_WITH_BZ2=ON \
-DARROW_WITH_ZLIB=ON \
-DARROW_WITH_ZSTD=ON \
-DARROW_WITH_LZ4=ON \
-DARROW_WITH_SNAPPY=ON \
-DARROW_WITH_BROTLI=ON \
-DARROW_PARQUET=ON \
-DARROW_PYTHON=ON \
-DARROW_PLASMA=ON \
-DARROW_BUILD_TESTS=ON \
-DARROW_CUDA=ON 
make -j $(nproc)
make install

# Step 6: Building Pyarrow Wheel
cd ../../python
export PYARROW_WITH_PARQUET=ON
export PYARROW_WITH_CUDA=ON
python setup.py build_ext --build-type=release --bundle-arrow-cpp bdist_wheel
#cmake --build . --config release --
pip install dist/pyarrow-3.0.0-cp36-cp36m-linux_aarch64.whl


# Step 7: Install R packages
install2.r decor dplyr cpp11 bit64
export ARROW_R_DEV=true
export PKG_CONFIG_PATH=$ARROW_HOME/lib/pkgconfig
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/arrow/lib/
cd ../r
R CMD INSTALL .

# Cleaning up
cd ../../
rm -r arrow-apache-arrow-3.0.0/ apache-arrow-3.0.0.tar.gz
