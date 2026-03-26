# アーキテクチャ設計書 (Architecture Design)

## 1. 概要

本システムはAWS上に構築されたWebアプリケーション基盤であり、高可用性・セキュリティ・スケーラビリティを考慮した構成を採用。

本構成では以下のAWSサービスを利用。

- Amazon VPC
- Application Load Balancer (ALB)
- Amazon EC2
- Auto Scaling
- Amazon RDS
- AWS Systems Manager (SSM)
- Amazon CloudWatch
- Amazon Route 53
- AWS Certificate Manager (ACM)
- Amazon S3
- AWS CloudTrail

---

## 2. システム構成

本システムは以下の3層構成を採用。

- Presentation Layer
- Application Layer
- Database Layer

### Presentation Layer

- Application Load Balancer
- Amazon Route 53
- AWS Certificate Manager (ACM)

インターネットからのHTTP/HTTPSリクエストを受け付け、Auto Scaling Group内のEC2インスタンスへトラフィックを分散する。

また、Route53で管理する独自ドメインをALBへ名前解決し、ALBにはACM証明書を設定してHTTPS通信を有効化する。

HTTP(80)でのアクセスはHTTPS(443)へリダイレクトし、通信の暗号化を強制する。

### Application Layer

- Amazon EC2
- Auto Scaling Group

Webサーバおよびアプリケーションサーバとして動作する。

また、Auto Scalingにより以下を実現する。

- 負荷に応じたスケールアウト
- インスタンス障害時の自動復旧

### Database Layer

- Amazon RDS

アプリケーションデータを管理するリレーショナルデータベース。

Multi-AZ構成により以下を実現する。

- 自動フェイルオーバー
- 高可用性

---

## 3. 可用性設計

本システムでは以下の可用性設計を採用。

- Multi-AZ構成
- ALBによるロードバランシング
- Auto Scalingによるインスタンス管理
- RDS Multi-AZ構成

Availability Zoneに障害が発生した場合でも、サービス継続が可能な構成とする。

---

## 4. スケーラビリティ設計

Auto Scaling Groupを利用し、CloudWatchメトリクスに応じてEC2インスタンスを自動スケールする。

下記はスケーリング条件。

- CPU使用率
- ALBリクエスト数
- Target Tracking Policy

### Auto Scaling

本システムではTarget Tracking Scaling Policyを利用し、ASGAverageCPUUtilizationを指標として自動スケーリングを行う。

- 最小台数: 2
- 希望台数: 2
- 最大台数: 4
- 目標CPU使用率: 50%

---

## 5. 運用設計

EC2への管理アクセスはSSHは使用せず、AWS Systems Manager Session Managerを使用する。

これにより以下を実現する。

- SSHポート不要
- 踏み台サーバ不要

### 監査ログ・運用証跡

AWSアカウント上の操作記録はCloudTrailで取得し、S3へ保存する。

これにより以下を実現する。

- AWSリソースに対する操作履歴の記録
- セキュリティインシデント発生時の追跡
- 監査証跡の長期保管

---

## 6. 監視設計

以下のサービスを利用して監視を行う。

- Amazon CloudWatch
- ALB Health Check
- Auto Scaling Health Check

異常検知時にはAuto Scalingにより、インスタンスの自動復旧を行う。

### ログ出力設計

RDSでは以下のログをCloudWatch Logsへ出力する。

- error
- general
- slowquery

これにより、性能劣化やSQL実行状況の分析を容易にする。

### 監査ログの保管先

CloudTrailの出力先として専用のS3バケットを作成し、以下の設定を適用する。

- パブリックアクセスブロック
- バージョニング有効化
- サーバーサイド暗号化(AES256)
- ライフサイクル設定による保存期間管理

---

## 7. DNS / HTTPS設計

独自ドメインはRoute53 Hosted Zoneで管理する。

- ALBに対してAレコード(Alias)を設定
- ACM証明書はDNS検証方式で発行
- DNS検証用レコードはRoute53へ自動登録

これにより、証明書発行・検証・HTTPS化までをTerraformで一貫して自動化する。
