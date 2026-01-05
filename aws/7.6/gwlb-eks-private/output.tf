
output "EKSClusterName" {
  value = module.eks_cluster.cluster_name
}

output "EKSClusterEndpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "EKSClusterArn" {
  value = module.eks_cluster.cluster_arn
}

output "CustomerVPCId" {
  value = var.customer_vpc_id
}

output "CustomerPrivateSubnetAZ1" {
  value = var.customer_private_subnet_az1_id
}

output "CustomerPrivateSubnetAZ2" {
  value = var.customer_private_subnet_az2_id
}

output "NATGatewayAZ1" {
  value = aws_nat_gateway.nat_gw_az1.id
}

output "NATGatewayAZ2" {
  value = aws_nat_gateway.nat_gw_az2.id
}
