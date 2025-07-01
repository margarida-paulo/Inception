FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

#Install needed dependencies
#Might be worth it to install procps for debugging purposes (seeing running processes)
RUN apt-get update &&\
    apt-get install -y mariadb-server procps &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

#Make the directory for the mariadb data
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

RUN mariadb_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

#Copy files from the host to the image
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

#EXPOSE is used for documentation, doesn't actually open the port.
EXPOSE 3306

ENTRYPOINT ["bash", "-c", "/entrypoint.sh"]