
locals {
  name   = "terraform"
  region = "ap-northeast-1"
}


# ------------------------
# Tag name
# ------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}


# ------------------------
# IAM Uses
# ------------------------
variable "iam_users" {
  description = "IAM users and their group memberships"
  type = map(object({
    groups = list(string)
  }))
}

# ------------------------
# Domain
# ------------------------
variable "domain" {
  type = string
}

# ------------------------
# DB login 
# ------------------------
variable "db_username" {
  type        = string
  description = "username for RDS"
}

variable "db_password" {
  type        = string
  description = "password for RDS"
  sensitive   = true
}