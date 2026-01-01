# Secondary Transit Gateway
resource "aws_ec2_transit_gateway" "secondary_tgw" {
  count                           = var.enable_multiregion ? 1 : 0
  provider                        = aws.secondary
  description                     = "Secondary Transit Gateway for multiregion"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  
  tags = {
    Name = "secondary-tgw-${var.secondary_region}"
  }
}

# Route Table for secondary TGW
resource "aws_ec2_transit_gateway_route_table" "secondary_tgw_route_table" {
  count              = var.enable_multiregion ? 1 : 0
  provider           = aws.secondary
  transit_gateway_id = aws_ec2_transit_gateway.secondary_tgw[0].id
  
  tags = {
    Name = "secondary-tgw-route-table"
  }
}

# VPC attachment to secondary TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "secondary_vpc_attachment" {
  count                                           = var.enable_multiregion ? 1 : 0
  provider                                        = aws.secondary
  subnet_ids                                      = [
    aws_subnet.secondary_private_subnet_az1[0].id,
    aws_subnet.secondary_private_subnet_az2[0].id
  ]
  transit_gateway_id                              = aws_ec2_transit_gateway.secondary_tgw[0].id
  vpc_id                                          = aws_vpc.secondary_vpc[0].id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  tags = {
    Name = "secondary-vpc-attachment"
  }
}

# Route table association
resource "aws_ec2_transit_gateway_route_table_association" "secondary_vpc_association" {
  count                          = var.enable_multiregion ? 1 : 0
  provider                       = aws.secondary
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.secondary_vpc_attachment[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.secondary_tgw_route_table[0].id
}
