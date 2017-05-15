FROM php:7.1.4-fpm

MAINTAINER Vitalii Sydorenko <vetal.sydo@gmail.com>

# Install programs
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    gzip \
    nano \
    curl \
    tree

## Install apt-utils
ARG DEBIAN_FRONTEND=noninteractive
#RUN apt-get update \
#    && apt-get install -y --no-install-recommends apt-utils

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Set timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN "date"


# Install GD
RUN apt-get update \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng12-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# Install MCrypt
RUN apt-get update \
    && apt-get install -y libmcrypt-dev \
    && docker-php-ext-install mcrypt

# Install Intl
#RUN apt-get update \
#    && apt-get install -y libicu-dev \
#    && docker-php-ext-install intl

RUN curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/58.2/icu4c-58_2-src.tgz \
    && tar -zxf /tmp/icu.tar.gz -C /tmp \
    && cd /tmp/icu/source \
    && ./configure --prefix=/usr/local \
    && make \
    && make install
RUN docker-php-ext-configure intl --with-icu-dir=/usr/local \
    && docker-php-ext-install intl

# Install Mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install soap
RUN apt-get update \
    && apt-get install -y libxml2-dev \
    && docker-php-ext-install soap

# Install opcache
RUN docker-php-ext-install opcache

# Install PHP zip extension
RUN docker-php-ext-install zip

# Install xdebug
ENV XDEBUG_ENABLE 0
RUN pecl install xdebug \
    && rm -rf /tmp/pear
COPY ./xdebug.ini.disabled /usr/local/etc/php/conf.d/

# Install exif
RUN docker-php-ext-install exif

# Copy my own php.ini
COPY ./php.ini /usr/local/etc/php/

# Define PHP_TIMEZONE env variable
ENV PHP_TIMEZONE Europe/Kiev

# Define PHP_TIMEZONE env variable
ENV MEMORY_LIMIT 512M

ENV IS_SYMFONY_2 = 0
ENV IS_SYMFONY_3 = 0


RUN echo 'alias ll="ls -l"' >> ~/.bashrc

WORKDIR /var/www/default

# Start!
COPY ./start /usr/local/bin/
RUN chmod +x /usr/local/bin/start
CMD ["start"]
