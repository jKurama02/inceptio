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
