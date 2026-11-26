# 本番用 nginx イメージ
# ビルド（リポジトリのルートで実行）:
#   docker build -f docker/nginx/Dockerfile -t nagoyameshi-nginx .
# CSS・JS・画像などの静的ファイルは nginx が直接返し、それ以外は PHP-FPM（127.0.0.1:9000）に渡す

# ---------------------------------------------------------------- フロントのビルド（@vite 用の public/build）
FROM public.ecr.aws/docker/library/node:20-slim AS assets
WORKDIR /build
COPY laravel-nagoyameshi/package.json laravel-nagoyameshi/package-lock.json ./
RUN npm ci
COPY laravel-nagoyameshi/ ./
RUN npm run build

# ---------------------------------------------------------------- nginx
FROM public.ecr.aws/docker/library/nginx:1.27-alpine

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# PHP-FPM コンテナと同じパスに public を置く（SCRIPT_FILENAME を揃えるため）
COPY laravel-nagoyameshi/public /var/www/html/public
COPY --from=assets /build/public/build /var/www/html/public/build

# public/storage は ECS の共有ボリューム（アップロード画像）のマウント先
RUN rm -rf /var/www/html/public/storage && mkdir -p /var/www/html/public/storage

EXPOSE 80
