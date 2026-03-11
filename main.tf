# ------------------------
# Terraform configuration
# ------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

# ------------------------
# Provider
# ------------------------
provider "aws" {
  profile = "portfolio_user"
  region  = "ap-northeast-1"
}

# ------------------------
# Variables
# ------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}