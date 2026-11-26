# nagoyameshi-terraform

NAGOYAMESHI（Laravel）を AWS で動かすための Terraform です。
設計書「NAGOYAMESHI_AWSインフラ構成設計書_v0.2.pptx」の構成をコードにしています。

- 東京リージョン（ap-northeast-1）
- 本番（`example.com`）と検証（`stg.example.com`）の 2環境
- VPC・NAT Gateway・ALB は 2環境で共有
- ECS Fargate のタスクは nginx と PHP-FPM の 2コンテナ構成
- デプロイは ECS 標準のブルーグリーン方式。本番では Auto Scaling で 2〜4 タスクに増減
- RDS for MySQL 8.4。本番は Multi-AZ、検証は Single-AZ。自動バックアップは 7日
- タスクにはパブリック IP を付けない。外部への通信は NAT Gateway を経由
- 検証サイトには、許可した IP からしかアクセスできない（ALB のリスナールールで制限）
- CloudWatch アラームの通知は SNS からメールで届く
- State は S3 に保存し、`use_lockfile` でロックする（DynamoDB は使わない）

## ディレクトリ構成

ファイルはリソースごとに分けています。どのディレクトリも `provider.tf`（Terraform とプロバイダーの設定）、`variables.tf`（入力）、`outputs.tf`（出力）を共通で持ちます。

```
bootstrap/              State 用 S3 バケット（最初に 1回だけ実行。この State 自体はローカル）
  s3.tf                   State 用バケット・暗号化・バージョニング・HTTPS 以外を拒否
modules/
  network/              VPC・サブネット 6つ・IGW・NAT・ルートテーブル・S3 Gateway エンドポイント
    vpc.tf                VPC・Internet Gateway
    subnet.tf             public / private-app / private-db × 2AZ
    nat_gateway.tf        Elastic IP・NAT Gateway（1a に 1つ）
    route_table.tf        ルートテーブルと関連付け
    vpc_endpoint.tf       S3 Gateway エンドポイント
  alb/                  本番・検証で共有する ALB
    alb.tf                ALB・リスナー（80→443 リダイレクト、443 の既定は 404）
    security_group.tf     ALB の SG
  ecs_service/          環境ごとの ECS サービス
    target_group.tf       ターゲットグループ（blue / green）
    listener_rule.tf      ALB のリスナールール（検証は送信元 IP で制限）
    iam.tf                タスク実行ロール・タスクロール・インフラロール
    task_definition.tf    タスク定義（アプリ用・マイグレーション用）
    service.tf            ECS サービス（ブルーグリーン）
    autoscaling.tf        Auto Scaling（CPU のターゲット追跡）
    cloudwatch_logs.tf    ロググループ
    locals.tf             コンテナ定義の共通部分
  rds/                  環境ごとの RDS
    rds.tf                サブネットグループ・パラメータグループ・パスワード・DB インスタンス
    security_group.tf     RDS の SG
  monitoring/           CloudWatch アラーム（通知は SNS）
    alarm_app_log.tf      ログの ERROR 検知
    alarm_alb.tf          5xx・異常ターゲット
    alarm_ecs.tf          ECS の CPU・メモリ
    alarm_rds.tf          RDS の CPU・空き容量
  cicd/                 CI/CD
    codebuild.tf          CodeBuild とそのロール・ロググループ
    codepipeline.tf       CodePipeline（V2）とそのロール
envs/
  shared/               本番・検証で共有するリソース
    network.tf / alb.tf   上のモジュールの呼び出し
    acm.tf / route53.tf   証明書と DNS 検証レコード
    ecs.tf / ecr.tf       ECS クラスター・ECR リポジトリ
    sns.tf / budgets.tf   アラーム通知・請求アラート
    s3_images.tf / cloudfront.tf          画像用 S3 と CloudFront
    s3_artifacts.tf / codeconnections.tf  パイプライン用 S3・GitHub 接続
    random.tf             バケット名の接尾辞
  prod/                 本番
    main.tf               shared の State の参照・共通の値（locals）
    security_group.tf     ECS タスクの SG
    rds.tf / ecs.tf / monitoring.tf / cicd.tf   モジュールの呼び出し
    ssm.tf                Terraform が登録する SSM パラメータ
    route53.tf            サイトの A レコード
    backend.tf            State の保存先（key だけ環境ごとに違う）
  stg/                  検証（backend.tf 以外は prod と同じ内容。違うのは backend.tf と tfvars だけ）
```

