#!/bin/bash

# Cargar configuración
source ./ingress.config

# Configurar AWS profile si está definido
if [ -n "$AWS_PROFILE" ]; then
  export AWS_PROFILE=$AWS_PROFILE
  echo "🔑 Usando AWS Profile: $AWS_PROFILE"
fi

echo "🚀 Desplegando Ingress Controller completo..."
echo "📍 ALB se creará en subnets: $INGRESS_SUBNET_AZ1, $INGRESS_SUBNET_AZ2"

# 1. Verificar configuración AWS
echo "🔍 Verificando configuración AWS..."
CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Error: No se puede acceder a AWS. Verifica tus credenciales."
    exit 1
fi

echo "📊 Cuenta AWS actual: $CURRENT_ACCOUNT"

# Verificar que kubectl funciona
kubectl cluster-info &>/dev/null || {
    echo "❌ Error: kubectl no puede conectar al cluster"
    echo "💡 Ejecuta: aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME"
    exit 1
}

# 2. Obtener account ID
ACCOUNT_ID=$CURRENT_ACCOUNT

# 2. Crear IAM policy si no existe
echo "📋 Verificando IAM policy..."
aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy &>/dev/null || {
    echo "📋 Creando IAM policy..."
    curl -s -o /tmp/iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file:///tmp/iam_policy.json \
        --region $REGION
    rm -f /tmp/iam_policy.json
}

# 2.1. Encontrar y configurar permisos del node role (COMPLETO)
echo "🔐 Configurando permisos del node role..."

# Obtener el rol real del node group
NODE_ROLE_ARN=$(aws eks describe-nodegroup \
    --cluster-name $CLUSTER_NAME \
    --nodegroup-name $(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --query 'nodegroups[0]' --output text) \
    --query 'nodegroup.nodeRole' --output text 2>/dev/null)

if [ -n "$NODE_ROLE_ARN" ] && [ "$NODE_ROLE_ARN" != "None" ]; then
    NODE_ROLE_NAME=$(echo $NODE_ROLE_ARN | cut -d'/' -f2)
    echo "✅ Node role encontrado: $NODE_ROLE_NAME"
else
    echo "⚠️  Buscando rol con métodos alternativos..."
    # Intentar obtener desde instancias EC2
    NODE_INSTANCE_ID=$(kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' | cut -d'/' -f5)
    if [ -n "$NODE_INSTANCE_ID" ]; then
        INSTANCE_PROFILE=$(aws ec2 describe-instances --instance-ids $NODE_INSTANCE_ID --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' --output text 2>/dev/null)
        if [ -n "$INSTANCE_PROFILE" ] && [ "$INSTANCE_PROFILE" != "None" ]; then
            NODE_ROLE_NAME=$(echo $INSTANCE_PROFILE | cut -d'/' -f2 | sed 's/-instance-profile$//')
            echo "✅ Node role encontrado via EC2: $NODE_ROLE_NAME"
        fi
    fi
    
    # Fallback a nombre estándar
    if [ -z "$NODE_ROLE_NAME" ]; then
        NODE_ROLE_NAME="${CLUSTER_NAME}-eks-node-role"
        echo "📋 Usando nombre estándar: $NODE_ROLE_NAME"
    fi
fi

# Agregar TODAS las políticas necesarias
echo "🔐 Agregando permisos completos..."
POLICIES=(
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    "arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy"
)

for policy in "${POLICIES[@]}"; do
    policy_name=$(echo $policy | cut -d'/' -f3)
    echo "📎 Agregando $policy_name..."
    aws iam attach-role-policy \
        --role-name $NODE_ROLE_NAME \
        --policy-arn $policy 2>/dev/null && echo "  ✅ $policy_name" || echo "  ⚠️  $policy_name (ya existe o error)"
done

# Verificar permisos críticos
echo "🔍 Verificando permisos críticos..."
aws iam list-attached-role-policies --role-name $NODE_ROLE_NAME --query 'AttachedPolicies[?contains(PolicyName, `ElasticLoadBalancing`) || contains(PolicyName, `AWSLoadBalancerController`)].PolicyName' --output table 2>/dev/null || echo "⚠️  No se pudo verificar políticas"

# 3. Crear service account (método simple, sin eksctl)
echo "🔐 Creando service account..."
kubectl create serviceaccount aws-load-balancer-controller -n kube-system --dry-run=client -o yaml | kubectl apply -f -

# 4. Instalar AWS Load Balancer Controller con Helm
echo "📦 Instalando AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts &>/dev/null
helm repo update

# Desinstalar si existe
helm uninstall aws-load-balancer-controller -n kube-system &>/dev/null || true

# Instalar
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$REGION \
  --wait --timeout=300s

# 5. Verificar que el controller esté corriendo
echo "⏳ Verificando que el controller esté listo..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=aws-load-balancer-controller -n kube-system --timeout=300s

echo "📋 Estado del controller:"
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# 6. Desplegar Nginx si no existe
echo "🌐 Desplegando Nginx..."
kubectl get deployment nginx-deployment &>/dev/null || {
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF
}

# 7. Crear/actualizar Ingress
echo "🔗 Creando Ingress..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
    alb.ingress.kubernetes.io/subnets: $INGRESS_SUBNET_AZ1,$INGRESS_SUBNET_AZ2
    alb.ingress.kubernetes.io/healthcheck-path: /
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
EOF

echo "✅ Despliegue completado!"
echo ""

# Verificación post-instalación
echo "🔍 Verificando estado del sistema..."
echo ""

# 1. Estado del controller
echo "📋 Estado del AWS Load Balancer Controller:"
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# 2. Estado del ingress
echo ""
echo "📋 Estado del Ingress:"
kubectl get ingress nginx-ingress

# 3. Verificar logs del controller por errores
echo ""
echo "🔍 Verificando logs del controller (últimas 5 líneas):"
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=5 | grep -E "(error|Error|ERROR)" || echo "✅ No hay errores visibles en los logs"

# 4. Esperar y verificar ALB
echo ""
echo "⏳ Esperando creación del ALB (puede tomar 2-3 minutos)..."
for i in {1..6}; do
    ALB_HOSTNAME=$(kubectl get ingress nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ -n "$ALB_HOSTNAME" ]; then
        echo "🌍 ALB creado exitosamente: $ALB_HOSTNAME"
        break
    else
        echo "⏳ Intento $i/6 - ALB aún no está listo..."
        sleep 30
    fi
done

if [ -z "$ALB_HOSTNAME" ]; then
    echo "⚠️  ALB no se ha creado aún. Verifica con:"
    echo "kubectl describe ingress nginx-ingress"
    echo "kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=20"
fi

echo ""
echo "📋 Comandos útiles para verificar:"
echo "kubectl get ingress nginx-ingress"
echo "kubectl describe ingress nginx-ingress"
echo "kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=20"
echo ""
echo "🔒 El ALB se creará en las subnets: $INGRESS_SUBNET_AZ1, $INGRESS_SUBNET_AZ2"
