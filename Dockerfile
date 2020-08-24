FROM php:7.0-apache

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
            php7.0-dev \
            php7.0-cli \
            php7.0-apcu \
            php7.0-json \
            php7.0-ldap \
            php7.0-mbstring \
            php7.0-mysql \
            php7.0-pgsql \
            php7.0-sqlite3 \
            php7.0-xml \
            php7.0-xsl \
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
            php7.0-xmlrpc \
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
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    composer global require hirak/prestissimo
