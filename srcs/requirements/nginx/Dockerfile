#Nginx container, accessbile from outside of Docker via port 443

#Debian is more popular than Alpine, therefore there are more
# resources available to learn from
FROM debian:bullseye

#Update the apt command
RUN apt update

#apt-get -> More used in scripts, more predictable behaviour
# -y option -> Answer yes to the confirmation prompt automatically
RUN apt-get install -y openssl nginx &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*


#TO BE CONTINUED