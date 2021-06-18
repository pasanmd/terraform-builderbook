provider "aws" {
        region     = "us-east-1"
}
# create an instance

variable cidr_blocks {}
variable subnet_idr_blocks {}
variable avail_zone {}
variable env_prefix {}

#create the vpc

resource "aws_vpc" "myapp-vpc" {
    cidr_block= var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

#create the subnet
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cid_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tag = {
        Name: "${var.env_prefix}-subnet-1}"
    }
}

