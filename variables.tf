
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