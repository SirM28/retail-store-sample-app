##############################################
# GitHub OIDC Provider & Terraform Role
##############################################

# Create the GitHub OIDC provider if it doesn't exist
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    # GitHub's current OIDC thumbprint
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# IAM Role for GitHub Actions Terraform Deployment
resource "aws_iam_role" "terraform_github_actions" {
  name = "bedrock-terraform-role"
  description = "Role assumed by GitHub Actions workflows to deploy infrastructure using Terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Replace this with your actual GitHub username/repo
            "token.actions.githubusercontent.com:sub" = "repo:MayowaOladunni/retail-store-sample-app:*"
          }
        }
      }
    ]
  })
}

# Attach AdministratorAccess for full Terraform capability (simplified for project)
resource "aws_iam_role_policy_attachment" "terraform_admin_attach" {
  role       = aws_iam_role.terraform_github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Output the role ARN for GitHub Actions
output "terraform_github_role_arn" {
  description = "IAM Role ARN to use in GitHub Actions"
  value       = aws_iam_role.terraform_github_actions.arn
}
