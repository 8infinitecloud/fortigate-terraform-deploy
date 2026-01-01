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

# Private route to Transit Gateway (for cross-region inspection)
resource "aws_route" "secondary_private_to_tgw" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_private_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

# Routes to primary region via TGW (hardcoded CIDRs)
resource "aws_route" "secondary_to_primary_fgt_vpc" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_private_rt[0].id
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

resource "aws_route" "secondary_to_primary_customer1_vpc" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_private_rt[0].id
  destination_cidr_block = "20.1.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

resource "aws_route" "secondary_to_primary_customer2_vpc" {
  count                  = var.enable_multiregion ? 1 : 0
  provider               = aws.secondary
  route_table_id         = aws_route_table.secondary_private_rt[0].id
  destination_cidr_block = "30.1.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

# Route Table Associations
resource "aws_route_table_association" "secondary_public_subnet_az1_association" {
  count          = var.enable_multiregion ? 1 : 0
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_public_subnet_az1[0].id
  route_table_id = aws_route_table.secondary_public_rt[0].id
}

resource "aws_route_table_association" "secondary_public_subnet_az2_association" {
  count          = var.enable_multiregion ? 1 : 0
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_public_subnet_az2[0].id
  route_table_id = aws_route_table.secondary_public_rt[0].id
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
