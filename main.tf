variable "name" {
    description = "name of application"
    type = string
    # default = "tschui"
}

variable "vpc_id" {
    description = "vpc id"
    type = string
    # default = "vpc-067f3ab097282bc4d"
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["public-*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["private-*"]
  }
}

locals {
    department = "marketing"
}

resource "aws_instance" "public" {
  ami                         = "ami-04c913012f8977029"
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.public.ids[0] #Public Subnet ID, e.g. subnet-xxxxxxxxxxx.
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
 
  tags = {
    Name = "${var.name}-ec2"
    Department = local.department
  }
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "${var.name}-sg"
  description = "Allow SSH inbound"
  vpc_id      = var.vpc_id #VPC ID (Same VPC as your EC2 subnet above), e.g. vpc-xxxxxxxxxxx
  lifecycle {
    create_before_destroy = true
  }
 
  tags = {
    Department = local.department
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

output "public_ip" {
    value = aws_instance.public.public_ip
}

output "public_dns" {
    value = aws_instance.public.public_dns
}

output "public_subnet_ids" {
    value = data.aws_subnets.public.ids
}

output "private_subnet_ids" {
    value = data.aws_subnets.private.ids
}