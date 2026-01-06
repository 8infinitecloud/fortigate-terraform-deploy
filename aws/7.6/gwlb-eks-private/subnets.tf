# Force recreation by adding lifecycle rule
resource "aws_subnet" "eks_private_subnet_az1" {
  vpc_id            = var.customer_vpc_id
  cidr_block        = var.eks_private_subnet_az1_cidr
  availability_zone = var.az1
  
  tags = {
    Name = "EKS Private Subnet AZ1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "eks_private_subnet_az2" {
  vpc_id            = var.customer_vpc_id
  cidr_block        = var.eks_private_subnet_az2_cidr
  availability_zone = var.az2
  
  tags = {
    Name = "EKS Private Subnet AZ2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
  }
}
