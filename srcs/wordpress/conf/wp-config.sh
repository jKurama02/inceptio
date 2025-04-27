#!/bin/sh
echo "Starting configuring WordPress..."

wp core download --all-root

echo "Create wp-config.php..."
wp config create --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_USER --dbpass=$WORDPRESS_PASSWORD --dbhost=$WORDPRESS_DB_HOST --allow-root

wp core install --url="http://localhost" --title="anmedyns" --admin_user="admin" --admin_password="adminpassword" --admin_email="anmedyns@student.42roma.it" --allow-root

php-fpm82 --nodaemonize

