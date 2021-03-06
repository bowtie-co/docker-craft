# FROM php:7.3-fpm
FROM bowtie/php:7.3-fpm-nginx

# ENV APP_DIR /var/www/app
# ENV APP_USER www-data

# ENV NGINX_PATH=/etc/nginx

# RUN mkdir -p $APP_DIR

# # Set working directory
# WORKDIR $APP_DIR

# Install apt requirements & dependencies
# RUN apt-get update && apt-get install -y \
#     build-essential default-mysql-client libpng-dev libjpeg62-turbo-dev libfreetype6-dev libmagickwand-dev libzip-dev \
#     locales zip jpegoptim optipng pngquant gifsicle vim xvfb unzip git curl cron nginx supervisor \
#     #
#     # Install imagick using pecl
#     && pecl install imagick-3.4.3 \
#     #
#     # Install composer
#     && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
#     #
#     # Clear apt cache
#     && apt-get clean && rm -rf /var/lib/apt/lists/*


# # # Install extensions
# RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath bz2 ftp gettext opcache shmop sockets sysvmsg sysvsem sysvshm iconv intl \
#     && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
#     && docker-php-ext-install gd \
#     && docker-php-ext-enable imagick

COPY composer.lock composer.json ./
RUN composer install

# COPY etc/nginx $NGINX_PATH
# COPY etc/php/* /usr/local/etc/php/
# COPY etc/php-fpm.d/* /usr/local/etc/php-fpm.d/
# COPY etc/supervisord/* /etc/supervisor/conf.d/

# # Remove default nginx sites-enabled
# RUN rm $NGINX_PATH/sites-enabled/* \
#     && ln -s $NGINX_PATH/sites-available/craft.conf $NGINX_PATH/sites-enabled/craft.conf \
#     && nginx -t

# Copy existing application directory contents
COPY . .

# Expose port 80 and start php-fpm server
EXPOSE 80

ENTRYPOINT [ "scripts/docker-entrypoint.sh" ]

# CMD ["php-fpm"]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf" ]
