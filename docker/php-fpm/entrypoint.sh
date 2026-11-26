#!/bin/sh
set -e

# ECS タスク内で nginx と共有するボリューム（storage/app/public）を PHP-FPM（www-data）が書き込めるようにする
mkdir -p /var/www/html/storage/app/public
chown www-data:www-data /var/www/html/storage/app/public

# 既定は php-fpm。マイグレーション用タスクでは php artisan migrate --force などに置き換わる
exec "$@"
