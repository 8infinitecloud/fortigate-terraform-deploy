//AWS Configuration
variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "eu-west-1"
}

// Existing VPC and Subnet IDs from gwlb-crossaz deployment
variable "customer_vpc_id" {
  description = "Customer VPC ID from gwlb-crossaz deployment"
  type        = string
}

variable "customer_public_subnet_az1_id" {
  description = "Customer public subnet AZ1 ID from gwlb-crossaz"
  type        = string
}

variable "customer_public_subnet_az2_id" {
  description = "Customer public subnet AZ2 ID from gwlb-crossaz"
  type        = string
}

variable "customer_private_subnet_az1_id" {
  description = "Customer private subnet AZ1 ID from gwlb-crossaz"
  type        = string
}

variable "customer_private_subnet_az2_id" {
  description = "Customer private subnet AZ2 ID from gwlb-crossaz"
  type        = string
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
  default     = "1.28"
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

variable "public_access_cidrs" {
  description = "CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
