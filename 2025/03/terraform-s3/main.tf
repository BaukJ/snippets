data "aws_caller_identity" "main" {}

resource "aws_s3_bucket" "main" {
  bucket = "kuba-test-bucket-main-2025"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}

resource "aws_kms_key" "main" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root",
            "arn:aws:iam::891377217644:root", # arup-dev
            "arn:aws:iam::992382511840:role/data-lake-euw1-prod-platform-support",
          ]
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow decrypt use of the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::992382511840:role/data-lake-euw1-prod-platform-support",
          ]
        },
        Action = [
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root",
            "arn:aws:iam::891377217644:root", # arup-dev
          ]
        }
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObjectTagging",
          "s3:DeleteObject",
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*",
        ]
      },
      {
        Principal = {
          AWS = [
            "arn:aws:iam::992382511840:role/data-lake-euw1-prod-platform-support",
          ]
        }
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectTagging",
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*",
        ]
      }
    ]
  })
}
