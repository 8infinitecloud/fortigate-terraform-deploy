# EKS Cluster Module
module "eks_cluster" {
  source = "./modules/eks"

  cluster_name           = var.cluster_name
  kubernetes_version     = var.kubernetes_version
  vpc_id                 = var.customer_vpc_id
  private_subnet_ids     = [aws_subnet.eks_private_subnet_az1.id, aws_subnet.eks_private_subnet_az2.id]
  node_instance_types    = var.node_instance_types
  desired_capacity       = var.desired_capacity
  max_capacity           = var.max_capacity
  min_capacity           = var.min_capacity
  endpoint_public_access = var.endpoint_public_access
  public_access_cidrs    = var.public_access_cidrs
  eks_admin_users        = var.eks_admin_users

  tags = {
    Environment = "demo"
    Project     = "fortigate-gwlb-eks"
  }
}

# NAT Gateway for private subnets (single NAT for both AZs)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.customer_public_subnet_az1_id

  tags = {
    Name = "NAT Gateway"
  }
}

# Route table for private subnets with NAT Gateway
resource "aws_route_table" "csprivate_rt" {
  vpc_id = var.customer_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Customer Private Route Table"
  }
}

resource "aws_route_table_association" "csprivate_rta_az1" {
  subnet_id      = aws_subnet.eks_private_subnet_az1.id
  route_table_id = aws_route_table.csprivate_rt.id
}

resource "aws_route_table_association" "csprivate_rta_az2" {
  subnet_id      = aws_subnet.eks_private_subnet_az2.id
  route_table_id = aws_route_table.csprivate_rt.id
}
