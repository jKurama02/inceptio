#!/bin/bash

# Start the MariaDB service
service mariadb start

sleep 10

# Create the database if it doesn't exist
echo "Creating database if it doesn't exist..."
mariadb  -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

# Create the user if it doesn't exist
echo "Creating user if it doesn't exist..."
mariadb  -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# Grant all privileges to the user on the database
echo "Granting privileges..."
mariadb  -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;"

# Change the root user's password
echo "Changing root user's password..."
mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# Flush privileges to ensure changes take effect
echo "Flushing privileges..."
mariadb -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

# Shut down the mariadb service
echo "Shutting down MariaDB service..."
mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Wait for shutdown to complete
sleep 10

# Restart MariaDB in safe mode
exec mysqld_safe
