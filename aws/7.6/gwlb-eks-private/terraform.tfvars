# Existing infrastructure from gwlb-crossaz deployment
customer_vpc_id = "vpc-009cd288bad3903dc"

# REQUIRED: Get these subnet IDs from your gwlb-crossaz deployment
# Run: cd ../gwlb-crossaz && terraform output
# Or use AWS Console to find subnets in the VPC above
customer_public_subnet_az1_id = "subnet-02d5d12b41c0d846f"
customer_public_subnet_az2_id = "subnet-05a64f746bb4fc811"
customer_private_subnet_az1_id = "subnet-0c19baa05aec046cc"
customer_private_subnet_az2_id = "subnet-06af0c59e9fd58e06"

# New subnets for EKS worker nodes (will be created automatically)
eks_private_subnet_az1_cidr = "10.1.100.0/24"
eks_private_subnet_az2_cidr = "10.1.101.0/24"

# EKS Configuration
cluster_name = "customer-eks-cluster"
kubernetes_version = "1.28"
node_instance_types = ["t3.medium"]
desired_capacity = 2
max_capacity = 4
min_capacity = 1
endpoint_public_access = false

# add file