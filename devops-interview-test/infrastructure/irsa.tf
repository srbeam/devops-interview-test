# Use existing OIDC provider
data "aws_iam_openid_connect_provider" "eks" {
  url = "https://oidc.eks.ap-southeast-1.amazonaws.com/id/1452B34E049FEAB2EBF67120A1E100F1"  # Replace with your OIDC issuer URL
}

# Create IAM Role for Service Account (IRSA)
resource "aws_iam_role" "irsa_role" {
  name = "eks-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals" = {
            "oidc.eks.ap-southeast-1.amazonaws.com/id/1452B34E049FEAB2EBF67120A1E100F1:sub" = "system:serviceaccount:default:my-service-account"
          }
        }
      }
    ]
  })
}

# Create IAM Policy for S3 Read-Only Access
resource "aws_iam_policy" "s3_read_only" {
  name        = "eks-irsa-s3-read-only"
  description = "Allows EKS pods to read from S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::my-devops-data-bucket"] #S3 bucket name
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::my-devops-data-bucket/*"] #S3 bucket name
      }
    ]
  })
}

# Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  policy_arn = aws_iam_policy.s3_read_only.arn
  role       = aws_iam_role.irsa_role.name
}
