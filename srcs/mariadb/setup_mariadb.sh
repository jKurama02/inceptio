#!/bin/sh

echo "_+_+_+_+📊 Starting MariaDB setup..._+_+_+_+"

chown -R mysql:mysql /var/log/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "###Initializing database..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	mysql --user=mysql &
	pid=$!

	echo "###Waiting for database to be ready..."
	sleep 15;

	mysql -u root << EOF
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
	CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
	CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED  BY '${MYSQL_PASSWORD}';
	GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
	FLUSH PRIVILEGES;
EOF

	sleep 15;
	
	kill $pid
	wait $pid
fi
exec mysqld --user=mysql
