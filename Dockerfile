FROM devilbox/php-fpm-5.3

# Install selected extensions and other stuff
RUN apt-get update && apt-get install -y \
        git-core zlib1g-dev \
        libicu-dev libmcrypt-dev libbz2-dev libxslt-dev curl unzip wget \
    && docker-php-ext-install -j$(nproc) mysqli intl bcmath mcrypt zip bz2 mbstring pcntl xsl pdo pdo_mysql

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

# Install Composer
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot && rm -rf /tmp/composer-setup.php

WORKDIR "/var/www"
