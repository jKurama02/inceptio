FROM alpine:3.20.5

RUN apk update && apk upgrade && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-phar \
    php82-gd \
    php82-iconv \
    php82-pdo \
    php82-pdo_mysql \
    php82-session \
    php82-simplexml \
    php82-tokenizer \
    wget \
    curl \
    mariadb-client

RUN adduser -S nginx && addgroup -S nginx

# file di configurazione di PHP-FPM
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html/wordpress

# file di configurazione di WORDPRESS
COPY conf/wp-config.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wp-config.sh

ENTRYPOINT [ "/bin/sh" , "/usr/local/bin/wp-config.sh"]
