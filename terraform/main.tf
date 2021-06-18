provider "aws" {
 profile = "default"
 region = var.region
}
module "vpc" {
 source = "terraform-aws-modules/vpc/aws"

 name = "my-vpc"
 cidr = "10.0.0.0/16"


private_subnets = ["10.0.14.0/24", "10.0.28.0/24"]
public_subnets = ["10.0.135.0/24", "10.0.140.0/24"]
enable_nat_gateway = true

tags = {
 Terraform = "true"
 Environment = "dev"
 }
}
