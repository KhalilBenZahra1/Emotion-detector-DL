FROM nginx:alpine

# Creer le repertoire pour HTTPS
RUN mkdir -p /etc/nginx/ssl /var/www/.well-known/acme-challenge/

# Generer un certificat auto-signe
RUN apk add --no-cache openssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -subj "/CN=emotion-detection.duckdns.org" && \
    apk del openssl

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY templates/index.html /usr/share/nginx/html/index.html
COPY static /usr/share/nginx/html/static

EXPOSE 80 443