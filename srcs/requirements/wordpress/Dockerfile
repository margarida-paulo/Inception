FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

#Install needed dependencies
    #php-fpm -> Connects the webserver to the code (NGINX container to wordpress container)
    #php-mysql -> Allows interaction between php and the database
    RUN apt-get update &&\
    apt-get install -y php php-fpm php-mysql curl wget unzip default-mysql-client &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

#Copy script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

#Change PHP-FPM configuration file to listen in port 9000
RUN sed -i "s|^listen = .*|listen = 9000|" /etc/php/7.3/fpm/pool.d/www.conf

EXPOSE 9000

ENTRYPOINT ["bash", "-c", "/setup.sh"]