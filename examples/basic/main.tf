terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket  = "jbiac-terraform-state-2025"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform"
}

module "secure_vpc" {
  source   = "../../modules/vpc"
  vpc_cidr = "10.1.0.0/16"
  vpc_name = "ExampleVPC"
}

output "vpc_id" {
  value = module.secure_vpc.vpc_id
}
