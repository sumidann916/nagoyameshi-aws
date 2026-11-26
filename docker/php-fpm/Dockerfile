# 本番用 PHP-FPM（Laravel）イメージ
# ビルド（リポジトリのルートで実行）:
#   docker build -f docker/php-fpm/Dockerfile -t nagoyameshi-app .
# ECS では nginx コンテナと同じタスクで動き、nginx から 127.0.0.1:9000 で呼ばれる

# ---------------------------------------------------------------- フロントのビルド（@vite 用の public/build）
FROM public.ecr.aws/docker/library/node:20-slim AS assets
WORKDIR /build
COPY laravel-nagoyameshi/package.json laravel-nagoyameshi/package-lock.json ./
RUN npm ci
COPY laravel-nagoyameshi/ ./
RUN npm run build

# ---------------------------------------------------------------- PHP-FPM
FROM public.ecr.aws/docker/library/php:8.2-fpm AS app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       unzip libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql zip bcmath gd exif opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=public.ecr.aws/docker/library/composer:2 /usr/bin/composer /usr/bin/composer

# PHP と PHP-FPM の設定
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY docker/php-fpm/php.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY docker/php-fpm/www.conf /usr/local/etc/php-fpm.d/zz-app.conf

WORKDIR /var/www/html

# 依存パッケージ（ソースより先にコピーしてキャッシュを効かせる）
COPY laravel-nagoyameshi/composer.json laravel-nagoyameshi/composer.lock ./
RUN composer install --no-dev --no-interaction --no-scripts --no-autoloader --prefer-dist

COPY laravel-nagoyameshi/ ./
COPY --from=assets /build/public/build ./public/build

# public/storage（ローカル用のリンク）は使わない。.env は ECS の環境変数で代替する
RUN rm -rf public/storage .env \
    && composer dump-autoload --no-dev --optimize \
    && php artisan view:cache \
    && chown -R www-data:www-data storage bootstrap/cache

COPY docker/php-fpm/entrypoint.sh /usr/local/bin/app-entrypoint
RUN sed -i 's/\r$//' /usr/local/bin/app-entrypoint && chmod +x /usr/local/bin/app-entrypoint

EXPOSE 9000
ENTRYPOINT ["app-entrypoint"]
CMD ["php-fpm"]
