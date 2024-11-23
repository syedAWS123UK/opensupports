provider "aws" {
  region = "us-east-1"
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"
  name    = "opensupports-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Security Groups
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "opensupports" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t3.micro"
  key_name      = "opensupportkeypair"

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Name = "opensupports-instance"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "opensupports_bucket" {
  bucket = "opensupports-${random_id.bucket_id.hex}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

# RDS MySQL
resource "aws_db_instance" "opensupports_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "opensupports"
  username             = "admin"
  password             = "securepassword"
  publicly_accessible  = false
  
# Enable encryption for RDS
  storage_encrypted = true
  kms_key_id        = "aws/kms"  # specify a custom KMS key if desired

  # Enable backup retention
  backup_retention_period = 7
}

# EC2 Instance with IAM Role
resource "aws_instance" "opensupports" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t3.micro"
  key_name      = "opensupportkeypair"

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = module.vpc.public_subnets[0]

  iam_instance_profile   = aws_iam_instance_profile.ec2_role.name
  associate_public_ip_address = true

  tags = {
    Name = "opensupports-instance"
  }
}
