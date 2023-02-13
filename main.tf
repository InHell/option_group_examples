
data "aws_iam_policy_document" "dev_rds_backup" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
      "s3:GetObjectMetaData",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "arn:aws:s3:::backup-rds-*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::backup-rds-*",
      "arn:aws:s3:::backup-rds-*/*",
    ]
  }
}

resource "aws_iam_policy" "dev_rds_backup" {
  name   = "dev_rds_backup"
  path   = "/"
  policy = data.aws_iam_policy_document.dev_rds_backup.json

  tags = {
    environment = "${var.environment}-RDS"
  }
}

resource "aws_iam_role" "dev-rds-backup-policy" {
  name               = "dev-rds-backups"
  assume_role_policy = data.aws_iam_policy_document.rds-service.json

  tags = {
    environment = "${var.environment}-RDS"
  }
}

data "aws_iam_policy_document" "rds-service" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "dev-rds-backup-policy" {
  role       = aws_iam_role.dev-rds-backup-policy.name
  policy_arn = aws_iam_policy.dev_rds_backup.arn
}
