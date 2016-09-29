FROM centos:7

MAINTAINER fising <fising@qq.com>

ENV PHP_VERSION 7.0.11
ENV PHP_FPM_PORT 9000

RUN yum update -y && yum -y install wget gcc gcc-c++ libxml2 libxml2-devel openssl openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel

WORKDIR /usr/local/src/

RUN wget ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/libmcrypt/libmcrypt-2.5.7.tar.gz && \
    tar xzvf libmcrypt-2.5.7.tar.gz && \
    cd libmcrypt-2.5.7 && \
    ./configure --prefix=/usr/local --disable-posix-threads && \
    make && \
    make install && \
    cd ..

RUN wget -O php-${PHP_VERSION}.tar.gz http://cn2.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror && \
    tar xzvf php-${PHP_VERSION}.tar.gz && \
    cd php-${PHP_VERSION} && \
    ./configure --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-mcrypt=/usr/local \
    --enable-mysqlnd \
    --with-mysqli \
    --with-pdo-mysql \
    --enable-fpm \
    --with-fpm-user=nginx \
    --with-fpm-group=nginx \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-gd-native-ttf \
    --with-openssl \
    --enable-pcntl \
    --enable-sockets \
    --with-xmlrpc \
    --enable-zip \
    --enable-soap \
    --without-pear \
    --with-gettext \
    --enable-session \
    --with-curl \
    --with-jpeg-dir \
    --with-freetype-dir \
    --enable-opcache && \
    make && \
    make install && \
    cp php.ini-development /usr/local/php/etc/php.ini && \
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
    groupadd www && \
    useradd -g www -s /sbin/nologin www && \
    sed 's/user = nginx/user = www/;s/group = nginx/group = www/' /usr/local/php/etc/php-fpm.d/www.conf.default > /usr/local/php/etc/php-fpm.d/www.conf

EXPOSE $PHP_FPM_PORT

VOLUME ["/app"]

ENTRYPOINT /usr/local/php/sbin/php-fpm && /bin/bash
