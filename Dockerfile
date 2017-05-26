FROM ubuntu:16.04

MAINTAINER Vitalii Sydorenko <vetal.sydo@gmail.com>

RUN apt-get clean && apt-get -y update && apt-get install -y locales curl software-properties-common git unzip gzip nano tree \
  && locale-gen en_US.UTF-8 
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y --force-yes php7.1-fpm php7.1-bcmath php7.1-bz2 php7.1-common php7.1-curl \
                php7.1-fpm php7.1-gd php7.1-gmp php7.1-imap php7.1-intl \
                php7.1-json php7.1-ldap php7.1-mbstring php7.1-mcrypt php7.1-mysql php7.1-pdo php7.1-pdo-mysql \
                php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-phpdbg php7.1-pspell \
                php7.1-readline php7.1-recode php7.1-soap php7.1-sqlite3 \
                php7.1-tidy php7.1-xml php7.1-xmlrpc php7.1-xsl php7.1-zip \
                php-tideways php-mongodb php-redis php7.1-xdebug

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 10M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/post_max_size = .*/post_max_size = 12M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini

RUN sed -i -e "s/pid =.*/pid = \/var\/run\/php7.1-fpm.pid/" /etc/php/7.1/fpm/php-fpm.conf
RUN sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/7.1/fpm/php-fpm.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.1/fpm/php-fpm.conf
RUN sed -i "s/listen = .*/listen = 9000/" /etc/php/7.1/fpm/pool.d/www.conf
RUN sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/7.1/fpm/pool.d/www.conf

# xDebug configuration
RUN phpdismod xdebug
RUN echo "xdebug.remote_enable=1" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.remote_autostart=0" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.idekey = \"PHPSTORM\"" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.var_display_max_data=2048" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.var_display_max_depth=128" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "xdebug.max_nesting_level = 500" >> /etc/php/7.1/mods-available/xdebug.ini
RUN echo "export PHP_IDE_CONFIG=\"serverName=server\"" >> ~/.bashrc


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version


RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV WORKDIR /var/www/default
WORKDIR $WORKDIR


EXPOSE 9000
ADD ./start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
CMD ["start.sh"]
