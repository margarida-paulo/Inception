FROM debian:bullseye

#Might be worth it to install procps for debugging purposes (seeing running processes)
RUN apt-get update \
    apt-get install -y mariadb-server \
    apt-get clean \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3306