## 命名規則

| 対象 | 規則 | 例 |
|---|---|---|
| AWS リソース名（共有） | `<プロジェクト>-<役割>` | `nagoyameshi-alb`、`nagoyameshi-alarm` |
| AWS リソース名（環境ごと） | `<プロジェクト>-<環境>-<役割>` | `nagoyameshi-prod-ecs`、`nagoyameshi-stg-rds` |
| 環境の識別子 | 本番 `prod`、検証 `stg`、共有 `shared` | |
| S3 バケット | `<プロジェクト>-<用途>-<ランダムな 8文字>`（世界で一意にするため） | `nagoyameshi-images-1a2b3c4d` |
| SSM パラメータ | `/<プロジェクト>/<環境>/<Laravel の変数名>` | `/nagoyameshi/prod/DB_PASSWORD` |
| ロググループ | `/ecs/<プロジェクト>-<環境>/<コンテナ>`、`/codebuild/<プロジェクト>-<環境>` | `/ecs/nagoyameshi-prod/app` |
| Terraform のリソース名 | 1つだけなら `this`、複数なら役割（`public`・`app`・`db` など） | `aws_vpc.this`、`aws_subnet.app` |
| Terraform のファイル名 | 作るリソースの種類ごと（上のディレクトリ構成を参照） | `security_group.tf` |
| タグ | すべてのリソースに `Project`・`Environment`・`ManagedBy` を `default_tags` で付ける | `Environment = prod` |

名前の接頭辞は `variables.tf` の `project`（初期値 `nagoyameshi`）と `env` から作るため、値を変えるだけで別の名前の環境を作れます。

## 秘密情報の扱い

- パスワードやキーは `.tf` と `terraform.tfvars` に書きません。
- RDS のパスワードは Terraform が生成し、SSM Parameter Store に SecureString で保存します（コンテナには ECS が SSM から渡す）。
- 外部サービスのキー（`APP_KEY`・Stripe・SES の SMTP 認証情報）は、手作業で SSM に登録します（下の手順 3）。
- `terraform.tfvars` と State ファイルは `.gitignore` で Git に含めません。State にはパスワードが残るため、State 用バケットは作業者だけが読めるようにします。

State は環境ごとに次のキーで保存します。

- `shared/terraform.tfstate`
- `prod/terraform.tfstate`
- `stg/terraform.tfstate`

## 事前に必要なもの

| 項目 | 内容 |
|---|---|
| ツール | Terraform 1.10 以上、AWS CLI、Docker |
| 作業用 IAM ユーザー | 管理者権限と MFA を設定する。ルートユーザーは使わない |
| ドメイン | Route 53 にホストゾーンがあること。Route 53 でドメインを取得すると自動で作られる |
| SES | 送信元アドレス（またはドメイン）の検証を済ませる。本番で使うにはサンドボックス解除の申請が必要 |
| アプリ側のファイル | 下の「アプリ側のファイル」を参照（nginx・PHP-FPM の Dockerfile と buildspec.yml） |

## 構築手順

### 1. State 用バケットを作る（1回だけ）

```bash
cd bootstrap
terraform init
terraform apply
# 出力された tfstate_bucket の値を控える（例: nagoyameshi-tfstate-1a2b3c4d）
```

### 2. 共有リソースを作る

```bash
cd ../envs/shared
cp terraform.tfvars.example terraform.tfvars   # domain_name・alarm_email を入力
terraform init -backend-config="bucket=<tfstate_bucket>"
terraform plan
terraform apply
```

