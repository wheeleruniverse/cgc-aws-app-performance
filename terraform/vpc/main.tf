terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

// _________________________________________________________
// variables

locals {
  cidr_anywhere = ["0.0.0.0/0"]
}

variable "cidr" {
  default = {
    private = "10.0.0.224/27"
    public  = "10.0.0.0/27"
    vpc     = "10.0.0.0/24"
  }
  description = "cidr blocks"
  type = object({
    private = string
    public  = string
    vpc     = string
  })
}

variable "prefix" {
  default     = "wheeler-cgc2106-"
  description = "prefix name"
  type        = string
}

variable "project" {
  default     = "CloudGuruChallenge_21.06"
  description = "project name"
  type        = string
}

// _________________________________________________________
// resources

resource "aws_eip" "ip" {
  tags = {
    Name    = "${var.prefix}eip"
    Project = var.project
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.prefix}igw"
    Project = var.project
  }
}

resource "aws_nat_gateway" "ngw" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.private.id

  tags = {
    Name    = "${var.prefix}ngw"
    Project = var.project
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = local.cidr_anywhere[0]
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name    = "${var.prefix}private-rt"
    Project = var.project
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = local.cidr_anywhere[0]
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.prefix}public-rt"
    Project = var.project
  }
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private.id
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_security_group" "private_sg" {
  description = "${var.prefix}private-sg"
  name        = "${var.prefix}private-sg"
  vpc_id      = aws_vpc.vpc.id

  egress {
    cidr_blocks = local.cidr_anywhere
    description = "egress all from anywhere"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    description = "ingress postgres from vpc"
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
  }

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    description = "ingress redis from vpc"
    from_port   = 6379
    protocol    = "tcp"
    to_port     = 6379
  }

  tags = {
    Name    = "${var.prefix}private-sg"
    Project = var.project
  }
}

resource "aws_security_group" "public_sg" {
  description = "${var.prefix}public-sg"
  name        = "${var.prefix}public-sg"
  vpc_id      = aws_vpc.vpc.id

  egress {
    cidr_blocks = local.cidr_anywhere
    description = "egress all from anywhere"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = local.cidr_anywhere
    description = "ingress https from anywhere"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  ingress {
    cidr_blocks = local.cidr_anywhere
    description = "ingress ssh from anywhere"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  tags = {
    Name    = "${var.prefix}public-sg"
    Project = var.project
  }
}

resource "aws_subnet" "private" {
  cidr_block = var.cidr.private
  vpc_id     = aws_vpc.vpc.id

  tags = {
    Name    = "${var.prefix}private-1"
    Project = var.project
  }
}

resource "aws_subnet" "public" {
  cidr_block = var.cidr.public
  vpc_id     = aws_vpc.vpc.id

  tags = {
    Name    = "${var.prefix}public-1"
    Project = var.project
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr.vpc

  tags = {
    Name    = "${var.prefix}vpc"
    Project = var.project
  }
}
