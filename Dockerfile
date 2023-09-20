FROM php:8.2-fpm-alpine AS php_upstream
FROM nginx:alpine as nginx_upstream
FROM composer/composer:2-bin AS composer_upstream

FROM php_upstream AS php

# Install php extensions using docker-php-extension-installer from github.com/mlocati
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions
RUN install-php-extensions \
    intl \
    opcache \
    zip \
    pdo \
    pdo_mysql

# install composer
COPY --from=composer_upstream --link /composer /usr/bin/composer

# install nodejs
RUN apk add --no-cache nodejs npm

# copy project
COPY . /var/www/app/

# install project dependencies
RUN cd /var/www/app/ && \
    composer install && \
    npm init -y && \
    npm install --force

WORKDIR /var/www/app

EXPOSE 9000

FROM nginx_upstream as nginx

# copy nginx config
COPY ./docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# copy project
COPY . /var/www/app

EXPOSE 9000
