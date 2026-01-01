
output "FGTPublicIP" {
  value = aws_eip.FGTPublicIP.public_ip
}

output "FGT2PublicIP" {
  value = aws_eip.FGT2PublicIP.public_ip
}

output "Username" {
  value = "admin"
}

output "FGT1-Password" {
  value = aws_instance.fgtvm.id
}

output "FGT2-Password" {
  value = aws_instance.fgtvm2.id
}

output "LoadBalancerPrivateIP" {
  value = data.aws_network_interface.vpcendpointip.private_ip
}

output "LoadBalancerPrivateIP2" {
  value = data.aws_network_interface.vpcendpointipaz2.private_ip
}

output "CustomerVPC" {
  value = aws_vpc.customer-vpc.id
}

output "FGTVPC" {
  value = aws_vpc.fgtvm-vpc.id
}

# Multiregion Outputs (conditional)
output "multiregion_enabled" {
  description = "Whether multiregion is enabled"
  value       = var.enable_multiregion
}

output "secondary_region" {
  description = "Secondary region name"
  value       = var.enable_multiregion && length(module.multiregion) > 0 ? module.multiregion[0].secondary_region : null
}

output "secondary_vpc_id" {
  description = "Secondary VPC ID"
  value       = var.enable_multiregion && length(module.multiregion) > 0 ? module.multiregion[0].secondary_vpc_id : null
}

output "secondary_tgw_id" {
  description = "Secondary Transit Gateway ID"
  value       = var.enable_multiregion && length(module.multiregion) > 0 ? module.multiregion[0].secondary_tgw_id : null
}

output "tgw_peering_id" {
  description = "TGW Peering Connection ID"
  value       = var.enable_multiregion && length(module.multiregion) > 0 ? module.multiregion[0].tgw_peering_id : null
}
