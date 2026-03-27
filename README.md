# terraform-aws-production-like-infra

## 概要
本プロジェクトは、AWS上にWeb3層アーキテクチャを構築し、Terraformを用いてインフラのコード化を行ったポートフォリオです。

可用性・セキュリティ・運用性を意識した構成を採用しています。

## 構成図
![構成図](./images/architecture.png)

## 使用技術
- AWS
  - VPC / EC2 / RDS / ALB
  - Route53 / ACM
  - S3（ログ保存）
  - CloudTrail（監査ログ）
- Terraform
- Linux / Apache

## 設計方針

- セキュリティ
  - EC2・RDSはプライベートサブネットに配置
  - ALB経由でのみアクセス可能

- 可用性
  - マルチAZ構成
  - ALBによる負荷分散

- 運用性
  - CloudTrailで操作ログを取得
  - S3へログ集約

- HTTPS対応
  - ACMで証明書を管理
  - Route53でDNS設定
 
## ディレクトリ構成

```
# 本リポジトリでは、Terraformコードだけでなく、設計書・構成図・初期設定用スクリプトもあわせて管理し、構築意図が分かるようにしています。
.
├── terraform/
│   ├── docs/
│   │   ├── architecture.md        # AWS構成設計書
│   │   ├── iam_design.md          # IAM構成設計書
│   │   ├── network_design.md      # ネットワーク構成設計書
│   │   └── security_design.md     # セキュリティ構成設計書
│   ├── images/
│   │   └── architecture.png       # AWS構成図
│   ├── source/
│   │   └── initialize.sh          # user_data起動シェル
│   ├── acm.tf                     # SSL証明書
│   ├── appserver.tf               # Web / Appサーバ
│   ├── cloudtrail.tf              # AWS操作ログ
│   ├── data.tf                    # AMI参照
│   ├── elb.tf                     # ロードバランサ(ALB)
│   ├── iam.tf                     # IAM
│   ├── main.tf                    # Provider / Terraform設定
│   ├── network.tf                 # VPC / Subnet / Endpoint / NAT / IGW
│   ├── rds.tf                     # RDS
│   ├── route53.tf                 # Route53
│   ├── security.tf                # Security Group
│   └── variables.tf               # 変数定義
└── README.md                      # 本ドキュメント
```

## 構築手順

1. AWS認証情報を設定

2. Terraform初期化
   terraform init

3. 作成リソースの確認
   terraform plan

4. 実行
   terraform apply -auto-approve

## 工夫した点

- セキュリティ向上のため、Webサーバをプライベートサブネットに配置
- SSL証明によるHTTPS化
- RDSのフェイルオーバー構成による可用性の確保
- NATのマルチAZ構成による可用性の確保
- CloudTrailとS3を連携し監査ログを保存


## 今後の改善点

- CI/CD（GitHub Actions）の導入
- ECSによる、Web/Appコンテナ化による疎結合
- WAFの導入