apply の後に、手作業が 2つあります。

- **GitHub との接続を承認する**: AWS コンソールの「デベロッパー用ツール → 設定 → 接続」を開きます。`nagoyameshi-github` が「保留中」になっているので、「保留中の接続を更新」から GitHub と連携します。
- **SNS の購読を確認する**: `alarm_email` に届く確認メールのリンクを押します。

### 3. 秘密情報を SSM に登録する（環境ごと）

Terraform で値を扱わないパラメータは、手作業で SecureString として登録します。
`DB_*`・`AWS_BUCKET`・`AWS_URL`・`APP_URL` は Terraform が自動で登録します。

```bash
ENV=stg   # 本番は prod
for NAME in APP_KEY STRIPE_KEY STRIPE_SECRET MAIL_USERNAME MAIL_PASSWORD; do
  read -r -s -p "$NAME: " VALUE; echo
  aws ssm put-parameter --name "/nagoyameshi/$ENV/$NAME" --type SecureString --value "$VALUE" --overwrite
done
```

- APP_KEY は環境ごとに新しく作ります: `php artisan key:generate --show`
- MAIL_USERNAME と MAIL_PASSWORD は、SES コンソールで作った SMTP 認証情報です。

### 4. 最初のイメージを ECR に push する

ECS サービスは、最初は環境のタグ（`:stg` / `:prod`）のイメージで起動します。そのため、apply の前に 2つのイメージを用意します。
2回目以降は CodeBuild（buildspec.yml）が自動で push し、デプロイ後はコミット ID のタグのイメージに置き換わります。

アプリのリポジトリのルートで実行します。

```bash
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
REG=$ACCOUNT.dkr.ecr.ap-northeast-1.amazonaws.com
aws ecr get-login-password | docker login --username AWS --password-stdin $REG
docker build -f docker/php-fpm/Dockerfile -t $REG/nagoyameshi-app:stg   -t $REG/nagoyameshi-app:prod .
docker build -f docker/nginx/Dockerfile   -t $REG/nagoyameshi-nginx:stg -t $REG/nagoyameshi-nginx:prod .
for t in stg prod; do docker push $REG/nagoyameshi-app:$t; docker push $REG/nagoyameshi-nginx:$t; done
```

### 5. 検証環境 → 本番環境の順に作る

```bash
cd ../stg      # 次に ../prod でも同じ手順を行う
cp terraform.tfvars.example terraform.tfvars   # tfstate_bucket・allowed_cidrs・github_* などを入力
terraform init -backend-config="bucket=<tfstate_bucket>"
terraform plan
terraform apply
```

### 6. 初期データを入れる（環境ごとに 1回だけ）

初期 SQL はテーブル作成から行うため、必ず `init:db` を `migrate` より先に実行します。

```bash
ENV=stg
SUBNETS=$(cd envs/shared && terraform output -json app_subnet_ids | tr -d '[]"')
SG=$(cd envs/$ENV && terraform output -raw ecs_security_group_id)
aws ecs run-task --cluster nagoyameshi --launch-type FARGATE \
  --task-definition nagoyameshi-$ENV-migrate \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SG],assignPublicIp=DISABLED}" \
  --overrides '{"containerOverrides":[{"name":"app","command":["php","artisan","init:db"]}]}'
# 完了したら、--overrides を外して同じコマンドを実行する（migrate --force）
```

### 7. デプロイの確認

`github_branch` で指定したブランチに push すると、CodePipeline が次の順に実行します。

1. CodeBuild がイメージをビルドして push し、マイグレーションを実行する
2. ECS がブルーグリーン方式でデプロイする

切り替えた後は 10分間（`bake_time_minutes`）旧タスクを残しておき、問題がなければ旧タスクを停止します。

## アプリ側のファイル（アプリのリポジトリにあるもの）

このTerraformとあわせて使う、アプリのリポジトリ側のファイルです。

