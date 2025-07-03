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
if ! wp core is-installed --allow-root ; then
    echo "Wordpress not installed - installing now..."
    wp core install \
        --url="$WP_WEBSITE" \
        --title="$DOMAIN_NAME" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create "$WP_USER2" "$WP_USER2_EMAIL" \
        --user_pass="$WP_USER2_PASS" \
        --role=author \
        --allow-root
    
    echo "Installing theme..."
    wp theme install "silverstorm" --activate --allow-root

else
    echo "Wordpress installation detected - skipped installation"
fi

echo "Changing ownership of files to ensure permissions..."
chown -R www-data:www-data /var/www/html

echo "Running website..."
#Runs the php-fpm, which listens to requests and sends the output
exec php-fpm7.4 -F
