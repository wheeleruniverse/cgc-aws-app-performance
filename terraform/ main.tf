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
  region  = "us-west-2"
}

module "elasticache-redis" {
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster
  // https://registry.terraform.io/modules/cloudposse/elasticache-redis/aws/latest
  source  = "cloudposse/elasticache-redis/aws"
  version = "0.39.0"

  delimiter   = "-"
  enabled     = true
  environment = "prd"
  name        = "redis"
  namespace   = "CloudGuruChallenge_21.06"
  vpc_id      = "vpc-177feb6f"
}

resource "aws_db_instance" "postgres" {
  allocated_storage   = 10
  engine              = "postgres"
  engine_version      = "13.2"
  instance_class      = "db.t3.micro"
  name                = "postgres"
  password            = "foobarbaz"
  skip_final_snapshot = true
  username            = "foo"

  tags = {
    Project = "CloudGuruChallenge_21.06"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "CloudGuruChallenge_21.06"
  }
}


