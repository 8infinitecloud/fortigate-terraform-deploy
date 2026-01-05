# Existing infrastructure from gwlb-crossaz deployment
customer_vpc_id = "vpc-0c939eaa020ee2056"

# REQUIRED: Get these subnet IDs from your gwlb-crossaz deployment
# Run: cd ../gwlb-crossaz && terraform output
# Or use AWS Console to find subnets in the VPC above
customer_public_subnet_az1_id = "subnet-09236d6190c791e55"
customer_public_subnet_az2_id = "subnet-01cd4de7b2c0febe2"
customer_private_subnet_az1_id = "subnet-08ea1a92fe396f960"
customer_private_subnet_az2_id = "subnet-0b10169ec035c91c0"

# New subnets for EKS worker nodes (will be created automatically)
eks_private_subnet_az1_cidr = "20.1.10.0/24"
eks_private_subnet_az2_cidr = "20.1.11.0/24"

# EKS Configuration
cluster_name = "customer-eks-cluster"
kubernetes_version = "1.28"
node_instance_types = ["t3.medium"]
desired_capacity = 2
max_capacity = 4
min_capacity = 1
endpoint_public_access = false

# add file