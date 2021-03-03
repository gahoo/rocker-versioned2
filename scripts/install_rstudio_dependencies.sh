apt-get update
apt-get install -y --no-install-recommends \
    file \
    git \
    libapparmor1 \
    libgc1c2 \
    libclang-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libobjc4 \
    libssl-dev \
    libpq5 \
    lsb-release \
    psmisc \
    procps \
    python-setuptools \
    sudo \
    pandoc \
    pandoc-citeproc \
    pandoc-citeproc-preamble \
    pandoc-data \
    time \
    cmake \
    uuid-dev \
    libpam0g-dev \
    libxml2-dev \
    openjdk-8-jdk-headless \
    openssh-client \
    wget

rm -rf /var/lib/apt/lists/*
