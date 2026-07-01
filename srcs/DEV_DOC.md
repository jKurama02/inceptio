# Developer Documentation

## Prerequisites

- A Linux virtual machine (as required by the subject).
- Docker Engine and the Docker Compose plugin installed.
- `make`.

## Setting up the environment from scratch

1. Clone the repository.
2. Create `srcs/.env` at the root of `srcs/` (this file is git-ignored and must
   never be committed). Example content:

   ```env
   DOMAIN_NAME=anmedyns.42.fr

   MYSQL_DATABASE=wordpress
   MYSQL_USER=wpuser
   MYSQL_PASSWORD=<choose_a_password>
   MYSQL_ROOT_PASSWORD=<choose_a_password>

   WORDPRESS_DB_HOST=mariadb
   WORDPRESS_DB_NAME=wordpress
   WORDPRESS_USER=wpuser
   WORDPRESS_PASSWORD=<choose_a_password>

   ADMIN_USER=<admin_username_without_"admin"_in_it>
   ADMIN_PASSWORD=<choose_a_password>
   ```

3. Make sure `login.42.fr` (here `anmedyns.42.fr`) resolves to your VM's local IP,
   e.g. by adding an entry to `/etc/hosts`.

## Building and launching the project

```bash
make        # runs mkdir + build + up
make build  # only builds the images via docker compose
make up     # only starts the containers (detached)
```

The Makefile drives everything through `docker compose -f srcs/docker-compose.yml`,
which in turn builds each service from its own `Dockerfile` under
`srcs/requirements/<service>/`.

## Managing containers and volumes

```bash
docker compose -f srcs/docker-compose.yml ps       # container status
docker compose -f srcs/docker-compose.yml logs -f  # follow logs
make down                                          # stop containers
make clean                                         # stop + remove containers/images
make fclean                                        # clean + remove volumes
make re                                             # fclean + rebuild everything
docker network ls                                  # inspect the docker-network
docker volume ls                                   # list named volumes
```

## Data storage and persistence

- `mariadb_data` (named volume) → mounted at `/var/lib/mysql` inside the MariaDB
  container, backed by `/home/anmedyns/data/mariadb` on the host.
- `wordpress_data` (named volume) → mounted at `/var/www/html` inside the
  WordPress (and NGINX) container, backed by `/home/anmedyns/data/wordpress` on
  the host.

Both directories are created automatically by `make mkdir` (part of `make all`)
before the containers start. Because these are named volumes rather than bind
mounts, data survives `make down` / `make up` and a full VM reboot, as long as
the volumes themselves are not removed (`make fclean` does remove them).