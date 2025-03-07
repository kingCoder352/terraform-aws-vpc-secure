output "terraform_role_arn" {
  description = "ARN of the Terraform IAM role"
  value = aws_iam_role.terraform_role.arn
}
