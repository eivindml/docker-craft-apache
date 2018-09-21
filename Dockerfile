# Build deps
FROM composer:latest as vendor

COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock

FROM php:7.1-apache

RUN apt-get update \
	&& apt-get install -yq apt-utils unzip libmcrypt-dev libmagickwand-dev --no-install-recommends  \
	&& docker-php-ext-install zip pdo_mysql mcrypt gd \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& rm -r /var/lib/apt/lists/*

# Enable .htaccess
RUN a2enmod rewrite

COPY --from=vendor /app/vendor /var/www/vendor

# Copy over Craft files
COPY config/ /var/www/config
COPY modules/ /var/www/modules
COPY storage/ /var/www/storage
COPY templates/ /var/www/templates
COPY storage/ /var/www/storage
COPY web/ /var/www/html

COPY .env /var/www/.env
COPY composer.json /var/www/composer.json
COPY composer.lock /var/www/composer.lock

# Set permissions
RUN chmod 777 -R /var/www/config
RUN chmod 777 -R /var/www/vendor
RUN chmod 777 -R /var/www/storage
RUN chmod 777 -R /var/www/html/cpresources

RUN chmod 777 /var/www/.env
RUN chmod 777 /var/www/composer.json
RUN chmod 777 /var/www/composer.lock

# Expose default port
EXPOSE 80
