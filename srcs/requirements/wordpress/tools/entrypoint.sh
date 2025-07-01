#!/bin/bash

#Script stops if command fails
set -e

#Wait for the mariadb container to be fully working
echo "Wait for mariadb..."
until mysqladmin ping -h"$DB_HOSTNAME" -P"$DB_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    sleep 1
done

#File used by php-fpm to store temporary files, locks or secondary sockets
mkdir -p "/run/php"

#Go to root directory of website
cd /var/www/html

#Download WordPress if not present
if [ ! -f wp-load.php ]; then
    echo "WordPress not found — downloading it now..."
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    cp -r wordpress/* . && \
    rm -rf latest.tar.gz wordpress
fi

#Create wp-config.php if not present
if [ ! -f wp-config.php ]; then
    echo "Generating wp-config.php..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$DB_HOSTNAME:$DB_PORT" \
        --allow-root
fi

#Install wordpress if not installed
#Skip the notification email
if [ ! wp core is-installed --allow-root ]; then
    echo "Wordpress not installed - installing now..."
    wp core install \
        --url="$WEBSITE_WP" \
        --title="$DOMAIN_NAME" \
        --admin_user="$ADMIN_WP" \
        --admin_password="$ADMIN_PS" \
        --admin_email="$ADMIN_EMAIL" \
        --skip-email \
        --allow-root