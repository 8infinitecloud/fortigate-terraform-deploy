
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

# Multiregion Outputs
output "multiregion_enabled" {
  description = "Whether multiregion is enabled"
  value       = module.multiregion.multiregion_enabled
}

output "secondary_region" {
  description = "Secondary region name"
  value       = module.multiregion.secondary_region
}

output "secondary_vpc_id" {
  description = "Secondary VPC ID"
  value       = module.multiregion.secondary_vpc_id
}

output "secondary_tgw_id" {
  description = "Secondary Transit Gateway ID"
  value       = module.multiregion.secondary_tgw_id
}

output "tgw_peering_id" {
  description = "TGW Peering Connection ID"
  value       = module.multiregion.tgw_peering_id
}
