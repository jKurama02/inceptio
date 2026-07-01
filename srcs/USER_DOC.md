# User Documentation

## What this stack provides

- **NGINX** — the only entry point to the infrastructure, reachable over HTTPS (port 443, TLSv1.2/1.3 only).
- **WordPress + php-fpm** — the website and its administration panel.
- **MariaDB** — the database that stores all WordPress content (posts, users, settings).

## Starting and stopping the project

From the repository root:

```bash
make        # build the images (if needed) and start all containers
make down   # stop all containers
```

## Accessing the website and the admin panel

- Website: `https://anmedyns.42.fr`
- Admin dashboard: `https://anmedyns.42.fr/wp-admin`

Note: the site is only accessible over HTTPS. A self-signed certificate warning in
the browser is expected and can be accepted manually.

## Credentials

Login credentials (database and WordPress users) are defined as environment
variables in `srcs/.env`, which is **not** committed to git. Ask whoever set up
the project for a copy of this file, or generate a new one following `DEV_DOC.md`.

- WordPress administrator: username defined by `ADMIN_USER` in `.env` (must not
  contain "admin"/"administrator").
- WordPress regular user: username defined by `WORDPRESS_USER` in `.env`.
- Database root/user passwords: `MYSQL_ROOT_PASSWORD` / `MYSQL_PASSWORD` in `.env`.

**Never commit `.env` or real passwords to the git repository.**

## Checking that services are running correctly

```bash
docker compose -f srcs/docker-compose.yml ps   # container status
docker ps                                      # all running containers
docker logs nginx
docker logs wordpress
docker logs mariadb
```

All three containers should show as `running`/`healthy`. If one keeps restarting,
check its logs for the cause before reporting an issue.