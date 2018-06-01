FROM php:5.6-fpm

RUN apt-get update && apt-get install -y \
        git-core zlib1g-dev \
        libicu-dev libmcrypt-dev libbz2-dev libxslt-dev curl unzip wget libmemcached-dev telnet \
    && docker-php-ext-install -j$(nproc) mysqli intl bcmath mcrypt zip bz2 mbstring pcntl xsl pdo pdo_mysql soap

ENV XDEBUG_VERSION 2.4.0

RUN set -xe && \
  cd /tmp && \
  wget http://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz && \
  tar -xvzf xdebug-$XDEBUG_VERSION.tgz && \
  cd xdebug-$XDEBUG_VERSION && \
  phpize && \
  ./configure && \
  make && \
  make install && \
  rm -rf /tmp/xdebug-$XDEBUG_VERSION

RUN usermod -u $LOCAL_USER_ID www-data

RUN pecl install memcached-2.2.0
RUN pecl install memcache-3.0.8
RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini
RUN echo extension=memcache.so >> /usr/local/etc/php/conf.d/memcache.ini

COPY custom.ini /usr/local/etc/php/conf.d/20-custom.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/20-xdebug.ini

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

WORKDIR "/var/www"