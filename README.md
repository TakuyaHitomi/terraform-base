# activecore
## アカウント情報の設定
### $HOME/.aws/config の設定
$HOME/.aws/config に以下の内容を追加する

```bash
```

## S3 Backend の構築
**環境を構築するアカウント内にすでに作成済みの場合は不要**

```bash
$ cd tfstate-backend
$ terraform init
$ terraform plan
$ terraform apply
aws_region = "ap-northeast-1"
dynamodb_table_tfstate_lock_name = "dynamodb_table_tfstate_lock"
s3_bucket_tfstate_name = "xxxxxxxxxxxx-tfstate-activecore-jp"
```

## S3 Buckend の設定
bucket は上の output に出力された s3_bucket_tfstate_name を使用
profile は $HOME/.aws/config などに自身が設定している profile を使用

```bash
$ cd terraform
$ terraform init -backend-config="dynamodb_table=dynamodb_table_tfstate_lock" -backend-config="bucket=xxxxxxxxxxxx-tfstate-activecore-jp" -backend-config="region=ap-northeast-1" -backend-config="profile=activecore"
```

## 環境の構築手順
本番適用時は `-var-file=develop.tfvars` を `-var-file=production.tfvars` に変更して実行

```bash
$ terraform plan -var-file=develop.tfvars
$ terraform apply -var-file=develop.tfvars
```

## Container Image の ECR へのプッシュ手順
profile は $HOME/.aws/config などに自身が設定している profile を使用
xxxxxxxxxxxx の箇所は ECR Repository がある AWS アカウントの ID

1. 認証トークンを取得し、レジストリに対して Docker クライアントを認証

```bash
$ aws ecr get-login-password --region ap-northeast-1 --profile=activecore | docker login --username AWS --password-stdin xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com
```

2. docker image をビルド
version は適宜更新する

```bash
$ cd containers/suid
$ docker build -t activecore:0.1.x .
```

3. イメージにタグを付与

```bash
$ docker tag activecore:0.1.x xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/activecore:0.1.x
```

4. AWS リポジトリにこのイメージをプッシュ

```bash
$ docker push xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/activecore:0.1.x
```

## BLEA の展開
[Baseline Environment on AWS](https://github.com/aws-samples/baseline-environment-on-aws/blob/main/README_ja.md)
ドキュメントに従って環境を用意しアカウントに展開

```bash
$ cd usecases/base-standalone
$ npx cdk bootstrap -c environment=activecore --profile activecore
$ npx cdk deploy --all -c environment=activecore --profile activecore
```

以下の機能がセットアップされる

- CloudTrail による API のロギング
- AWS Config による構成変更の記録
- GuardDuty による異常なふるまいの検知
- SecurityHub によるベストプラクティスからの逸脱検知 (AWS Foundational Security Best Practice, CIS benchmark)
- デフォルトセキュリティグループの閉塞 （逸脱した場合自動修復）
- AWS Health イベントの通知
- セキュリティに影響する変更操作の通知（一部）

## BLEA が作成した S3 Bucket にライフサイクルを設定する
BLEA が作成する S3 Bucket のリストと各役割は以下の通り
1. blea-base-config-configbucket
AWS Config が継続監視している AWS Resource への変更履歴を保存する Bucket
[配信チャネルの管理](https://docs.aws.amazon.com/ja_jp/config/latest/developerguide/manage-delivery-channel.html)

2. blea-base-trail-archivelogsbucket
cloudtrail bucket への操作履歴を保存するバケット
[サーバーアクセスログを使用したリクエストのログ記録](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/userguide/ServerLogs.html)

3. blea-base-trail-cloudtrailbucket
cloudtrail が収集した API の呼び出し履歴などを保存する Bucket
[AWS アカウント の証跡の作成](https://docs.aws.amazon.com/ja_jp/awscloudtrail/latest/userguide/cloudtrail-create-and-update-a-trail.html)

上の 3 つの Bucket にライフサイクルルールを設定し 1 年でデータを削除する
