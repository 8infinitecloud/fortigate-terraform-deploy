# Security Groups for secondary VPC
resource "aws_security_group" "secondary_public_sg" {
  count       = var.enable_multiregion ? 1 : 0
  provider    = aws.secondary
  name        = "secondary-public-sg"
  description = "Security group for public subnets in secondary region"
  vpc_id      = aws_vpc.secondary_vpc[0].id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  # Allow traffic from primary region VPCs
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpccidr, var.csvpccidr, var.cs2vpccidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secondary-public-sg"
  }
}

resource "aws_security_group" "secondary_private_sg" {
  count       = var.enable_multiregion ? 1 : 0
  provider    = aws.secondary
  name        = "secondary-private-sg"
  description = "Security group for private subnets in secondary region"
  vpc_id      = aws_vpc.secondary_vpc[0].id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  # Allow traffic from primary region VPCs
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpccidr, var.csvpccidr, var.cs2vpccidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secondary-private-sg"
  }
}
