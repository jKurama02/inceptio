FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt-get install -y mariadb-server \
	curl

RUN apt-get install systemd -y

COPY my_config/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY setup_mariadb.sh /usr/local/bin/mariadbscript.sh

RUN chmod +x /usr/local/bin/mariadbscript.sh

EXPOSE 3306

CMD ["/usr/local/bin/mariadbscript.sh"]
