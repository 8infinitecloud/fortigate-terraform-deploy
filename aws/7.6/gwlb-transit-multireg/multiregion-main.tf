# Multiregion Module
module "multiregion" {
  source = "./multiregion"
  
  # Pass variables to module
  enable_multiregion = var.enable_multiregion
  secondary_region   = var.secondary_region
  
  # Pass primary region variables for cross-region routing
  vpccidr    = var.vpccidr
  csvpccidr  = var.csvpccidr
  cs2vpccidr = var.cs2vpccidr
  
  # Pass GWLB service name for cross-region inspection
  primary_gwlb_service_name = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  
  providers = {
    aws.secondary = aws.secondary
  }
  
  # Dependencies
  depends_on = [
    aws_ec2_transit_gateway.terraform-tgwy,
    aws_ec2_transit_gateway_route_table.tgwy-fgt-route,
    aws_vpc_endpoint_service.fgtgwlbservice
  ]
}

# Secondary region provider
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
