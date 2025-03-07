
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type = string
  default = "SecureVPC"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type = list(string)
}

variable "enable_nat" {
  description = "Enable NAT Gateway or NAT Instance"
  type = bool
  default = false # NAT is disabled by default to avoid costs
}
