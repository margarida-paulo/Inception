#!/bin/bash
set -e

DB_DATA_DIR="/var/lib/mysql"
DB_INIT_MARKER="$DB_DATA_DIR/.db_initialized"

echo "⏳ Starting MariaDB bootstrap..."

# Start mysqld in background for setup
mysqld --user=mysql --skip-networking --datadir="$DB_DATA_DIR" &
pid="$!"

# Wait for server to be ready
until mysqladmin ping --silent; do
    sleep 1
done

if [ ! -f "$DB_INIT_MARKER" ]; then
    echo "✅ First-time DB setup..."

    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    touch "$DB_INIT_MARKER"
    echo "📌 Database initialized."
else
    echo "📁 Existing database detected. Skipping initialization."
fi

# Shutdown the bootstrap process
mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
wait "$pid"

echo "🚀 Starting MariaDB in production mode..."
exec mysqld