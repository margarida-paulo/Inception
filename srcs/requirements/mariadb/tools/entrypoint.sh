#!/bin/bash

#If a command fails, stop the entire script from running!
set -e

#Standard directory for mysql data
DB_DATA="/var/lib/mysql"

#Setting up the database
echo "MariaDB: Bootstrap..."

#The skip networking starts the MariaDB without opening network ports, so that the setup is safer
#& makes it run in the background
mysqld --user=mysql --skip-networking --datadir="$DB_DATA" &

#Stores the pid of the process we just put in the background
pid="$!"

#Waits for the mysql to be ready
until mysqladmin ping; do
    sleep 1
done

#Checks for a root password
ROOT_PASSWD_SET = $(mysql -u root -e "SELECT authentication_string FROM mysql.user WHERE user='root' AND host='localhost';" -s -N)

if [! -f "ROOT_PASSWD_SET"]; then
    echo "Setting up database"

    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    echo "Database initialized!"
else
    echo "Existing database detected, skipping initialization"
fi

echo "Shutting down bootstrap MariaDB"
mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
wait "$pid"

echo "Starting MariaDB in production mode"
exec mysqld
