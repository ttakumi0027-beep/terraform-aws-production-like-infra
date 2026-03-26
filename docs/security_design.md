# セキュリティ設計書 (Security Design)

## 1. 概要

本システムではAWSのベストプラクティスに基づき、多層防御のセキュリティ設計を採用。

主な対策は以下の通り。

- Public / Private Subnet分離
- Security Groupによる通信制御
- 踏み台サーバの廃止設計
- IAMによるアクセス制御

---

## 2. ネットワークセキュリティ

インターネットから直接アクセス可能なリソースは、Application Load Balancerのみとする。

EC2およびRDSはPrivate Subnetに配置する。

これにより以下を実現する。

- 外部からの直接アクセス防止
- 攻撃対象の最小化

---

## 3. セキュリティグループ設計

### ALBセキュリティグループ構成

| Type | Port | Source |
|-----|-----|------|
| HTTP | 80 | 0.0.0.0/0 |
| HTTPS | 443 | 0.0.0.0/0 |

---

### EC2セキュリティグループ構成

| Type | Port | Source |
|-----|-----|------|
| HTTP | 80 | ALB Security Group |

EC2はALBからの通信のみ許可する。

---

### RDSセキュリティグループ構成

| Type | Port | Source |
|-----|-----|------|
| MySQL | 3306 | EC2 Security Group |

RDSはアプリケーションサーバからの通信のみ許可する。

---

## 4. 踏み台サーバ廃止設計

EC2への接続は踏み台サーバを使用せず、AWS Systems Manager Session Managerを利用する。

これにより

- SSHポート開放不要
- セキュリティ向上
- アクセスログ取得

を実現する。

---

## 5. VPC Endpoint設計

SSM通信はVPC Endpointを利用し、インターネットを経由しない設計とする。

利用Endpoint

- com.amazonaws.ap-northeast-1.ssm
- com.amazonaws.ap-northeast-1.ssmmessages
- com.amazonaws.ap-northeast-1.ec2messages

### VPC Endpointセキュリティ

VPC Endpointには専用Security Groupを適用し、アプリケーションサーバのSecurity GroupからのHTTPS(443)通信のみを許可する。

これにより、SSM通信経路を必要最小限に限定する。

---

## 6. データベースセキュリティ設計

RDSには以下のセキュリティ対策を適用する。

- Private Subnet配置
- Security Groupによるアクセス制御
- Multi-AZ構成
- 自動バックアップ

### RDS追加設定

RDSには以下の追加対策を適用する。

- ストレージ暗号化
- Publicly Accessible無効化
- CloudWatch Logs出力(error / general / slowquery)
- 自動マイナーバージョンアップグレード

---

## 7. HTTPS通信設計

ALBにはACM証明書を設定し、クライアントとALB間の通信をHTTPSで暗号化する。

- リスナーポート443でHTTPSを受け付ける
- SSL Policy: `ELBSecurityPolicy-2016-08`
- HTTP(80)アクセスはHTTPS(443)へ301リダイレクトする

これにより以下を実現する。

- 通信の盗聴防止
- 通信経路の改ざん防止
- 利用者のアクセス統一(HTTPS強制)

---

## 8. DNS / 証明書検証設計

ACM証明書の発行時にはDNS検証方式を採用する。

DNS検証用レコードはRoute53へ自動登録し、ドメイン所有確認を行う。

これにより、手動設定によるミスを防ぎ、証明書発行をコードで一元管理する。

---

## 9. 監査ログ保管設計

AWS操作の監査ログはCloudTrailで取得し、専用のS3バケットへ保存する。

S3バケットには以下の設定を適用する。

- パブリックアクセスブロック
- バージョニング有効化
- サーバーサイド暗号化(AES256)
- ライフサイクルによる保持期間管理

また、CloudTrailログファイル検証を有効化し、ログ改ざん検知に対応する。

---

