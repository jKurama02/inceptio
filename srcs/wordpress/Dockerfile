FROM alpine:3.18

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
    mariadb-client \ 
    tini

RUN apk update && apk add --no-cache php82-cli

RUN adduser -S nginx && addgroup -S nginx
RUN ln -sf /usr/bin/php82 /usr/bin/php

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
RUN mkdir -p /run/php

COPY conf/wp-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp-config.sh


WORKDIR /var/www/html

# Copia personalizzazione homepage
COPY ./custom-homepage.php /tmp/custom-homepage.php

# Aggiungi un file di configurazione temporaneo per aumentare il limite di memoria PHP
RUN echo "memory_limit = 256M" > /etc/php82/conf.d/memory-limit.ini

# Crea directory mu-plugins e copia personalizzazione
RUN mkdir -p /var/www/html/wp-content/mu-plugins
COPY ../../custom-homepage.php /var/www/html/wp-content/mu-plugins/

ENTRYPOINT ["tini", "--", "/bin/sh" , "/usr/local/bin/wp-config.sh"]
