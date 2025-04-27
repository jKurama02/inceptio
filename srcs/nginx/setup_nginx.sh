#!/bin/sh

echo "Starting 🔧 Nginx with a different port ..."
# Install Nginx

echo "Conf Nginx:"
cat /etc/nginx/nginx.conf

nginx -g 'daemon off;'
# -g 'daemon off;' is used to run nginx in the foreground, which is necessary for Docker containers.
