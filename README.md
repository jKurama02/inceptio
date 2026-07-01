*This project has been created as part of the 42 curriculum by anmedyns.*

# Inception

## Description

Inception is a system administration project that sets up a small, self-contained web
infrastructure using Docker and Docker Compose. Three custom-built containers — **NGINX**,
**WordPress + php-fpm**, and **MariaDB** — run on a dedicated Docker network and communicate
with each other without exposing anything except the HTTPS entry point. WordPress data and
the database are stored in named Docker volumes so they persist across restarts.

## Instructions

Requirements: Docker, Docker Compose, and a `srcs/.env` file (see `DEV_DOC.md` for details).

```bash
make        # builds the images and starts every container
make down   # stops the containers
make clean  # stops containers and removes images
make fclean # clean + removes volumes
make re     # fclean + full rebuild
```

Once running, the site is reachable at `https://anmedyns.42.fr` (see `USER_DOC.md`).

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [WordPress Codex](https://wordpress.org/documentation/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)

**AI usage:** AI assistance (Claude) was used to review the project subject and
evaluation sheet against the repository, to draft/structure this README and the
`USER_DOC.md` / `DEV_DOC.md` files, and to double-check configuration choices
(volumes, networking, secrets handling) against the subject's requirements. All
Docker/Compose configuration and scripts were written and understood by the student.

## Project description: key design choices

| Comparison | Why this project uses one over the other |
|---|---|
| **Virtual Machines vs Docker** | Docker containers share the host kernel, so they start in seconds and use far less RAM/disk than full VMs, while still isolating each service (NGINX, WordPress, MariaDB) in its own filesystem and process space. |
| **Secrets vs Environment Variables** | Environment variables (via `srcs/.env`) are used to configure non-sensitive settings such as the domain name and service hostnames. Sensitive values (DB/admin passwords) are also environment-based here; Docker secrets would be the more secure alternative for production use, since secrets are mounted as files in-memory and never appear in `docker inspect` or image layers. |
| **Docker Network vs Host Network** | A dedicated user-defined `docker-network` is used instead of `network: host`. This keeps containers isolated from the host network stack, gives each service a resolvable DNS name (e.g. `mariadb`, `wordpress`), and only exposes port 443 through NGINX. |
| **Docker Volumes vs Bind Mounts** | Named volumes (`mariadb_data`, `wordpress_data`) are used instead of bind mounts. Docker manages their lifecycle and permissions, and their host path is fixed under `/home/anmedyns/data/`, which satisfies the persistence requirement without tying the setup to a specific host directory layout.