#!/bin/sh
echo "Starting configuring WordPress..."

sleep 10

wp core download --allow-root

sleep 22

echo "Create wp-config.php..."
wp config create --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_USER --dbpass=$WORDPRESS_PASSWORD --dbhost=$WORDPRESS_DB_HOST --allow-root

wp core install --url="http://localhost" --title="anmedyns" --admin_user="admin" --admin_password="adminpassword" --admin_email="anmedyns@student.42roma.it" --allow-root
sleep 10

php-fpm82 --nodaemonize
echo "Finish wp-config.php..."


