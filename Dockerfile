FROM genkaok/php7.0-apache2

# PhalconPHP
RUN wget https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh && bash script.deb.sh
RUN apt-get update && apt-get install php7.0-phalcon

# Locales
RUN apt-get install locales && locale-gen ru_RU.UTF-8

# Install parallel composer module
RUN composer global require hirak/prestissimo