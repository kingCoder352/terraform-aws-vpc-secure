resource "aws_iam_role" "terraform_role" {
  name = "TerraformDeploymentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com" # Allowing EC2 or Terraform to assume this role
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "TerraformDeploymentRole"
  }
}

resource "aws_iam_policy" "terraform_policy" {
  name = "TerraformDeploymentPolicy"
  description = "Least privilege permissions for Terraform to manage AWS infrastructure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*", # Allow Terraform to create/modify EC2 instances
          "vpc:*", # Allow Terraform to manage networking
          "iam:PassRole" # Allow Terraform to assign IAM roles to instances
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "iam:DeleteRole", # Prevent Terraform from deleting critical IAM roles
          "iam:DeletePolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_attach" {
  policy_arn = aws_iam_policy.terraform_policy.arn
  role       = aws_iam_role.terraform_role.name
}
