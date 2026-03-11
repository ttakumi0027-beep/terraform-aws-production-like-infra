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

---

## 6. データベースセキュリティ設計

RDSには以下のセキュリティ対策を適用する。

- Private Subnet配置
- Security Groupによるアクセス制御
- Multi-AZ構成
- 自動バックアップ

---

## 7. 最小権限の原則

IAMポリシーはLeast Privilege Principle（最小権限の原則）に基づき設計する。

---