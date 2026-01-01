# TGW Peering Connection (Primary to Secondary)
resource "aws_ec2_transit_gateway_peering_attachment" "primary_to_secondary" {
  count               = var.enable_multiregion ? 1 : 0
  peer_region         = var.secondary_region
  peer_transit_gateway_id = aws_ec2_transit_gateway.secondary_tgw[0].id
  transit_gateway_id  = aws_ec2_transit_gateway.terraform-tgwy.id
  
  tags = {
    Name = "tgw-peering-primary-to-secondary"
  }
}

# Accept peering connection in secondary region
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "secondary_accepter" {
  count                         = var.enable_multiregion ? 1 : 0
  provider                      = aws.secondary
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.primary_to_secondary[0].id
  
  tags = {
    Name = "tgw-peering-accepter-secondary"
  }
}

# Route from primary to secondary VPC
resource "aws_ec2_transit_gateway_route" "primary_to_secondary_route" {
  count                          = var.enable_multiregion ? 1 : 0
  destination_cidr_block         = var.secondary_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.primary_to_secondary[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwy-fgt-route.id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

# Route from secondary to primary VPCs
resource "aws_ec2_transit_gateway_route" "secondary_to_primary_fgt" {
  count                          = var.enable_multiregion ? 1 : 0
  provider                       = aws.secondary
  destination_cidr_block         = var.vpccidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.primary_to_secondary[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.secondary_tgw_route_table[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

resource "aws_ec2_transit_gateway_route" "secondary_to_primary_customer1" {
  count                          = var.enable_multiregion ? 1 : 0
  provider                       = aws.secondary
  destination_cidr_block         = var.csvpccidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.primary_to_secondary[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.secondary_tgw_route_table[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}

resource "aws_ec2_transit_gateway_route" "secondary_to_primary_customer2" {
  count                          = var.enable_multiregion ? 1 : 0
  provider                       = aws.secondary
  destination_cidr_block         = var.cs2vpccidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.primary_to_secondary[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.secondary_tgw_route_table[0].id
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter]
}
