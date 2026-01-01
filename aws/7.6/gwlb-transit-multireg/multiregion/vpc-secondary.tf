# Secondary VPC
resource "aws_vpc" "secondary_vpc" {
  count                = var.enable_multiregion ? 1 : 0
  provider             = aws.secondary
  cidr_block           = var.secondary_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  
  tags = {
    Name = "secondary-vpc-${var.secondary_region}"
  }
}

# Internet Gateway for secondary VPC
resource "aws_internet_gateway" "secondary_igw" {
  count    = var.enable_multiregion ? 1 : 0
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc[0].id
  
  tags = {
    Name = "secondary-igw-${var.secondary_region}"
  }
}

# Public Subnets
resource "aws_subnet" "secondary_public_subnet_az1" {
  count                   = var.enable_multiregion ? 1 : 0
  provider                = aws.secondary
  vpc_id                  = aws_vpc.secondary_vpc[0].id
  cidr_block              = var.secondary_public_subnet_az1
  availability_zone       = var.secondary_az1
  map_public_ip_on_launch = true
  
  tags = {
    Name = "secondary-public-subnet-az1"
  }
}

resource "aws_subnet" "secondary_public_subnet_az2" {
  count                   = var.enable_multiregion ? 1 : 0
  provider                = aws.secondary
  vpc_id                  = aws_vpc.secondary_vpc[0].id
  cidr_block              = var.secondary_public_subnet_az2
  availability_zone       = var.secondary_az2
  map_public_ip_on_launch = true
  
  tags = {
    Name = "secondary-public-subnet-az2"
  }
}

# Private Subnets
resource "aws_subnet" "secondary_private_subnet_az1" {
  count             = var.enable_multiregion ? 1 : 0
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary_vpc[0].id
  cidr_block        = var.secondary_private_subnet_az1
  availability_zone = var.secondary_az1
  
  tags = {
    Name = "secondary-private-subnet-az1"
  }
}

resource "aws_subnet" "secondary_private_subnet_az2" {
  count             = var.enable_multiregion ? 1 : 0
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary_vpc[0].id
  cidr_block        = var.secondary_private_subnet_az2
  availability_zone = var.secondary_az2
  
  tags = {
    Name = "secondary-private-subnet-az2"
  }
}

# NAT Gateway for private subnets
resource "aws_eip" "secondary_nat_eip" {
  count    = var.enable_multiregion ? 1 : 0
  provider = aws.secondary
  domain   = "vpc"
  
  tags = {
    Name = "secondary-nat-eip"
  }
}

resource "aws_nat_gateway" "secondary_nat_gw" {
  count         = var.enable_multiregion ? 1 : 0
  provider      = aws.secondary
  allocation_id = aws_eip.secondary_nat_eip[0].id
  subnet_id     = aws_subnet.secondary_public_subnet_az1[0].id
  
  tags = {
    Name = "secondary-nat-gw"
  }
  
  depends_on = [aws_internet_gateway.secondary_igw]
}
