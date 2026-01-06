#!/bin/bash

# Script para arreglar permisos IAM del AWS Load Balancer Controller
# Cargar configuración
source ./ingress.config

echo "🔧 Arreglando permisos IAM para AWS Load Balancer Controller..."

# Verificar configuración AWS
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Error: No se puede acceder a AWS. Verifica tus credenciales."
    exit 1
fi

echo "📊 Cuenta AWS: $ACCOUNT_ID"

# 1. Crear IAM policy si no existe
echo "📋 Verificando IAM policy..."
aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy &>/dev/null || {
    echo "📋 Creando IAM policy..."
    curl -s -o /tmp/iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file:///tmp/iam_policy.json \
        --region $REGION
    rm -f /tmp/iam_policy.json
    echo "✅ Policy creada"
}

# 2. Encontrar el rol del node group
echo "🔍 Buscando node role..."
NODE_ROLE_ARN=$(aws eks describe-nodegroup \
    --cluster-name $CLUSTER_NAME \
    --nodegroup-name $(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --query 'nodegroups[0]' --output text) \
    --query 'nodegroup.nodeRole' --output text 2>/dev/null)

if [ -n "$NODE_ROLE_ARN" ] && [ "$NODE_ROLE_ARN" != "None" ]; then
    NODE_ROLE_NAME=$(echo $NODE_ROLE_ARN | cut -d'/' -f2)
    echo "✅ Node role encontrado: $NODE_ROLE_NAME"
else
    echo "⚠️  Intentando con nombre estándar..."
    NODE_ROLE_NAME="${CLUSTER_NAME}-eks-node-role"
fi

# 3. Agregar todas las políticas necesarias
echo "🔐 Agregando permisos necesarios..."

POLICIES=(
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
    "arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy"
)

for policy in "${POLICIES[@]}"; do
    policy_name=$(echo $policy | cut -d'/' -f3)
    echo "📎 Agregando $policy_name..."
    aws iam attach-role-policy \
        --role-name $NODE_ROLE_NAME \
        --policy-arn $policy 2>/dev/null && echo "  ✅ $policy_name agregada" || echo "  ⚠️  $policy_name ya existe o error"
done

# 4. Verificar permisos actuales
echo ""
echo "📋 Políticas actuales del rol $NODE_ROLE_NAME:"
aws iam list-attached-role-policies --role-name $NODE_ROLE_NAME --query 'AttachedPolicies[].PolicyName' --output table 2>/dev/null || echo "❌ No se pudo listar políticas"

echo ""
echo "✅ Configuración de permisos completada!"
echo "💡 Ahora ejecuta: ./deploy-ingress-complete.sh"
