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

#Create the SSL certificate
#keyout -> Where to save the private key
#out -> Where to save the certificate (public key + info)
#subj -> Certificate details
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/selfsigned.key \
    -out /etc/nginx/ssl/selfsigned.crt \
    -subj "/C=PT/ST=Lisbon/L=Lisbon/O=42/OU=Inception/CN=margarida"

#Copy the nginx conf file from host to image, in the standard folder where nginx looks for conf files
COPY conf/nginx.conf /etc/nginx/conf.d/nginx.conf

EXPOSE 443

# Start nginx in the foreground so that the container keeps running
#CMD can be overridden if developers want to
CMD ["nginx", "-g", "daemon off;"]