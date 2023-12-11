FROM php:8.2-apache

# Install packages from Aptitude
RUN apt-get update && apt-get install -y --no-install-recommends \
    ghostscript \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure libraries with Docker PHP extention package
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

# Install libraries with Docker PHP extention package
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    gd \
    intl \
    mysqli \
    zip

# Install packages from PECL
RUN pecl install imagick \
    && pecl install xdebug

# Enabled libraries with Docker PHP extention package
RUN docker-php-ext-enable xdebug \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable bcmath \
    && docker-php-ext-enable exif \
    && docker-php-ext-enable gd \
    && docker-php-ext-enable intl \
    && docker-php-ext-enable mysqli \
    && docker-php-ext-enable zip \
    && docker-php-ext-enable opcache

# change default Apache2 document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable Apache2 modules
RUN a2enmod rewrite expires

# Installing WP-CLI
RUN set -eux; \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
    chmod +x wp-cli.phar; \
    mv wp-cli.phar /usr/local/bin/wp

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Generate and enable SSL/TLS certificate
RUN set -eux; \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=FR/ST=France/L=Paris/O=Angie/OU=OctaveOctave Team Web/CN=devmaster.local"; \
	chmod 777 /etc/ssl/private; \
	chmod 777 /etc/ssl/private/ssl-cert-snakeoil.key; \
	a2enmod ssl; \
	a2ensite default-ssl

# Adding docker-entrypoint.sh script to generate wp-config.php file
COPY Docker/webserver/docker-wpconfig-entrypoint.sh /usr/local/bin/docker-wpconfig-entrypoint
RUN chmod 775 /usr/local/bin/docker-wpconfig-entrypoint

WORKDIR /var/www/html
VOLUME /var/www/html

RUN useradd -m devmaster

ENTRYPOINT ["docker-wpconfig-entrypoint"]
CMD ["apache2-foreground"]