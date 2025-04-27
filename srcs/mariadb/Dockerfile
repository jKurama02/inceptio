FROM alpine:3.20.5

RUN apk update && apk upgrade && apk add --no-cache \
 mariadb \
 mariadb-client

# Crea directory con i permessi corretti
RUN mkdir -p /var/log/mysql /var/lib/mysql /run/mysqld && \
 chown -R mysql:mysql /var/log/mysql /var/lib/mysql /run/mysqld

# Variabili d'ambiente per configurare MariaDB
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=wordpress
ENV MYSQL_USER=wpuser
ENV MYSQL_PASSWORD=wppassword

COPY my_config/mariadb.conf /etc/mysql/conf.d/mariadb.conf
COPY setup_mariadb.sh /tmp/setup_mariadb.sh

RUN chmod +x /tmp/setup_mariadb.sh

# Esponi la porta 3306
EXPOSE 3306

# Imposta il volume per i dati persistenti
VOLUME ["/var/lib/mysql"]

# Esegui lo script di setup all'avvio
ENTRYPOINT ["/bin/sh", "/tmp/setup_mariadb.sh"]
