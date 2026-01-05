# EKS Private Cluster Add-on for FortiGate GWLB Cross-AZ

## Overview
This module adds an EKS cluster with private nodes to an existing `gwlb-crossaz` deployment. It creates NAT Gateways and configures the EKS cluster to use the existing Customer VPC infrastructure.

## Prerequisites
1. Deploy `gwlb-crossaz` first
2. Collect the required VPC and subnet IDs from the outputs

## Required Variables
From your `gwlb-crossaz` deployment outputs, you need:
- `customer_vpc_id`: Customer VPC ID
- `customer_public_subnet_az1_id`: Public subnet AZ1 ID
- `customer_public_subnet_az2_id`: Public subnet AZ2 ID  
- `customer_private_subnet_az1_id`: Private subnet AZ1 ID
- `customer_private_subnet_az2_id`: Private subnet AZ2 ID
- `customer_igw_id`: Internet Gateway ID

## Deployment Steps
1. Deploy `gwlb-crossaz` first:
   ```bash
   cd aws/7.6/gwlb-crossaz
   terraform apply
   ```

2. Get the outputs and update `terraform.tfvars`:
   ```bash
   terraform output
   ```

3. Deploy EKS add-on:
   ```bash
   cd ../gwlb-eks-private
   # Update terraform.tfvars with the VPC/subnet IDs
   terraform init
   terraform apply
   ```

## What This Creates
- **New private subnets** for EKS worker nodes (separate from existing ones)
- **EKS cluster** in the new private subnets
- **NAT Gateways** for internet access
- **Route tables** for the new EKS private subnets
- **IAM roles** for EKS cluster and nodes

## Architecture
- **Existing private subnets**: Reserved for ingress controllers
- **New EKS private subnets**: Dedicated for worker nodes
- **NAT Gateways**: Provide outbound internet access for EKS nodes
- **FortiGate GWLB**: Protects all traffic flows

## Cleanup
```bash
terraform destroy
```

Note: Destroy this module before destroying the base `gwlb-crossaz` infrastructure.
