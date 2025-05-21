FROM ubuntu:22.04

ARG TZ=America/New_York
ENV TZ=$TZ
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata \
        curl \
        wget \
        git \
        build-essential \
        cmake \
        libglib2.0-dev \
        libtool \
        pkg-config \
        ca-certificates \
        gnupg \
        ffmpeg \
        php-cli \
        php-curl \
        php-mbstring \
        php-xml \
        php-zip && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Build and install libmp4v2 from source
# Set git to use unauthenticated HTTPS without asking
# Build and install libmp4v2 from source without git
RUN curl -L https://github.com/enzo1982/libmp4v2/archive/refs/heads/master.zip -o /tmp/libmp4v2.zip && \
    apt-get install -y unzip && \
    unzip /tmp/libmp4v2.zip -d /tmp && \
    cd /tmp/libmp4v2-master && \
    mkdir -p build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/libmp4v2*



# Install m4b-tool binary
COPY m4b-tool.phar /usr/local/bin/m4b-tool
RUN chmod +x /usr/local/bin/m4b-tool

# Bind volumes
VOLUME /config
VOLUME /temp

# Optional runtime envs
ENV PUID=""
ENV PGID=""
ENV CPU_CORES=""
ENV SLEEPTIME=""

LABEL Description="m4b-tool container with PHP 8.x and libmp4v2 from source"

CMD ["sleep", "infinity"]
