# Multiregion Outputs
output "multiregion_enabled" {
  description = "Whether multiregion is enabled"
  value       = var.enable_multiregion
}

output "secondary_region" {
  description = "Secondary region name"
  value       = var.enable_multiregion ? var.secondary_region : null
}

output "secondary_vpc_id" {
  description = "Secondary VPC ID"
  value       = var.enable_multiregion ? aws_vpc.secondary_vpc[0].id : null
}

output "secondary_vpc_cidr" {
  description = "Secondary VPC CIDR"
  value       = var.enable_multiregion ? aws_vpc.secondary_vpc[0].cidr_block : null
}

output "secondary_tgw_id" {
  description = "Secondary Transit Gateway ID"
  value       = var.enable_multiregion ? aws_ec2_transit_gateway.secondary_tgw[0].id : null
}

output "tgw_peering_id" {
  description = "TGW Peering Connection ID"
  value       = var.enable_multiregion ? aws_ec2_transit_gateway_peering_attachment.primary_to_secondary[0].id : null
}

output "secondary_public_subnets" {
  description = "Secondary region public subnet IDs"
  value = var.enable_multiregion ? [
    aws_subnet.secondary_public_subnet_az1[0].id,
    aws_subnet.secondary_public_subnet_az2[0].id
  ] : []
}

output "secondary_private_subnets" {
  description = "Secondary region private subnet IDs"
  value = var.enable_multiregion ? [
    aws_subnet.secondary_private_subnet_az1[0].id,
    aws_subnet.secondary_private_subnet_az2[0].id
  ] : []
}

output "secondary_gwlb_endpoints" {
  description = "Secondary region GWLB endpoint IDs (not supported cross-region)"
  value       = "Cross-region GWLB endpoints not supported by AWS"
}

output "inspection_enabled" {
  description = "Whether traffic inspection is enabled in secondary region"
  value       = var.enable_multiregion ? "Via Transit Gateway to primary region" : "Not applicable"
}
