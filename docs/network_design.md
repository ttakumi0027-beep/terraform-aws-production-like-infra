# ネットワーク設計書 (Network Design)

## 1. 概要

本システムはAWS上に構築されたWeb・アプリケーション基盤であり、可用性・セキュリティを考慮したネットワーク設計を採用。

主な設計方針は以下の通り。

- Public / Private Subnet分離
- Multi-AZ構成による高可用性
- Application層とDatabase層のネットワーク分離
- NAT GatewayによるPrivate Subnetのアウトバウンド通信
- VPC EndpointによるSSM接続

---

## 2. VPC設計

| 項目 | 内容 |
|------|------|
| VPC CIDR | 10.0.0.0/16 |
| リージョン | ap-northeast-1 (Tokyo) |

VPC内でPublic Subnet / Private Subnetを分離し、Web・アプリケーション層とデータベース層をそれぞれ異なるサブネットに配置する。

---

## 3. サブネット設計

| サブネット名 | CIDR | AZ | 用途 |
|--------------|------|----|------|
| nat-subnet-public-1a | 10.0.0.0/24 | ap-northeast-1a | ALB / NAT Gateway |
| nat-subnet-public-1c | 10.0.2.0/24 | ap-northeast-1c | ALB / NAT Gateway |
| app-subnet-private-1a | 10.0.1.0/24 | ap-northeast-1a | EC2 (Web / App) |
| app-subnet-private-1c | 10.0.3.0/24 | ap-northeast-1c | EC2 (Web / App) |
| db-subnet-private-1a| 10.0.4.0/24 | ap-northeast-1a | RDS |
| db-subnet-private-1c | 10.0.5.0/24 | ap-northeast-1c | RDS |

---

## 4. サブネット配置設計

本システムでは以下の3層構造を採用。

### Public Layer

- Application Load Balancer
- NAT Gateway

### Application Layer

- EC2 (Web / Application Server)
- Auto Scaling Group

### Database Layer

- Amazon RDS
- Multi-AZ構成

これにより以下を実現する。

- インターネットから直接DBへアクセス不可
- ALB経由でのみアプリケーションアクセス
- EC2からのみRDSへ接続可能

---

## 5. ルートテーブル設計

### Public Subnet

| Destination | Target |
|-------------|--------|
| 0.0.0.0/0 | Internet Gateway |

Public Subnetはインターネットアクセスを許可する。

---

### Private App Subnet

| Destination | Target |
|-------------|--------|
| 0.0.0.0/0 | NAT Gateway |

EC2からの外部通信はNAT Gatewayを経由する。

---

### Private DB Subnet

| Destination | Target |
|-------------|--------|
| 0.0.0.0/0 | NAT Gateway |

RDSから外部サービスへの通信が必要な場合、NAT Gatewayを経由してインターネットへアクセスする。

---

## 6. NAT Gateway設計

可用性を確保するため、各Availability ZoneにNAT Gatewayを配置する。

| AZ | NAT Gateway名 |
|----|-------------|
| ap-northeast-1a | nat-gw-1a |
| ap-northeast-1c | nat-gw-1c |

これによりAZ障害発生時でも他AZの通信に影響を与えない設計とする。

---

## 7. VPC Endpoint設計

EC2インスタンスへの管理アクセスはAWS Systems Managerを利用する。

SSM通信はVPC Endpointを使用し、インターネットを経由せずにプライベートネットワーク内で通信を行う。

利用するEndpoint

- com.amazonaws.ap-northeast-1.ssm
- com.amazonaws.ap-northeast-1.ssmmessages
- com.amazonaws.ap-northeast-1.ec2messages

---

## 8. RDS配置設計

Amazon RDSは専用のPrivate DB Subnetに配置する。

DB Subnet Group

- 10.0.4.0/24 (AZ-a)
- 10.0.5.0/24 (AZ-c)

Multi-AZ構成により

- Primary DB
- Standby DB

を異なるAZに配置し、高可用性を確保する。

---

## 9. 可用性設計

本ネットワークでは以下の高可用性設計を採用。

- Multi-AZサブネット配置
- ALBによるロードバランシング
- Auto Scaling GroupによるEC2の自動スケーリング
- RDS Multi-AZ構成
- NAT GatewayのAZ分散配置