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

variable "public_key" {
  description = "ssh public key"
  sensitive   = true
  type        = string
}

variable "sg" {
  description = "security group ids"
  type = object({
    private = list(string)
    public  = list(string)
  })
}

variable "subnet" {
  description = "subnet ids"
  type = object({
    private = list(string)
    public  = list(string)
  })
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

// _________________________________________________________
// resources

resource "aws_db_instance" "db" {
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.dsg.name
  engine                 = "postgres"
  engine_version         = "13.2"
  identifier             = "${var.prefix}db"
  instance_class         = var.type.db
  max_allocated_storage  = 100
  name                   = "postgres"
  password               = var.password
  skip_final_snapshot    = true
  storage_type           = "gp2"
  username               = "master"
  vpc_security_group_ids = var.sg.private

  tags = {
    Name    = "${var.prefix}db"
    Project = var.project
  }
}

resource "aws_db_subnet_group" "dsg" {
  name       = "${var.prefix}dsg"
  subnet_ids = var.subnet.private

  tags = {
    Name    = "${var.prefix}dsg"
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
  security_group_ids   = var.sg.private
  subnet_group_name    = aws_elasticache_subnet_group.csg.name

  tags = {
    Name    = "${var.prefix}cache"
    Project = var.project
  }
}

resource "aws_elasticache_subnet_group" "csg" {
  name       = "${var.prefix}csg"
  subnet_ids = var.subnet.private

  tags = {
    Name    = "${var.prefix}csg"
    Project = var.project
  }
}

resource "aws_instance" "server" {
  depends_on = [
    aws_db_instance.db,
    aws_elasticache_cluster.cache
  ]

  ami                         = var.ami
  associate_public_ip_address = true
  instance_type               = var.type.ec2
  key_name                    = aws_key_pair.keypair.key_name
  subnet_id                   = random_shuffle.public_subnet.result[0]
  user_data                   = file("user-data.sh")
  vpc_security_group_ids      = var.sg.public

  tags = {
    Name    = "${var.prefix}server"
    Project = var.project
  }
}

resource "aws_key_pair" "keypair" {
  key_name   = "${var.prefix}keypair"
  public_key = var.public_key

  tags = {
    Name    = "${var.prefix}keypair"
    Project = var.project
  }
}

resource "random_shuffle" "public_subnet" {
  input        = var.subnet.public
  result_count = 1
}

// _________________________________________________________
// outputs

output "server_public_ip" {
  value = aws_instance.server.public_ip
}