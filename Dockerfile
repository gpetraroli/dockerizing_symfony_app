FROM php:8.2-fpm-alpine AS php_upstream
FROM nginx:alpine as nginx_upstream

FROM php_upstream

# Install php extensions using docker-php-extension-installer from github.com/mlocati
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions
RUN install-php-extensions \
    intl \
    opcache \
    zip \
    pdo_mysql \

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

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

FROM nginx_upstream

# copy nginx config
COPY ./docker/nginx/nginx.conf /etc/nginx/conf.d/app.conf

# copy project
COPY --from=php_upstream /var/www/app /var/www/app
