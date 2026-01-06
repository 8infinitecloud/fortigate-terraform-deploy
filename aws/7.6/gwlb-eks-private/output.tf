
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

output "EKSPrivateSubnetAZ1" {
  value = aws_subnet.eks_private_subnet_az1.id
}

output "EKSPrivateSubnetAZ2" {
  value = aws_subnet.eks_private_subnet_az2.id
}

output "IngressPrivateSubnetAZ1" {
  value = var.customer_private_subnet_az1_id
}

output "IngressPrivateSubnetAZ2" {
  value = var.customer_private_subnet_az2_id
}

output "NATGateway" {
  value = aws_nat_gateway.nat_gw.id
}

output "KubeconfigCommand" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks_cluster.cluster_name} --profile your-aws-profile"
}

output "EKSAdminUsers" {
  value = var.eks_admin_users
}
