#!/bin/bash

# Script stops if command fails
set -e

DATA="/var/lib/mysql" # Where data will be stored
DB_INITIALIZED="$DATA/.db_initialized" # Flag file, if exists, mariaDB is setup already

if [ ! -f "$DB_INITIALIZED" ]; then

    echo "MariaDB: Bootstrapping..."

    #   Start mysql daemon in background without network connection (safer for setup)
    mysqld --user=mysql --skip-networking --datadir="$DATA" &
    initialization_pid="$!"

    # Wait for the server to be ready
    until mysqladmin ping --silent; do
        sleep 1
    done

    echo "Setting up database"

    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    touch "$DB_INITIALIZED"
    echo "Database correctly initialized."
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    
    #Wait for the process to fully finish to avoid a race condition
    wait "$initialization_pid"
else
    echo "Database was already setup, proceed without initializing."
fi

echo "MariaDB: Production mode"

#Execute mysqld in the foreground
#bind-address -> Makes sure mariadb listens on all available network interfaces
#character-set and collation-server -> Set recommended character enconding for modern WordPress
exec mysqld \
    --bind-address=0.0.0.0 \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_general_ci 