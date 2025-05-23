FROM ubuntu:22.04

ARG TZ=America/New_York
ENV TZ=$TZ
ENV DEBIAN_FRONTEND=noninteractive

# Install general dependencies + tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    curl \
    wget \
    git \
    unzip \
    build-essential \
    cmake \
    autoconf \
    automake \
    libtool \
    libglib2.0-dev \
    pkg-config \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    ffmpeg && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Install PHP 8.2 from Sury PPA
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    php8.2-cli \
    php8.2-curl \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Build and install libmp4v2 from sergiomb2
RUN curl -L https://github.com/sergiomb2/libmp4v2/archive/refs/heads/master.zip -o /tmp/libmp4v2.zip && \
    unzip -o /tmp/libmp4v2.zip -d /tmp && \
    cd /tmp/libmp4v2-master && \
    mkdir -p m4 && \
    autoreconf -i && \
    ./configure CXXFLAGS="-Wno-narrowing" && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/libmp4v2*

# Add m4b-tool
COPY m4b-tool.phar /usr/local/bin/m4b-tool
RUN chmod +x /usr/local/bin/m4b-tool

# Add batch conversion scripts
COPY config/batch-m4b-builder.sh /usr/local/bin/batch-m4b-builder.sh
COPY config/file-m4b-builder.sh /usr/local/bin/file-m4b-builder.sh
COPY config/track-m4b-builder.sh /usr/local/bin/track-m4b-builder.sh
RUN chmod +x /usr/local/bin/batch-m4b-builder.sh
RUN chmod +x /usr/local/bin/file-m4b-builder.sh
RUN chmod +x /usr/local/bin/track-m4b-builder.sh

# Optional bind volumes
VOLUME /config
VOLUME /temp

# Optional envs for runtime customization
ENV PUID=""
ENV PGID=""
ENV CPU_CORES=""
ENV SLEEPTIME=""

LABEL Description="m4b-tool container with PHP 8.2, libmp4v2, and embedded batch builder script"

CMD ["sleep", "infinity"]
