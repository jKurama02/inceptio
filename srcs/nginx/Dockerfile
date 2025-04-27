FROM nginx:alpine

COPY setup_nginx.sh /setup_nginx.sh
COPY html/index.html /usr/share/nginx/html
COPY my_config/nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /setup_nginx.sh

ENTRYPOINT [ "sh", "setup_nginx.sh" ]

