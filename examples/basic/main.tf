terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket  = "jbiac-terraform-state-2025"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


# Specifies the AWS provider and region
provider "aws" {
  region  = "us-east-1"
  profile = "terraform"
}


# Calls the VPC module and passes required variables
module "secure_vpc" {
  source   = "../../modules/vpc" # Path to the VPC module
  vpc_cidr = "10.1.0.0/16" # Defines the VPC's CIDR block
  vpc_name = "ExampleVPC"
  public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"] # Defines public subnet CIDRs
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"] # Defines private subnet CIDRs
  enable_nat = false # Default: No NAT to avoid costs
}

# Outputs the created VPC details
output "vpc_id" {
  value = module.secure_vpc.vpc_id
}

module "secure_iam" {
  source = "../../modules/iam"
}

output "iam_role_arn" {
  value = module.secure_iam.terraform_role_arn
}
