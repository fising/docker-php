FROM centos:7

MAINTAINER fising <fising@qq.com>

ENV NGINX_VERSION 1.10.1
ENV PHP_VERSION 7.0.11
ENV NGINX_PORT 80

RUN yum update -y && yum -y install wget gcc gcc-c++ autoconf automake libtool make cmake zlib zlib-devel pcre-devel libxml2 libxml2-devel openssl openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel

WORKDIR /usr/local/src/

RUN wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.39.tar.gz && \
    tar xzvf pcre-8.39.tar.gz

RUN groupadd nginx && \
    useradd -g nginx -s /sbin/nologin -M nginx && \
    wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    ./configure --prefix=/usr/local/nginx --with-http_ssl_module --user=nginx --group=nginx --with-pcre=/usr/local/src/pcre-8.39 --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module && \
    make && \
    make install && \
    cd ..

RUN wget ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/libmcrypt/libmcrypt-2.5.7.tar.gz && \
    tar xzvf libmcrypt-2.5.7.tar.gz && \
    cd libmcrypt-2.5.7 && \
    ./configure --prefix=/usr/local --disable-posix-threads && \
    make && \
    make install && \
    cd ..

RUN groupadd www && \
    useradd -g www -s /sbin/nologin -M www && \
    wget -O php-${PHP_VERSION}.tar.gz http://cn2.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror && \
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
    sed 's/user = nginx/user = www/;s/group = nginx/group = www/' /usr/local/php/etc/php-fpm.d/www.conf.default > /usr/local/php/etc/php-fpm.d/www.conf

COPY nginx.conf /usr/local/nginx/conf/nginx.conf

EXPOSE $NGINX_PORT

VOLUME ["/app"]

ENTRYPOINT /usr/local/php/sbin/php-fpm && /usr/local/nginx/sbin/nginx && /bin/bash
