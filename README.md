# terraform-aws-production-like-infra

## 概要
本プロジェクトは、AWS上にWeb三層アーキテクチャを構築し、Terraformを用いてインフラのコード化を行ったポートフォリオです。

本構成は、実務で利用される一般的なWeb三層アーキテクチャをベースに、セキュリティ・可用性・運用性を考慮して設計しています。

## 構成図
<img src="./images/architecture.png" width="100%">

## 使用技術
- AWS
  - VPC / EC2 / RDS / ALB / NAT Gateway / SSM
  - Route53 / ACM
  - S3（ログ保存）
  - CloudTrail（監査ログ）
- Terraform
- Linux / Apache

### Terraform採用理由

- インフラ構成をコードで管理することで再現性を担保
- 手動構築による設定ミスの防止

## 設計方針

- セキュリティ

  - EC2・RDSはプライベートサブネットに配置
    - 外部からの直接アクセスを遮断し、攻撃対象領域を最小化するため
      
  - ALB経由でのみアクセス可能
    - サーバ（EC2）をALB経由の通信のみを許可することで、インターネットからの直接攻撃を防ぐ

  - NAT Gateway（以下、NAT GW）の利用
    - プライベートサブネット内のEC2がインターネットへアウトバウンド通信を行うため
    - 外部からの直接アクセスを防ぎつつ、パッケージ更新などを可能にする
    - 各AZに配置することで単一障害点を排除
   
  - ユーザからのHTTPS通信対応
    - ACMでSSL/TLS証明書を管理
    - ALBでSSL終端を行い、HTTPS通信を実現
    - Route53でドメイン管理および名前解決を実施
   
  - SSMによるインスタンス管理
    - IAMロールを利用して安全に接続
    - SSHポート（22番）を開放せずに運用可能
    - 踏み台サーバ不要な構成

  - セキュリティグループ設計

    | 通信経路 | プロトコル | ポート | 用途 |
    |----------|-----------|--------|------|
    | ALB → EC2 | HTTP      | 80     | ALBからWebサーバへの通信 |
    | EC2 → RDS | MySQL     | 3306   | DB接続（EC2からのみ許可） |
    | 外部 → EC2 | -        | -      | 直接アクセス禁止（SSM接続のみ） |

- 可用性
  - EC2 / RDS / NAT GW のマルチAZ構成
    - 耐障害性の確保と可用性の向上をさせるため
    
  - ALBによる負荷分散
    - 単一障害点を排除し、トラフィックを分散することで可用性を向上させるため

- 運用性
  - CloudTrailによりAPI操作を記録し監査可能
  - S3にログを集約し長期保存を実現
  - 障害発生時の原因調査を容易にする設計


 ## 通信フロー

  1. ユーザーがRoute53で管理されたドメインへアクセス
  2. ALB（HTTPS）でリクエストを受信
  3. ALBからプライベートサブネットのEC2へルーティング
  4. EC2がRDSへ接続しデータ取得
  5. レスポンスをユーザーへ返却

  ※ EC2およびRDSはインターネットから直接アクセス不可
  
## ディレクトリ構成

```
# 本リポジトリでは、Terraformコードだけでなく、設計書・構成図・初期設定用スクリプトもあわせて管理し、構築意図が分かるようにしています。
.
├── terraform-aws-production-like-infra/
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
│   ├── network.tf                 # VPC / Subnet / Endpoint / NAT GW / IGW
│   ├── rds.tf                     # RDS
│   ├── route53.tf                 # Route53
│   ├── security.tf                # Security Group
│   └── variables.tf               # 変数定義
└── README.md                      # 本ドキュメント
```

## 構築手順

1. AWS認証情報を設定

2. Terraform初期化

   ```
   terraform init
   ```

4. 作成リソースの確認

   ```
   terraform plan
   ```

5. 実行

   ```
   terraform apply -auto-approve
   ```

## 工夫した点

- セキュリティ向上のため、Webサーバをプライベートサブネットに配置

- SSM使ったサーバ接続
  - 踏み台サーバを廃止し、SSHポート（22番）を開放せずに安全に接続可能
  - セキュリティリスクの低減および運用負荷の削減を実現
  
- SSL証明書によるHTTPS化

- CloudTrailとS3を連携し監査ログを保存


## 今後の改善点

- CI/CD（GitHub Actions）の導入

- ECSを用いたコンテナ化によるアプリケーションとインフラの分離

- WAFの導入
