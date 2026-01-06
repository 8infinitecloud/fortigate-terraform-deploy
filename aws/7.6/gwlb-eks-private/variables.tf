//AWS Configuration
variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

// Existing VPC and Subnet IDs from gwlb-crossaz deployment
variable "customer_vpc_id" {
  description = "Customer VPC ID from gwlb-crossaz deployment"
  type        = string
  default     = "vpc-009cd288bad3903dc"
}

variable "customer_public_subnet_az1_id" {
  description = "Customer public subnet AZ1 ID from gwlb-crossaz"
  type        = string
  default     = "subnet-02d5d12b41c0d846f"
}

variable "customer_public_subnet_az2_id" {
  description = "Customer public subnet AZ2 ID from gwlb-crossaz"
  type        = string
  default     = "subnet-05a64f746bb4fc811"
}

variable "customer_private_subnet_az1_id" {
  description = "Customer private subnet AZ1 ID from gwlb-crossaz (reserved for ingress)"
  type        = string
  default     = "subnet-0c19baa05aec046cc"
}

variable "customer_private_subnet_az2_id" {
  description = "Customer private subnet AZ2 ID from gwlb-crossaz (reserved for ingress)"
  type        = string
  default     = "subnet-06af0c59e9fd58e06"
}

// New subnets for EKS worker nodes
variable "eks_private_subnet_az1_cidr" {
  description = "CIDR block for EKS private subnet AZ1"
  type        = string
  default     = "10.1.200.0/24"
}

variable "eks_private_subnet_az2_cidr" {
  description = "CIDR block for EKS private subnet AZ2"
  type        = string
  default     = "10.1.201.0/24"
}

variable "az1" {
  description = "Availability Zone 1"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Availability Zone 2"
  type        = string
  default     = "us-east-1b"
}

// EKS Cluster Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "customer-eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "Instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_capacity" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = false
}

variable "eks_admin_users" {
  description = "List of IAM users to grant admin access to EKS cluster"
  type        = list(string)
  default     = []
}

variable "public_access_cidrs" {
  description = "CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
