data "aws_caller_identity" "other" {
  provider = aws.other
}
data "aws_organizations_organization" "other" {
  provider = aws.other
}

resource "aws_s3_bucket" "other" {
  provider = aws.other
  bucket = "kuba-test-bucket-other2"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "other" {
  provider = aws.other
  bucket = aws_s3_bucket.other.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.other.arn
    }
  }
}


resource "aws_kms_key" "other" {
  provider = aws.other
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.other.account_id}:root"
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
            "arn:aws:iam::${data.aws_caller_identity.other.account_id}:root",
            aws_iam_role.main.arn,
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
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "other" {
  provider = aws.other
  bucket = aws_s3_bucket.other.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Principal = {
        AWS = [
          "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root",
          "arn:aws:iam::${data.aws_caller_identity.other.account_id}:root",
          aws_iam_role.main.arn,
        ]
      }
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:DeleteObject",
      ]
      Resource = [
        aws_s3_bucket.other.arn,
        "${aws_s3_bucket.other.arn}/*",
      ]
      # Condition = {
      #   StringEquals = {
      #     "aws:PrincipleOrgID" = data.aws_organizations_organization.other.id
      #   }
      # }
    }]
  })
}
