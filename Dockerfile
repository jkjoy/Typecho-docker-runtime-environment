# 使用 PHP-FPM 的 Alpine 镜像
FROM php:8.3-fpm-alpine

# 设置工作目录
WORKDIR /app

RUN apk add --no-cache \
    lighttpd \
    autoconf \
    pkgconf \
    make \
    gcc \
    libc-dev \
    zlib-dev \
    libpng-dev \
    icu-dev \
    libzip-dev \
    freetype-dev \ 
    && docker-php-ext-install pdo_mysql mysqli gd intl opcache zip \
    && pecl install redis && docker-php-ext-enable redis \
    && apk del autoconf pkgconf make gcc libc-dev \
    && rm -rf /var/cache/apk/* \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' /usr/local/etc/php/php.ini \
    && sed -i 's/post_max_size = .*/post_max_size = 100M/' /usr/local/etc/php/php.ini

# 配置 Lighttpd
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf

# 复制应用文件
COPY index.php /app/index.php

# 设置权限
RUN chown -R www-data:www-data /app

# 暴露端口
EXPOSE 80

# 启动 Lighttpd 和 PHP-FPM
CMD ["sh", "-c", "php-fpm & lighttpd -D -f /etc/lighttpd/lighttpd.conf"]
