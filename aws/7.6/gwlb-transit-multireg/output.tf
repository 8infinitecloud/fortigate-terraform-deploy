
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

output "architecture_summary" {
  description = "Architecture deployment summary"
  value = var.enable_multiregion ? "Multi-Region: Primary (us-east-1) + Secondary (${var.secondary_region}) with cross-region inspection" : "Single Region: ${var.region} only"
}

output "secondary_region" {
  description = "Secondary region name"
  value       = var.enable_multiregion && length(module.multiregion) > 0 ? module.multiregion[0].secondary_region : "Not deployed"
}

output "secondary_vpc_id" {
  description = "Secondary VPC ID"
  value       = var.enable_multiregion && length(module.multiregion) > 0 ? module.multiregion[0].secondary_vpc_id : "Not deployed"
}

output "secondary_tgw_id" {
  description = "Secondary Transit Gateway ID"
  value       = var.enable_multiregion && length(module.multiregion) > 0 ? module.multiregion[0].secondary_tgw_id : "Not deployed"
}

output "tgw_peering_id" {
  description = "TGW Peering Connection ID"
  value       = var.enable_multiregion && length(module.multiregion) > 0 ? module.multiregion[0].tgw_peering_id : "Not deployed"
}

output "inspection_flow" {
  description = "Traffic inspection flow"
  value = var.enable_multiregion ? "All traffic from ${var.secondary_region} inspected by FortiGates in ${var.region}" : "All traffic inspected locally in ${var.region}"
}
