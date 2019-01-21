FROM genkaok/php7.0-apache2

# PhalconPHP
RUN wget https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh && bash script.deb.sh
RUN apt-get update && apt-get install php7.0-phalcon

# Install parallel composer module
RUN composer global require hirak/prestissimo