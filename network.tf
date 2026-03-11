# ------------------------
# VPC
# ------------------------

resource "aws_vpc" "vpc" {
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name    = "${var.project}-${var.environment}-vpc"
    Project = var.project
    Env     = var.environment
  }
}

# ------------------------
# Public-Subnet
# ------------------------

# NAT/ALB Subnet Public-1a
resource "aws_subnet" "nat_public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-nat-public-1a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

# NAT/ALB Subnet Public-1c
resource "aws_subnet" "nat_public_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-nat-public-1c"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}


# ------------------------
# Private-Subnet
# ------------------------

# App-server Subnet Private-1a
resource "aws_subnet" "app_private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-app-private-1a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

# App-server Subnet Private-1c
resource "aws_subnet" "app_private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-app-private-1c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

# DB-server Subnet Private-1a
resource "aws_subnet" "db_private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-db-private-1a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

# DB-server Subnet Private-1c
resource "aws_subnet" "db_private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.environment}-db-private-1c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}
