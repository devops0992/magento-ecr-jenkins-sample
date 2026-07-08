# Custom Magento/PHP-FPM image
# In a real Magento project, add required PHP extensions here.
FROM php:8.2-fpm-alpine

RUN docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www/html

COPY public/ ./public/
COPY app/ ./app/

RUN addgroup -g 1000 magento \
    && adduser -D -G magento -u 1000 magento \
    && chown -R magento:magento /var/www/html

USER magento

EXPOSE 9000
