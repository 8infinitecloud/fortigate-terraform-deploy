# 🚀 Deployment Instructions for gwlb-eks-private

## Prerequisites
1. ✅ `gwlb-crossaz` already deployed
2. ✅ VPC ID: `vpc-0c939eaa020ee2056`

## Required Steps Before Pipeline Deployment

### 1. Get Subnet IDs
You need to find the subnet IDs from your existing `gwlb-crossaz` deployment:

```bash
# Option 1: From gwlb-crossaz terraform output
cd ../gwlb-crossaz
terraform output

# Option 2: Use AWS CLI
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0c939eaa020ee2056" --query 'Subnets[*].[SubnetId,Tags[?Key==`Name`].Value|[0],AvailabilityZone]' --output table
```

### 2. Update terraform.tfvars
Replace the placeholder values in `terraform.tfvars`:

```hcl
customer_public_subnet_az1_id = "subnet-ACTUAL_PUBLIC_AZ1_ID"
customer_public_subnet_az2_id = "subnet-ACTUAL_PUBLIC_AZ2_ID"
customer_private_subnet_az1_id = "subnet-ACTUAL_PRIVATE_AZ1_ID"
customer_private_subnet_az2_id = "subnet-ACTUAL_PRIVATE_AZ2_ID"
```

### 3. Commit Changes
```bash
git add terraform.tfvars
git commit -m "Configure subnet IDs for gwlb-eks-private"
git push
```

## Pipeline Deployment
1. Go to GitHub Actions
2. Select "Deploy FortiGate to AWS"
3. Configure:
   - **FortiGate Version**: `7.6`
   - **Deployment Type**: `gwlb-eks-private`
   - **AWS Region**: Same as your gwlb-crossaz deployment
   - **Other fields**: Not used for this deployment type

## What Gets Created
- ✅ New private subnets for EKS worker nodes
- ✅ EKS cluster with private API endpoint
- ✅ NAT Gateways for internet access
- ✅ Route tables for EKS subnets
- ✅ IAM roles for EKS

## Architecture
```
Existing gwlb-crossaz:
├── FortiGate VPC (10.1.0.0/16)
└── Customer VPC (20.1.0.0/16)
    ├── Public Subnets (20.1.0.0/24, 20.1.2.0/24)
    ├── Private Subnets (20.1.1.0/24, 20.1.3.0/24) ← Reserved for Ingress
    └── NEW EKS Subnets (20.1.10.0/24, 20.1.11.0/24) ← EKS Worker Nodes
```

## Troubleshooting
- **Error: terraform.tfvars not found**: Make sure you committed the file
- **Error: subnet not found**: Verify subnet IDs are correct
- **Error: VPC not found**: Check VPC ID and region match
