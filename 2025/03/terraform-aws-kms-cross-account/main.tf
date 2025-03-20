data "aws_caller_identity" "main" {}
data "aws_organizations_organization" "main" {}

data "aws_iam_policy_document" "main_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root",
      ]
    }
  }
}

resource "aws_iam_role" "main" {
  name               = "test-kms-access-role"
  assume_role_policy = data.aws_iam_policy_document.main_assume_role_policy.json # (not shown)
}

resource "aws_iam_role_policy" "main" {
  name = "test_policy_main"
  role = aws_iam_role.main.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # {
      #   Action   = ["s3:*"]
      #   Effect   = "Allow"
      #   Resource = "*"
      #   Condition = {
      #     StringNotEquals = {
      #       "aws:ResourceAccount" = data.aws_caller_identity.main.id
      #     }
      #     StringEquals = {
      #       "aws:ResourceOrgID" = "$${aws:PrincipalOrgID}"
      #     }
      #   }
      # },
      # {
      #   Action   = [
      #     "kms:Encrypt",
      #     "kms:Decrypt",
      #     "kms:DescribeKey",
      #     "kms:GenerateDataKey*",
      #   ]
      #   Effect   = "Allow"
      #   Resource = "*"
      #   # Condition = {
      #   #   StringNotEquals = {
      #   #     "aws:ResourceAccount" = data.aws_caller_identity.main.id
      #   #   }
      #   #   StringEquals = {
      #   #     "aws:ResourceOrgID" = "$${aws:PrincipalOrgID}"
      #   #   }
      #   # }
      # },
      {
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:ResourceAccount" = data.aws_caller_identity.main.id
          }
          StringEquals = {
            "aws:ResourceOrgID" = "$${aws:PrincipalOrgID}"
          }
        }
      },
    ]
  })
}


resource "aws_s3_bucket" "main" {
  bucket = "kuba-test-bucket-main"
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
            "arn:aws:iam::${data.aws_caller_identity.other.account_id}:root",
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

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Principal = {
        AWS = [
          "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root",
          "arn:aws:iam::${data.aws_caller_identity.other.account_id}:root"
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
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*",
      ]
      Condition = {
        StringEquals = {
          "aws:PrincipleOrgID" = data.aws_organizations_organization.main.id
        }
      }
    }]
  })
}
