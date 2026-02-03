resource "aws_s3_bucket" "other" {
  provider = aws.other
  bucket = "kuba-test-bucket-other-2025"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "other" {
  provider = aws.other
  bucket = aws_s3_bucket.other.id
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
          #"s3:GetBucketLocation",
        ]
        Resource = [
          aws_s3_bucket.other.arn,
          "${aws_s3_bucket.other.arn}/*",
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
          aws_s3_bucket.other.arn,
          "${aws_s3_bucket.other.arn}/*",
        ]
      }
    ]
  })
}
