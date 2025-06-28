FROM debian:bullseye

#Install needed dependencies
#Might be worth it to install procps for debugging purposes (seeing running processes)
RUN apt-get update &&\
    apt-get install -y mariadb-server procps &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

#Make the directory for the mariadb data
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

#EXPOSE is used for documentation, doesn't actually open the port.
#WHERE IS THE PORT OPEN THEN???
EXPOSE 3306

ENTRYPOINT ["bash", "-c", "/entrypoint.sh"]