provider "aws" {
        region     = "us-east-1"
}
# create an instance

variable cidr_blocks {}
variable subnet_idr_blocks {}
variable avail_zone {}
variable env_prefix {}
variable developer_ip_address_range {}

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


resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.mybuilderbook-subnet-1.id
    route_table_id = aws_route_table.mybuilderbook-route-table.id
}


resource "aws_security_group" "mybuilderbook-sg" {
  name = "mybuilderbook-sg"
  vpc_id = aws_vpc.mybuilderbook-vpc.id

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cid_block = [var.developer_ip_address_range]
  }

  ingress {
      from_port = 3000
      to_port = 3000
      protocol = "tcp"
      cid_block = ["0.0.0.0/0"]
  }

  egress  {

      from_port = 0
      to_port = 0
      protocol = "-1"
      cid_block = ["0.0.0.0/0"]
      prefix_list_ids = []
  }

   tags = {
      Name: "${var.env_prefix}-sg"
    }
}
