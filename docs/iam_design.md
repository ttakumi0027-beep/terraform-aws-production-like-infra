# IAM設計書 (IAM Design)

## 1. 概要

本システムではAWS IAMを利用して、AWSリソースへのアクセス制御を行う。

アクセス権限は、ユーザーの役割ごとに管理する。

---

# 2. IAMユーザー / グループ設計

IAMユーザーは役割ごとにグループへ所属させ、グループ単位で権限を管理する。

| グループ | 役割 | 付与ポリシー |
|---|---|---|
| Admin | AWS環境管理者 | AdministratorAccess |
| Engineer | 開発者 | PowerUserAccess |
| Operator | 運用監視 | ReadOnlyAccess |

### Admin

AWS環境の管理者。

許可操作

- IAM管理
- ネットワーク設定
- EC2 / RDS / ALB管理

---

### Engineer

アプリケーション開発者。

許可操作

- EC2作成 / 削除
- Auto Scaling設定
- RDS操作
- ALB設定
- CloudWatch確認

制限

- IAM管理不可

---

### Operator

運用監視担当。

許可操作

- EC2状態確認
- RDS状態確認
- CloudWatchメトリクス確認
- ALB状態確認

制限

- リソース作成 / 変更不可

---

# 3. IAMロール設計

EC2インスタンスには、Systems Manager利用のためIAMロールを付与する。

| Role Name | 付与ポリシー | 用途 |
|---|---|---|
| EC2-SSM-Role | AmazonSSMManagedInstanceCore | EC2管理 |

これにより以下を実現する。

- Session Manager接続
- SSH不要のサーバ管理

---