FROM php:7.3-apache

ARG PSR_VERSION=1.0.0
ARG PHALCON_VERSION=3.4.5

RUN rm /etc/apt/preferences.d/no-debian-php
RUN set -xe && \
        DEBIAN_FRONTEND=noninteractive && \
        apt-get update && apt-get install -yq \
            git \
            libpng-dev \
            zlib1g-dev \
            libwebp-dev \
            libjpeg62-turbo-dev \
            libxpm-dev \
            libfreetype6-dev \
            libxml2-dev \
            libgeoip-dev  \
            unzip \
            php7.3-dev \
            php7.3-cli \
            php7.3-apcu \
            php7.3-json \
            php7.3-ldap \
            php7.3-mbstring \
            php7.3-mysql \
            php7.3-pgsql \
            php7.3-sqlite3 \
            php7.3-xml \
            php7.3-xsl \
            php7.3-soap \
            php7.3-opcache \
            php7.3-pdo \
            php7.3-curl \
            php7.3-igbinary \
            php7.3-bz2 \
            php7.3-geoip \
            php7.3-imagick \
            php7.3-imap \
            php7.3-mcrypt \
            php7.3-redis \
            php7.3-xmlrpc \
            php7.3-intl \
        && rm -rf /var/lib/apt/lists/*

# Download PSR, see https://github.com/jbboehr/php-psr
RUN curl -LO https://github.com/jbboehr/php-psr/archive/v${PSR_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PSR_VERSION}.tar.gz && \
        # Download Phalcon
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PHALCON_VERSION}.tar.gz && \
        docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) \
            ${PWD}/php-psr-${PSR_VERSION} \
            ${PWD}/cphalcon-${PHALCON_VERSION}/build/${PHALCON_EXT_PATH}/php7/64bits/ && \
        # Remove all temp files
        rm -r \
            ${PWD}/v${PSR_VERSION}.tar.gz \
            ${PWD}/php-psr-${PSR_VERSION} \
            ${PWD}/v${PHALCON_VERSION}.tar.gz \
            ${PWD}/cphalcon-${PHALCON_VERSION}

RUN docker-php-ext-install gd pdo_mysql mysqli soap zip sockets

RUN pecl install rar
RUN pecl install apcu

RUN docker-php-ext-enable rar apcu sockets && \
    phpenmod pdo pdo_mysql soap apcu mysqli zip && \
    a2enmod rewrite headers && \
    php -m

# Locales
RUN echo "Europe/Moscow" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Install parallel composer module
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
