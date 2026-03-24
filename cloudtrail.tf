# ------------------------
# Data Sources
# ------------------------
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ------------------------
# S3 bucket for CloudTrail logs
# ------------------------
resource "aws_s3_bucket" "cloudtrail_logs_s3" {
  bucket = "${var.project}-${var.environment}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "${var.project}-${var.environment}-cloudtrail-logs"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs_s3" {
  bucket = aws_s3_bucket.cloudtrail_logs_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs_s3" {
  bucket = aws_s3_bucket.cloudtrail_logs_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs_s3" {
  bucket = aws_s3_bucket.cloudtrail_logs_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------
# Lifecycle rule
# ------------------------
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs_s3" {
  bucket = aws_s3_bucket.cloudtrail_logs_s3.id

  rule {
    id     = "cloudtrail-log-lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 180
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# ------------------------
# S3 bucket policy for CloudTrail
# ------------------------
data "aws_iam_policy_document" "cloudtrail_s3_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.cloudtrail_logs_s3.arn
    ]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail_logs_s3.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_s3" {
  bucket = aws_s3_bucket.cloudtrail_logs_s3.id
  policy = data.aws_iam_policy_document.cloudtrail_s3_policy.json
}

# ------------------------
# CloudTrail
# ------------------------
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "${var.project}-${var.environment}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs_s3.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true

  tags = {
    Name    = "${var.project}-${var.environment}-cloudtrail"
    Project = var.project
    Env     = var.environment
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs_s3]
}


#######################################
# Outputs
#######################################
output "cloudtrail_name" {
  value = aws_cloudtrail.cloudtrail.name
}

output "cloudtrail_s3_bucket_name" {
  value = aws_s3_bucket.cloudtrail_logs_s3.id
}

output "cloudtrail_home_region" {
  value = data.aws_region.current.name
}