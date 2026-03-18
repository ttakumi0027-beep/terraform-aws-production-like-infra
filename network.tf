
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
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-public-1a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

# NAT/ALB Subnet Public-1c
resource "aws_subnet" "public_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-public-1c"
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


# ------------------------
# VPC Endpnt
# ------------------------
variable "vpc_endpoints" {
  type    = list(string)
  default = ["ssm", "ssmmessages", "ec2messages"]
}



# ------------------------
# Route Table
# ------------------------

# Public-1a Route Table for NAT/ALB
resource "aws_route_table" "public_rt_1a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-public-1a-rt"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

# Public-1c Route Table for NAT/ALB
resource "aws_route_table" "public_rt_1c" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-public-1c-rt"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_route_table_association" "public_rt_assoc_1a" {
  route_table_id = aws_route_table.public_rt_1a.id
  subnet_id      = aws_subnet.public_subnet_1a.id
}

resource "aws_route_table_association" "public_rt_assoc_1c" {
  route_table_id = aws_route_table.public_rt_1c.id
  subnet_id      = aws_subnet.public_subnet_1c.id
}

# App Private Route Table 1a
resource "aws_route_table" "app_private_rt_1a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-app-private-rt-1a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_route_table_association" "app_private_rt_assoc_1a" {
  route_table_id = aws_route_table.app_private_rt_1a.id
  subnet_id      = aws_subnet.app_private_subnet_1a.id
}

# App Private Route Table 1c
resource "aws_route_table" "app_private_rt_1c" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-app-private-rt-1c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_route_table_association" "app_private_rt_assoc_1c" {
  route_table_id = aws_route_table.app_private_rt_1c.id
  subnet_id      = aws_subnet.app_private_subnet_1c.id
}

# Private Route Table for DB
resource "aws_route_table" "db_private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-db-private-rt"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_route_table_association" "db_private_rt_1a" {
  route_table_id = aws_route_table.db_private_rt.id
  subnet_id      = aws_subnet.db_private_subnet_1a.id
}

resource "aws_route_table_association" "db_private_rt_1c" {
  route_table_id = aws_route_table.db_private_rt.id
  subnet_id      = aws_subnet.db_private_subnet_1c.id
}

# ------------------------
# Internet Gateway
# ------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-igw"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_route" "public_rt_igw_1a" {
  route_table_id         = aws_route_table.public_rt_1a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public_rt_igw_1c" {
  route_table_id         = aws_route_table.public_rt_1c.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ------------------------
# Nat Gateway
# ------------------------

resource "aws_eip" "nat_eip_1a" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-${var.environment}-nat-eip-1a"
  }
}

resource "aws_nat_gateway" "nat_gw_1a" {
  allocation_id = aws_eip.nat_eip_1a.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name    = "${var.project}-${var.environment}-nat-gw-1a"
    Project = var.project
    Env     = var.environment
  }

}

resource "aws_route" "app_private_nat_1a" {
  route_table_id         = aws_route_table.app_private_rt_1a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_1a.id
}

resource "aws_eip" "nat_eip_1c" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-${var.environment}-nat-eip-1c"
  }
}

resource "aws_nat_gateway" "nat_gw_1c" {
  allocation_id = aws_eip.nat_eip_1c.id
  subnet_id     = aws_subnet.public_subnet_1c.id

  tags = {
    Name    = "${var.project}-${var.environment}-nat-gw-1c"
    Project = var.project
    Env     = var.environment
  }

}

resource "aws_route" "app_private_nat_1c" {
  route_table_id         = aws_route_table.app_private_rt_1c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_1c.id
}
