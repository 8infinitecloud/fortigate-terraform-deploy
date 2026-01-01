# Multiregion Variables
variable "enable_multiregion" {
  description = "Enable multiregion deployment"
  type        = bool
  default     = false
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
  default     = "us-west-2"
}

variable "secondary_az1" {
  description = "Secondary region AZ1"
  type        = string
  default     = "us-west-2a"
}

variable "secondary_az2" {
  description = "Secondary region AZ2"
  type        = string
  default     = "us-west-2b"
}

# Secondary VPC CIDR
variable "secondary_vpc_cidr" {
  description = "CIDR block for secondary VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "secondary_public_subnet_az1" {
  description = "Public subnet AZ1 in secondary region"
  type        = string
  default     = "10.2.0.0/24"
}

variable "secondary_public_subnet_az2" {
  description = "Public subnet AZ2 in secondary region"
  type        = string
  default     = "10.2.1.0/24"
}

variable "secondary_private_subnet_az1" {
  description = "Private subnet AZ1 in secondary region"
  type        = string
  default     = "10.2.2.0/24"
}

variable "secondary_private_subnet_az2" {
  description = "Private subnet AZ2 in secondary region"
  type        = string
  default     = "10.2.3.0/24"
}

# Pass primary region variables for cross-region routing
variable "primary_gwlb_service_name" {
  description = "Primary region GWLB service name"
  type        = string
}
