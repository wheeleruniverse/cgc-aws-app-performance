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

variable "ami" {
  default     = "ami-0aeeebd8d2ab47354" // us-east-1
  description = "ami id"
  type        = string
}

variable "password" {
  description = "password"
  sensitive   = true
  type        = string
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

variable "type" {
  default = {
    cache = "cache.t3.micro"
    db    = "db.t3.micro"
    ec2   = "t3.micro"
  }
  description = "instance type"
  type = object({
    cache = string
    db    = string
    ec2   = string
  })
}

resource "aws_db_instance" "db" {
  allocated_storage     = 20
  engine                = "postgres"
  engine_version        = "13.2"
  identifier            = "${var.prefix}db"
  instance_class        = var.type.db
  max_allocated_storage = 100
  name                  = "postgres"
  password              = var.password
  skip_final_snapshot   = true
  storage_type          = "gp2"
  username              = "master"

  tags = {
    Name    = "${var.prefix}db"
    Project = var.project
  }
}

resource "aws_elasticache_cluster" "cache" {
  cluster_id           = "${var.prefix}cache"
  engine               = "redis"
  engine_version       = "6.x"
  node_type            = var.type.cache
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"

  tags = {
    Name    = "${var.prefix}cache"
    Project = var.project
  }
}

resource "aws_instance" "server" {
  ami           = var.ami
  instance_type = var.type.ec2

  tags = {
    Name    = "${var.prefix}server"
    Project = var.project
  }
}


