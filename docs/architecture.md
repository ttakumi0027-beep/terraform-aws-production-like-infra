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

---

## 2. システム構成

本システムは以下の3層構成を採用。

- Presentation Layer
- Application Layer
- Database Layer

### Presentation Layer

- Application Load Balancer

インターネットからのHTTP/HTTPSリクエストを受け付け、Auto Scaling Group内のEC2インスタンスへトラフィックを分散する。

### Application Layer

- Amazon EC2
- Auto Scaling Group

Webサーバおよびアプリケーションサーバとして動作する。

また、Auto Scalingにより以下を実現する。

- 負荷に応じたスケールアウト
- インスタンス障害時の自動復旧

### Database Layer

- Amazon RDS

アプリケーションデータを管理するリレーショナルデータベースとする。

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

スケーリング条件は下記とする。

- CPU使用率
- ALBリクエスト数
- Target Tracking Policy

---

## 5. 運用設計

EC2への管理アクセスはSSHは使用せず、AWS Systems Manager Session Managerを使用する。

これにより以下を実現する。

- SSHポート不要
- 踏み台サーバ不要

---

## 6. 監視・監査設計

以下のサービスを利用して監視・監査を行う。

- Amazon CloudWatch
- AWS CloudTrail
- ALB Health Check
- Auto Scaling Health Check

異常検知時にはAuto Scalingによるインスタンスの自動復旧を行い、AWS操作の監査証跡の記録を行う。

---