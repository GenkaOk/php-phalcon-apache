FROM genkaok/php7.0-apache2

# PhalconPHP
RUN wget https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh && bash script.deb.sh
RUN apt-get update && apt-get install git php7.0-phalcon -y

# Locales
RUN apt-get install locales && echo "Europe/Moscow" > /etc/timezone && \
                                   dpkg-reconfigure -f noninteractive tzdata && \
                                   sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
                                   sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
                                   echo 'LANG="ru_RU.UTF-8"'>/etc/default/locale && \
                                   dpkg-reconfigure --frontend=noninteractive locales && \
                                   update-locale LANG=ru_RU.UTF-8

# Install parallel composer module
RUN composer global require hirak/prestissimo