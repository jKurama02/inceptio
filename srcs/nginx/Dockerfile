FROM nginx:alpine

COPY html/index.html /usr/share/nginx/html
COPY my_config/nginx.conf /etc/nginx/nginx.conf

# Install openssl
RUN apk add --no-cache openssl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 \
-nodes \
-out /etc/nginx/ssl/inception.crt \
-keyout /etc/nginx/ssl/inception.key \
-subj "/C=IT/ST=Rome/L=Rome/O=42 School/OU=anmedyns/CN=anmedyns.42.fr/"


CMD ["nginx", "-g", "daemon off;"]
