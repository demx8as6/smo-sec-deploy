# NGINX container for production
FROM nginx:alpine
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY dist /usr/share/nginx/html
