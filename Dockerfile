FROM php:7.0-apache

ARG PSR_VERSION=1.0.0
ARG PHALCON_VERSION=3.4.5

RUN rm /etc/apt/preferences.d/no-debian-php
RUN set -xe && \
        apt-get update && apt-get install -y \
            git \
            php7.0-dev \
            php7.0-cli \
            php7.0-apcu \
            php7.0-gd \
            php7.0-json \
            php7.0-ldap \
            php7.0-mbstring \
            php7.0-mysql \
            php7.0-pgsql \
            php7.0-sqlite3 \
            php7.0-xml \
            php7.0-xsl \
            php7.0-zip \
            php7.0-soap \
            php7.0-opcache \
            php7.0-pdo \
            php7.0-curl \
            php7.0-igbinary \
            php7.0-bz2 \
            php7.0-geoip \
            php7.0-imagick \
            php7.0-imap \
            php7.0-mcrypt \
            php7.0-redis \
            php7.0-xmlrpc && \
        # Download PSR, see https://github.com/jbboehr/php-psr
        curl -LO https://github.com/jbboehr/php-psr/archive/v${PSR_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PSR_VERSION}.tar.gz && \
        # Download Phalcon
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PHALCON_VERSION}.tar.gz && \
        docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) \
            ${PWD}/php-psr-${PSR_VERSION} \
            ${PWD}/cphalcon-${PHALCON_VERSION}/build/${PHALCON_EXT_PATH}/php7/64bits/ \
        && \
        pecl install rar && \
        pecl install apcu && \
        docker-php-ext-install pdo_mysql mysqli && \
        docker-php-ext-enable pdo_mysql mysqli rar apcu && \
        # Remove all temp files
        rm -r \
            ${PWD}/v${PSR_VERSION}.tar.gz \
            ${PWD}/php-psr-${PSR_VERSION} \
            ${PWD}/v${PHALCON_VERSION}.tar.gz \
            ${PWD}/cphalcon-${PHALCON_VERSION} \
        && \
        php -m

# PhalconPHP
#RUN wget https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh && bash script.deb.sh
#RUN apt-get update && apt-get install git php7.0-phalcon -y

# Locales
RUN echo "Europe/Moscow" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

RUN a2enmod rewrite headers

# Install parallel composer module
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    composer global require hirak/prestissimo