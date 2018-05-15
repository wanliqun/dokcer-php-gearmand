FROM php:7

# Install the required packages
RUN apt-get update && apt-get install -y wget vim git  supervisor \
        gcc autoconf bison flex make libboost-all-dev libtool libevent-dev uuid-dev gperf

# Install Gearmand
ENV GEARMAND_VERSION='1.1.18'
RUN \
    mkdir /gearman-srv && cd /gearman-srv && \
    wget https://github.com/gearman/gearmand/releases/download/$GEARMAND_VERSION/gearmand-$GEARMAND_VERSION.tar.gz && \
    tar -xvf gearmand-$GEARMAND_VERSION.tar.gz && \
    rm -fr gearmand-$GEARMAND_VERSION.tar.gz && \
    cd gearmand-$GEARMAND_VERSION && \
    ./configure && make && make install

# Compile & Build Pecl Gearman
ENV GEARMAN_VERSION='2.0.3'
RUN \
    mkdir /gearman-ext && cd /gearman-ext && \
    wget https://github.com/wcgallego/pecl-gearman/archive/gearman-$GEARMAN_VERSION.tar.gz && \
    tar -xvf gearman-$GEARMAN_VERSION.tar.gz && \
    mv pecl-gearman-gearman-$GEARMAN_VERSION gearman-$GEARMAN_VERSION && \
    rm -fr gearman-$GEARMAN_VERSION.tar.gz && \
    cd gearman-$GEARMAN_VERSION && \
    phpize && \
    ./configure && \
    make && make install

# Clean stuff
RUN rm -fr /gearman-srv /gearman-ext

# Enable gearman extension
RUN docker-php-ext-enable gearman.so

# Load dynamic library
RUN ldconfig

CMD ["supervisord"]
