#!/usr/bin/env bash

echo "Begin executing start script";


# Retrieve host ip
if [ -z "$HOST_IP" ]; then
	# Allows to set HOST_IP by env variable because could be different from the one which come from ip route command
	HOST_IP=$(/sbin/ip route|awk '/default/ { print $3 }')
fi;


sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /etc/php/7.1/mods-available/xdebug.ini
sed -i "s/xdebug.remote_connect_back=.*/xdebug.remote_host=$HOST_IP/" /etc/php/7.1/mods-available/xdebug.ini
echo "xDebug /etc/php/7.1/fpm/php.ini changes. remote_host=$HOST_IP  and remote_autostart=1";


# Setup git variables
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi
echo "git global config: GIT_EMAIL: ${GIT_EMAIL} GIT_NAME: ${GIT_NAME}"

echo "End executing start script";
exec "php-fpm7.1"
