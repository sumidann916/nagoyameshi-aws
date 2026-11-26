# Laravel Nagoyameshi アプリケーション

このリポジトリは、Terraformで構築されたAWSインフラ（ECS Fargate, ALB, RDS など）にデプロイされる Laravel アプリケーションです。

---

## 🚀 デプロイ方法（Terraform連携）

このプロジェクトは、Terraform構成で作成される CodePipeline により、自動的にデプロイすることを想定しています。

| ディレクトリ・ファイル | 内容 |
|---|---|
| `laravel-nagoyameshi/` | Laravel アプリケーション |
| `docker/` | 本番用の nginx・PHP-FPM イメージ |
| `buildspec.yml` | CodeBuild（イメージのビルド・ECR への push・マイグレーション） |
| `terraform/` | AWS 構成（手順は [terraform/README.md](terraform/README.md)） |

---

### ✅ 必須手順（Terraform側）

`terraform/envs/prod` と `terraform/envs/stg` の `terraform.tfvars.example` を `terraform.tfvars` にコピーし、値を入れてください（`terraform.tfvars` は Git に含めません）。
このリポジトリの情報は記入済みです：

```hcl
github_owner  = "sumidann916"
github_repo   = "nagoyameshi-aws"
github_branch = "main" # 検証（stg）は develop（未定・確認事項）
```

GitHub との接続はトークンではなく AWS CodeConnections を使います。
`terraform apply` 後に AWS コンソールで接続を「利用可能」にする手順も含め、[terraform/README.md](terraform/README.md) を参照してください。

---

## 🐳 ローカル環境での動作確認

ローカルでの動作確認は以下の手順で行います。

### 1. .env ファイルの作成

```bash
cp laravel-nagoyameshi/.env.example laravel-nagoyameshi/.env
```

APP_KEY、DB接続情報は `.env.example` にあらかじめ記述されています。

```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel_nagoyameshi
DB_USERNAME=laravel
DB_PASSWORD=password
```

### 2. コンテナの起動

```bash
docker compose up --build
```

### 3. マイグレーションの実行

```bash
docker compose exec laravel php artisan migrate
```

### 4. ストレージのシンボリックリンク作成

画像を表示するために、初回のみ以下を実行してください：

```bash
docker compose exec laravel php artisan storage:link
```

> ⚠️ `storage:link` はローカル環境での初回セットアップ時のみ必要です。
> 本番環境（ECS Fargate）では Dockerfile.deployment のビルド時に自動実行されます。

---

## 🚀 AWS本番デプロイ用のビルドについて

AWS ECS Fargate への本番デプロイでは、以下のDockerfileを使用します：

```
Dockerfile.deployment
```

この `Dockerfile.deployment` を CodeBuild で使用し、
ECR イメージのビルド → ECS による Laravel アプリの本番環境起動が行われるように設定してください。

### マイグレーションの自動実行について

本番環境では、`buildspec.yml` の設定により、CodePipeline の Build ステージ（CodeBuild）において、
ECR へのイメージ push 後に ECS RunTask によりマイグレーションが自動実行されます。

```
GitHub push
  → CodePipeline
    → CodeBuild: Dockerイメージビルド → ECR push → migration自動実行
    → ECS Fargate: 新しいイメージでサービス更新
```

手動でのマイグレーション実行は不要です。

---

## 📦 プロジェクト構成

- Laravel 10.x
- MySQL（Amazon RDS）
- SSM Parameter Store による環境変数管理（本番環境では `.env` 不要）
- デプロイは GitHub → CodePipeline → CodeBuild → ECR → ECS の流れ

---

## 📝 注意事項

- 本番環境では `.env` は使用せず、SSM Parameter Store によって環境変数を注入してください
- ブランチ名は `terraform.tfvars` で指定した `github_branch` に合わせてください
- `push → CodePipeline → デプロイ` の自動化を前提としています