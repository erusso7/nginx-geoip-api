FROM php:8-fpm-alpine

RUN apk add --no-cache nginx s6 php-opcache \
    && docker-php-ext-install opcache

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === trim(file_get_contents('https://composer.github.io/installer.sig'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php

RUN rm -rf /var/www && mkdir /var/www

WORKDIR /var/www
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-suggest

COPY ./docker/s6 /etc/s6
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/nginx/app.conf /etc/nginx/conf.d/default.conf

COPY ./docker/php-fpm/php.ini /usr/local/etc/php/php.ini
COPY ./docker/php-fpm/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./docker/php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf

#Mute the container logs
RUN sed -i  's/^access.log/;access.log/' /usr/local/etc/php-fpm.d/docker.conf

COPY ./public ./public
COPY ./_data ./_data

CMD ["/bin/s6-svscan","/etc/s6"]