provider "aws" {
        region     = "us-east-1"
}
# create an instance

variable cidr_blocks {}
variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable developer_ip_address_range {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable certificate_arn {}
variable mybuilerbook_server {}
variable aws_route53_zone {}
variable mybuilderbook_zone {}
variable route53_hosted_zone_name {}


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
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1}"
    }
}

resource "aws_route_table" "mybuilderbook-route-table"  {

   vpc_id =  aws_vpc.mybuilderbook-vpc.id

   route  {
       cidr_block = "0.0.0.0/0"
       gateway_id =  aws_internet_gateway.mybuilderbook-igw.id
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
      cidr_blocks = [var.developer_ip_address_range]
  }

  ingress {
      from_port = 3000
      to_port = 3000
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress  {

      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
  }

   tags = {
      Name: "${var.env_prefix}-sg"
    }
}

resource "aws_alb" "mybuilderbook-alb" {
  name            = "mybuilderbook-alb"
  security_groups = ["${aws_security_group.mybuilderbook-sg.id}"]
  subnets         = ["${aws_subnet.mybuilderbook-subnet-1.id}"]
  tags = {
    Name = "mybuiderbook-alb"
  }
}



resource "aws_alb_target_group" "group" {
  name     = "mybuilderbook-alb-target"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.mybuilderbook-vpc.id
  stickiness {
    type = "lb_cookie"
  }
  # setup the health check.
  health_check {
    path = "/"
    port = 3000
  }
}

resource "aws_alb_listener" "mybuilderbook_listener_http" {
  load_balancer_arn = "${aws_alb.mybuilderbook-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "mybuilderbook_listener_https" {
  load_balancer_arn = "${aws_alb.mybuilderbook-alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-mybuilderbook"
  certificate_arn   = "${var.certificate_arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}

data "aws_route53_zone" "mybuilderbook_zone" {
  name = "${var.route53_hosted_zone_name}"
}



resource "aws_route53_record" "mybuilderbook-A-record" {
  zone_id = "${data.aws_route53_zone.mybuilderbook_zone.zone_id}"
  name    = "${var.route53_hosted_zone_name}"
  type    = "A"
  alias {
    name                   = "${aws_alb.mybuilderbook-alb.dns_name}"
    zone_id                = "${aws_alb.mybuilderbook-alb.zone_id}"
    evaluate_target_health = true
  }
}


data "aws_ami" "latest-amazon-linux-image" {
   most_recent = true
   owners = ["amazon"]
    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}


output "aws_ami_id" {
    value  = data.aws_ami.latest-amazon-linux-image.id
}


output "ec2_public_ip" {
    value = aws_instance.mybuilderbook_server.public_ip
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = "${file(var.public_key_location)}"
}

resource "aws_instance" "mybuilderbook_server" {
    ami =  data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.mybuilderbook-subnet-1.id
    vpc_security_group_ids = aws_security_group.mybuilderbook-sg.id
    availability_zone  = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    user_data = file("setup-builderbook.sh")
}



