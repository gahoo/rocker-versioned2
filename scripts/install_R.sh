#!/bin/bash
set -e

sed 's#ports.ubuntu.com#mirrors.aliyun.com#g' /etc/apt/sources.list -i
echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy
echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
apt-get update && apt-get -y install lsb-release

UBUNTU_VERSION=${UBUNTU_VERSION:-`lsb_release -sc`}
LANG=${LANG:-en_US.UTF-8}
LC_ALL=${LC_ALL:-en_US.UTF-8}
CRAN=${CRAN:-/rocker_scripts/install_R.sh}

##  mechanism to force source installs if we're using RSPM
#CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION"/""}
CRAN_SOURCE="https://mirrors.aliyun.com/CRAN/"

export DEBIAN_FRONTEND=noninteractive

# Set up and install R
R_HOME=${R_HOME:-/usr/local/lib/R}



READLINE_VERSION=8
OPENBLAS=libopenblas-dev
if [ ${UBUNTU_VERSION} == "bionic" ]; then
  READLINE_VERSION=7
  OPENBLAS=libopenblas-dev
fi

apt-get update \
  && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    devscripts \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-* \
    libcurl4 \
    libicu* \
    libpcre2* \
    libjpeg-turbo* \
    ${OPENBLAS} \
    libpangocairo-* \
    libpng16* \
    libreadline${READLINE_VERSION} \
    libtiff* \
    liblzma* \
    libxt6 \
    locales \
    make \
    unzip \
    zip \
    zlib1g

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen en_US.utf8
/usr/sbin/update-locale LANG=en_US.UTF-8

BUILDDEPS="curl \
    default-jdk \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libpcre2-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    perl \
    rsync \
    subversion \
    tcl-dev \
    tk-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    texlive-latex-extra \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    wget \
    zlib1g-dev"

apt-get install -y --no-install-recommends $BUILDDEPS


if [[ "$R_VERSION" == "devel" ]]; then                               \
    wget https://stat.ethz.ch/R/daily/R-devel.tar.gz;                \
elif [[ "$R_VERSION" == "patched" ]]; then                           \
    wget https://stat.ethz.ch/R/daily/R-patched.tar.gz;              \
else                                                                 \
    wget https://mirrors.aliyun.com/CRAN/src/base/R-3/R-${R_VERSION}.tar.gz || \
    wget http://172.17.0.1:9000/mirrors.aliyun.com/CRAN/src/base/R-4/R-${R_VERSION}.tar.gz; \
fi &&                                                                \
    tar xzf R-${R_VERSION}.tar.gz &&   

cd R-${R_VERSION}
R_PAPERSIZE=letter \
R_BATCHSAVE="--no-save --no-restore" \
R_BROWSER=xdg-open \
PAGER=/usr/bin/pager \
PERL=/usr/bin/perl \
R_UNZIPCMD=/usr/bin/unzip \
R_ZIPCMD=/usr/bin/zip \
R_PRINTCMD=/usr/bin/lpr \
LIBnn=lib \
AWK=/usr/bin/awk \
CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
./configure --enable-R-shlib \
		   --enable-memory-profiling \
		   --with-readline \
		   --with-blas \
		   --with-lapack \
		   --with-tcltk \
		   --disable-nls \
		   --with-recommended-packages
make
make install
make clean

## Add a default CRAN mirror
echo "options(repos = c(CRAN = '${CRAN}'), download.file.method = 'libcurl')" >> ${R_HOME}/etc/Rprofile.site

## Set HTTPUserAgent for RSPM (https://github.com/rocker-org/rocker/issues/400)
echo  'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), 
                 paste(getRversion(), R.version$platform, 
                       R.version$arch, R.version$os)))' >> ${R_HOME}/etc/Rprofile.site


## Add a library directory (for user-installed packages)
mkdir -p ${R_HOME}/site-library
chown root:staff ${R_HOME}/site-library
chmod g+ws ${R_HOME}/site-library

## Fix library path
echo "R_LIBS=\${R_LIBS-'${R_HOME}/site-library:${R_HOME}/library'}" >> ${R_HOME}/etc/Renviron
echo "TZ=${TZ}" >> ${R_HOME}/etc/Renviron

## Use littler installation scripts
Rscript -e "install.packages(c('littler', 'docopt'), repos='${CRAN_SOURCE}')"
ln -s ${R_HOME}/site-library/littler/examples/install2.r /usr/local/bin/install2.r
ln -s ${R_HOME}/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r
ln -s ${R_HOME}/site-library/littler/bin/r /usr/local/bin/r


## Clean up from R source install
cd /
rm -rf /tmp/*
rm -rf R-${R_VERSION}
rm -rf R-${R_VERSION}.tar.gz
apt-get remove --purge -y $BUILDDEPS
apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*


