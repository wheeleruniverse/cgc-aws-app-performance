
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

variable "public_key" {
  description = "ssh public key"
  sensitive   = true
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

// _________________________________________________________
// resources

resource "aws_db_instance" "db" {
  allocated_storage      = 20
  db_subnet_group_name   = aws_subnet.private.id
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
  vpc_security_group_ids = [aws_security_group.private_sg.id]

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
  security_group_ids   = [aws_security_group.private_sg.id]
  subnet_group_name    = aws_subnet.private.id

  tags = {
    Name    = "${var.prefix}cache"
    Project = var.project
  }
}

resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.type.ec2
  key_name               = aws_key_pair.keypair.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

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
