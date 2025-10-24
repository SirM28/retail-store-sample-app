# ===============================================
# Read-only Developer IAM User Configuration
# ===============================================

resource "aws_iam_user" "developer_readonly" {
  name = "developer-readonly"
  tags = {
    Project = "project-bedrock"
    Role    = "ReadOnlyDeveloper"
  }
}

resource "aws_iam_user_policy" "developer_readonly_policy" {
  name = "DeveloperReadOnlyPolicy"
  user = aws_iam_user.developer_readonly.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EKSReadOnly"
        Effect   = "Allow"
        Action   = [
          "eks:Describe*",
          "eks:List*"
        ]
        Resource = "*"
      },
      {
        Sid      = "CloudWatchReadOnly"
        Effect   = "Allow"
        Action   = [
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "logs:Get*",
          "logs:Describe*",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid      = "RDSReadOnly"
        Effect   = "Allow"
        Action   = [
          "rds:Describe*"
        ]
        Resource = "*"
      },
      {
        Sid      = "DynamoDBReadOnly"
        Effect   = "Allow"
        Action   = [
          "dynamodb:Describe*",
          "dynamodb:List*",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = "*"
      },
      {
        Sid      = "S3ReadOnly"
        Effect   = "Allow"
        Action   = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Optional: Access key (for local use or CI/CD)
resource "aws_iam_access_key" "developer_readonly_key" {
  user = aws_iam_user.developer_readonly.name
}

output "developer_readonly_user" {
  value = aws_iam_user.developer_readonly.name
}

output "developer_readonly_access_key_id" {
  value = aws_iam_access_key.developer_readonly_key.id
  sensitive = true
}

output "developer_readonly_secret_access_key" {
  value = aws_iam_access_key.developer_readonly_key.secret
  sensitive = true
}
