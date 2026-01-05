#!/bin/bash

# Helper script to get outputs from gwlb-crossaz deployment
# Run this from the gwlb-crossaz directory after deployment

echo "Getting outputs from gwlb-crossaz deployment..."
echo ""

CUSTOMER_VPC=$(terraform output -raw CustomerVPC 2>/dev/null)
FGTVM_VPC=$(terraform output -raw FGTVPC 2>/dev/null)

if [ -z "$CUSTOMER_VPC" ]; then
    echo "Error: Could not get CustomerVPC output. Make sure gwlb-crossaz is deployed."
    exit 1
fi

echo "Copy these values to your gwlb-eks-private/terraform.tfvars:"
echo ""
echo "customer_vpc_id = \"$CUSTOMER_VPC\""

# Get subnet IDs using AWS CLI
echo "Getting subnet information..."
REGION=$(terraform output -raw region 2>/dev/null || echo "eu-west-1")

# Get public subnets
PUBLIC_SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$CUSTOMER_VPC" "Name=tag:Name,Values=*public*" \
    --query 'Subnets[*].[SubnetId,AvailabilityZone]' \
    --output text \
    --region $REGION)

# Get private subnets  
PRIVATE_SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$CUSTOMER_VPC" "Name=tag:Name,Values=*private*" \
    --query 'Subnets[*].[SubnetId,AvailabilityZone]' \
    --output text \
    --region $REGION)

# Get IGW
IGW=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$CUSTOMER_VPC" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text \
    --region $REGION)

echo ""
echo "# Subnet IDs (verify AZ mapping):"
echo "$PUBLIC_SUBNETS" | while read subnet az; do
    echo "# Public subnet in $az: $subnet"
done

echo "$PRIVATE_SUBNETS" | while read subnet az; do
    echo "# Private subnet in $az: $subnet"
done

echo ""
echo "# Update these based on your AZ requirements:"
PUB_AZ1=$(echo "$PUBLIC_SUBNETS" | head -1 | cut -f1)
PUB_AZ2=$(echo "$PUBLIC_SUBNETS" | tail -1 | cut -f1)
PRIV_AZ1=$(echo "$PRIVATE_SUBNETS" | head -1 | cut -f1)
PRIV_AZ2=$(echo "$PRIVATE_SUBNETS" | tail -1 | cut -f1)

echo "customer_public_subnet_az1_id = \"$PUB_AZ1\""
echo "customer_public_subnet_az2_id = \"$PUB_AZ2\""
echo "customer_private_subnet_az1_id = \"$PRIV_AZ1\""
echo "customer_private_subnet_az2_id = \"$PRIV_AZ2\""
