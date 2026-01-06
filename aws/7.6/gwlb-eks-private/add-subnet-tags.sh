#!/bin/bash

# Cargar configuración
source ./ingress.config

# Configurar AWS profile si está definido
if [ -n "$AWS_PROFILE" ]; then
  export AWS_PROFILE=$AWS_PROFILE
  echo "🔑 Usando AWS Profile: $AWS_PROFILE"
fi

echo "🏷️ Agregando tags necesarios a las subnets para ALB..."
echo "📍 Subnets objetivo: $INGRESS_SUBNET_AZ1, $INGRESS_SUBNET_AZ2"
echo "📍 Cluster: $CLUSTER_NAME"
echo "📍 Region: $REGION"

# Tags requeridos para subnets privadas (internal ALB)
echo ""
echo "📍 Agregando tags a subnet $INGRESS_SUBNET_AZ1..."
aws ec2 create-tags \
    --resources $INGRESS_SUBNET_AZ1 \
    --tags "Key=kubernetes.io/role/internal-elb,Value=1" "Key=kubernetes.io/cluster/$CLUSTER_NAME,Value=owned" \
    --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ Tags agregados exitosamente a $INGRESS_SUBNET_AZ1"
else
    echo "❌ Error agregando tags a $INGRESS_SUBNET_AZ1"
fi

echo ""
echo "📍 Agregando tags a subnet $INGRESS_SUBNET_AZ2..."
aws ec2 create-tags \
    --resources $INGRESS_SUBNET_AZ2 \
    --tags "Key=kubernetes.io/role/internal-elb,Value=1" "Key=kubernetes.io/cluster/$CLUSTER_NAME,Value=owned" \
    --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ Tags agregados exitosamente a $INGRESS_SUBNET_AZ2"
else
    echo "❌ Error agregando tags a $INGRESS_SUBNET_AZ2"
fi

echo ""
echo "🔍 Verificando tags agregados:"
aws ec2 describe-subnets \
    --subnet-ids $INGRESS_SUBNET_AZ1 $INGRESS_SUBNET_AZ2 \
    --query 'Subnets[*].[SubnetId,Tags[?Key==`kubernetes.io/role/internal-elb` || Key==`kubernetes.io/cluster/customer-eks-cluster`]]' \
    --region $REGION

echo ""
echo "✅ Proceso completado!"
