#!/bin/sh
echo "Starting configuring WordPress..."

sleep 10

# Check if WordPress is not already downloaded
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp core download --allow-root

    sleep 22

    echo "Create wp-config.php..."
    wp config create --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_USER --dbpass=$WORDPRESS_PASSWORD --dbhost=$WORDPRESS_DB_HOST --allow-root

    wp core install --url="https://anmedyns.42.fr" --title="t_anmedyns" --admin_user="u_anmedyns" --admin_password="'${ADMIN_PASSWORD}'" --admin_email="anmedyns@student.42roma.it" --allow-root

    # Create a second user (regular user)
    wp user create regularuser regularuser@student.42roma.it --role=author --user_pass="regularuserpass" --allow-root
fi

# Copy custom homepage if not exists
mkdir -p /var/www/html/wp-content/mu-plugins
if [ ! -f "/var/www/html/wp-content/mu-plugins/custom-homepage.php" ]; then
    cp /tmp/custom-homepage.php /var/www/html/wp-content/mu-plugins/custom-homepage.php
fi

sleep 10

php-fpm82 --nodaemonize


