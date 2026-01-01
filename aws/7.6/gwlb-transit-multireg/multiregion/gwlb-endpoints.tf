# GWLB Endpoint in secondary region pointing to primary GWLB
resource "aws_vpc_endpoint" "secondary_gwlb_endpoint" {
  count             = var.enable_multiregion ? 1 : 0
  provider          = aws.secondary
  service_name      = data.aws_vpc_endpoint_service.primary_gwlb_service[0].service_name
  subnet_ids        = [aws_subnet.secondary_public_subnet_az1[0].id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = aws_vpc.secondary_vpc[0].id
  
  tags = {
    Name = "secondary-gwlb-endpoint"
  }
}

# Data source to get primary GWLB service
data "aws_vpc_endpoint_service" "primary_gwlb_service" {
  count        = var.enable_multiregion ? 1 : 0
  provider     = aws.secondary
  service_name = var.primary_gwlb_service_name
}

# GWLB Endpoint for second AZ
resource "aws_vpc_endpoint" "secondary_gwlb_endpoint_az2" {
  count             = var.enable_multiregion ? 1 : 0
  provider          = aws.secondary
  service_name      = data.aws_vpc_endpoint_service.primary_gwlb_service[0].service_name
  subnet_ids        = [aws_subnet.secondary_public_subnet_az2[0].id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = aws_vpc.secondary_vpc[0].id
  
  tags = {
    Name = "secondary-gwlb-endpoint-az2"
  }
}
