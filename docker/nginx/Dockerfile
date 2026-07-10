# Custom Nginx image for Magento reverse proxy
FROM nginx:1.25-alpine

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY public/ /var/www/html/public/

EXPOSE 81
