# EKS Cluster Module
module "eks_cluster" {
  source = "./modules/eks"

  cluster_name           = var.cluster_name
  kubernetes_version     = var.kubernetes_version
  vpc_id                 = var.customer_vpc_id
  private_subnet_ids     = [var.customer_private_subnet_az1_id, var.customer_private_subnet_az2_id]
  node_instance_types    = var.node_instance_types
  desired_capacity       = var.desired_capacity
  max_capacity           = var.max_capacity
  min_capacity           = var.min_capacity
  endpoint_public_access = var.endpoint_public_access
  public_access_cidrs    = var.public_access_cidrs

  tags = {
    Environment = "demo"
    Project     = "fortigate-gwlb-eks"
  }
}

# NAT Gateway for private subnets
resource "aws_eip" "nat_eip_az1" {
  domain = "vpc"
  tags = {
    Name = "NAT Gateway EIP AZ1"
  }
}

resource "aws_eip" "nat_eip_az2" {
  domain = "vpc"
  tags = {
    Name = "NAT Gateway EIP AZ2"
  }
}

resource "aws_nat_gateway" "nat_gw_az1" {
  allocation_id = aws_eip.nat_eip_az1.id
  subnet_id     = var.customer_public_subnet_az1_id

  tags = {
    Name = "NAT Gateway AZ1"
  }
}

resource "aws_nat_gateway" "nat_gw_az2" {
  allocation_id = aws_eip.nat_eip_az2.id
  subnet_id     = var.customer_public_subnet_az2_id

  tags = {
    Name = "NAT Gateway AZ2"
  }
}

# Route tables for private subnets with NAT Gateway
resource "aws_route_table" "csprivate_rt_az1" {
  vpc_id = var.customer_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az1.id
  }

  tags = {
    Name = "Customer Private Route Table AZ1"
  }
}

resource "aws_route_table" "csprivate_rt_az2" {
  vpc_id = var.customer_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az2.id
  }

  tags = {
    Name = "Customer Private Route Table AZ2"
  }
}

resource "aws_route_table_association" "csprivate_rta_az1" {
  subnet_id      = var.customer_private_subnet_az1_id
  route_table_id = aws_route_table.csprivate_rt_az1.id
}

resource "aws_route_table_association" "csprivate_rta_az2" {
  subnet_id      = var.customer_private_subnet_az2_id
  route_table_id = aws_route_table.csprivate_rt_az2.id
}