| ファイル | 内容 |
|---|---|
| `docker/php-fpm/Dockerfile` | Laravel＋PHP-FPM（コンテナ名 `app`）。Vite のビルド結果も含む |
| `docker/nginx/Dockerfile`、`docker/nginx/default.conf` | nginx（コンテナ名 `nginx`）。静的ファイルを返し、PHP は 127.0.0.1:9000 へ渡す |
| `buildspec.yml` | 2つのイメージをビルドし、コミット ID と環境のタグ（`ENV_TAG`）を付けて push する。マイグレーションの完了を待ち、失敗したらデプロイを止める |

アップロード画像（`storage/app/public`）は、タスク内の共有ボリュームを通して nginx から配信します。
タスクが入れ替わると消えるので、それまでのつなぎです。

### まだ必要な変更

1. **S3 への画像保存**
   - `league/flysystem-aws-s3-v3` を追加する
   - 画像の保存先を `prod/`・`stg/` の接頭辞に分ける
   - 対応が済んだら、tfvars に `filesystem_disk = "s3"` を設定する（初期値は `local`）

## plan・apply の確認とエラーのときの対応

apply の前に、必ず plan の結果を確認します。

```bash
terraform fmt -recursive -check   # 書き方のずれがないか
terraform validate                # 文法・参照のエラーがないか
terraform plan -out=plan.tfplan   # 何が作られる・変わる・消えるかを確認
terraform apply plan.tfplan       # 確認した plan のとおりに実行
```

plan で確認すること:

- `destroy`（削除）や `must be replaced`（作り直し）が出ていないか。特に RDS・S3・ALB は作り直すとデータや DNS 名が変わる
- 変更の数（`Plan: X to add, Y to change, Z to destroy`）が想定どおりか

よくあるエラーと対応:

| エラー・症状 | 原因 | 対応 |
|---|---|---|
| `Error acquiring the state lock` | 別の作業で State がロックされている、または前回の作業が途中で止まった | 他に作業している人がいないか確認する。いなければ `terraform force-unlock <ロック ID>` |
| `no matching Route 53 Hosted Zone found` | `domain_name` のホストゾーンがない | Route 53 にホストゾーンを作る（ドメイン取得時に自動で作られる） |
| ACM の検証が終わらず apply が止まる | DNS 検証レコードが反映されていない | ホストゾーンの NS が、ドメインの登録情報と一致しているか確認する |
| `Unable to find remote state` | shared を先に apply していない、または `tfstate_bucket` が違う | shared を apply し、tfvars のバケット名を確認する |
| ECS のタスクが起動しない（`CannotPullContainerError`） | ECR に `:prod` / `:stg` のイメージがない | 手順 4 で最初のイメージを push する |
| ECS のタスクが起動しない（`ResourceInitializationError`） | SSM のパラメータが登録されていない | 手順 3 で 5つのパラメータを登録する |
| パイプラインの Source が失敗する | GitHub 接続が「保留中」のまま | コンソールで接続を承認する（手順 2） |
| apply が途中で失敗した | 一部のリソースだけ作られている | エラーの原因を直して、もう一度 `terraform plan`・`apply` を実行する（作成済みのものは State にあるので二重には作られない） |

## 削除するとき

```bash
# 本番 RDS は削除保護が有効。先に tfvars で db_deletion_protection = false にして apply する
cd envs/prod   && terraform destroy
cd ../stg      && terraform destroy
# 画像バケットはバージョニング有効のため、先に全バージョンを削除してから実行する
cd ../shared   && terraform destroy
# bootstrap の State バケットは prevent_destroy で保護しているので、通常は残す
```

## 未確定の値（設計書の「確認事項」）

tfvars の例に入っている値は仮のものです。実際の値に置き換えてください。

- ドメイン名
- 検証サイトにアクセスを許可する IP（`allowed_cidrs`）
- 通知先のメールアドレス
- 送信元のメールアドレス
- GitHub のリポジトリとブランチ（検証は仮に `develop`）
- Auto Scaling の最大数（仮に 4）
