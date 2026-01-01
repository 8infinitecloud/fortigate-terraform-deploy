# Route Tables for secondary VPC

# Public Route Table
resource "aws_route_table" "secondary_public_rt" {
  count    = var.enable_multiregion ? 1 : 0
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc[0].id
  
  tags = {
    Name = "secondary-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "secondary_private_rt" {
  count    = var.enable_multiregion ? 1 : 0
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc[0].id
  
  tags = {
    Name = "secondary-private-rt"
  }
}

# Public route to Internet Gateway
resource "aws_route" "secondary_public_internet_route" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_public_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.secondary_igw[0].id
}

# Private route to GWLB Endpoint for inspection (instead of NAT Gateway)
resource "aws_route" "secondary_private_inspection_route" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_private_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.secondary_gwlb_endpoint[0].id
  
  depends_on = [aws_vpc_endpoint.secondary_gwlb_endpoint]
}

# Public route for return traffic via GWLB endpoint
resource "aws_route" "secondary_public_inspection_route" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_public_rt[0].id
  destination_cidr_block = var.secondary_private_subnet_az1
  vpc_endpoint_id        = aws_vpc_endpoint.secondary_gwlb_endpoint[0].id
  
  depends_on = [aws_vpc_endpoint.secondary_gwlb_endpoint]
}

resource "aws_route" "secondary_public_inspection_route_az2" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_public_rt[0].id
  destination_cidr_block = var.secondary_private_subnet_az2
  vpc_endpoint_id        = aws_vpc_endpoint.secondary_gwlb_endpoint_az2[0].id
  
  depends_on = [aws_vpc_endpoint.secondary_gwlb_endpoint_az2]
}

# Routes to primary region via TGW
resource "aws_route" "secondary_to_primary_fgt_vpc" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_private_rt[0].id
  destination_cidr_block = var.vpccidr
  transit_gateway_id     = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

resource "aws_route" "secondary_to_primary_customer1_vpc" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_private_rt[0].id
  destination_cidr_block = var.csvpccidr
  transit_gateway_id     = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

resource "aws_route" "secondary_to_primary_customer2_vpc" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_private_rt[0].id
  destination_cidr_block = var.cs2vpccidr
  transit_gateway_id     = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

# GWLB Endpoint Route Table
resource "aws_route_table" "secondary_gwlb_rt" {
  count    = var.enable_multiregion ? 1 : 0
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc[0].id
  
  tags = {
    Name = "secondary-gwlb-rt"
  }
}

# Route from GWLB endpoint to Internet Gateway
resource "aws_route" "secondary_gwlb_internet_route" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_gwlb_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.secondary_igw[0].id
}

# Route from GWLB endpoint to private subnets via TGW (for cross-region traffic)
resource "aws_route" "secondary_gwlb_to_tgw" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_gwlb_rt[0].id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

# Associate GWLB subnets with GWLB route table
resource "aws_route_table_association" "secondary_gwlb_subnet_az1_association" {
  count          = var.enable_multiregion ? 1 : 0
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_public_subnet_az1[0].id
  route_table_id = aws_route_table.secondary_gwlb_rt[0].id
}

resource "aws_route_table_association" "secondary_gwlb_subnet_az2_association" {
  count          = var.enable_multiregion ? 1 : 0
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_public_subnet_az2[0].id
  route_table_id = aws_route_table.secondary_gwlb_rt[0].id
}

resource "aws_route_table_association" "secondary_private_subnet_az1_association" {
  count          = var.enable_multiregion ? 1 : 0
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_private_subnet_az1[0].id
  route_table_id = aws_route_table.secondary_private_rt[0].id
}

resource "aws_route_table_association" "secondary_private_subnet_az2_association" {
  count          = var.enable_multiregion ? 1 : 0
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_private_subnet_az2[0].id
  route_table_id = aws_route_table.secondary_private_rt[0].id
}
