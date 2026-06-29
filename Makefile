NAME = inception

all: mkdir build up

build:
	@echo "Building Docker images..."
	docker compose -f srcs/docker-compose.yml build

mkdir:
	mkdir -p /home/anmedyns/data/mariadb /home/anmedyns/data/wordpress
up:
	@echo "Starting containers..."
	docker compose -f srcs/docker-compose.yml up -d

down:
	@echo "Stopping containers..."
	docker compose -f srcs/docker-compose.yml down

clean: down
	@echo "Removing containers and images..."
	docker system prune -af

fclean: clean
	@echo "Removing volumes..."
	docker volume prune -fa

re: fclean all



# DOMAIN_NAME=anmedyns.42.fr

# WORDPRESS_DB_HOST=mariadb
# WORDPRESS_DB_NAME=wordpress
# WORDPRESS_USER=wpuser
# WORDPRESS_PASSWORD=wppassword

# MYSQL_ROOT_PASSWORD=rootpassword
# MYSQL_DATABASE=wordpress
# MYSQL_USER=wpuser
# MYSQL_PASSWORD=wppassword

# ADMIN_PASSWORD=the_adminpassword