provider "aws" {
        region     = "us-east-1"
}
# create an instance

variable cidr_blocks {}
variable subnet_idr_blocks {}
variable avail_zone {}
variable env_prefix {}

#create the vpc

resource "aws_vpc" "mybuilderbook-vpc" {
    cidr_block= var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

#create the subnet
resource "aws_subnet" "mybuilderbook-subnet-1" {
    vpc_id = aws_vpc.mybuilderbook-vpc.id
    cid_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tag = {
        Name: "${var.env_prefix}-subnet-1}"
    }
}

resource "aws_route_table" "mybuilderbook-route-table"  {

   vpc_id =  aws_vpc.mybuilderbook-vpc.id

   route  {
       cidr_block = "0.0.0.0/0"
       gateway_id =  xxx
    }

   tags = {
      Name: "${var.env_prefix}-rtb"
    }

}

resource "aws_internet_gateway" "mybuilderbook-igw" {
     vpc_id =  aws_vpc.mybuilderbook-vpc.id

   tags = {
      Name: "${var.env_prefix}-igw"
    }

}
