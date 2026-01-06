#!/bin/bash

# Obtener subnet IDs de las subnets privadas (para ingress/FortiGate routing)
PRIVATE_SUBNET_AZ1=$(terraform output -raw IngressPrivateSubnetAZ1 2>/dev/null || echo "subnet-0b8b8b8b8b8b8b8b8")
PRIVATE_SUBNET_AZ2=$(terraform output -raw IngressPrivateSubnetAZ2 2>/dev/null || echo "subnet-06af0c59e9fd58e06")

echo "🚀 Desplegando Nginx con ALB interno en subnets privadas..."
echo "📍 Usando subnets: $PRIVATE_SUBNET_AZ1, $PRIVATE_SUBNET_AZ2"

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
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internal"
    service.beta.kubernetes.io/aws-load-balancer-subnets: "$PRIVATE_SUBNET_AZ1,$PRIVATE_SUBNET_AZ2"
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
EOF

echo "✅ Despliegue completado!"
echo ""
echo "📋 Para verificar el estado:"
echo "kubectl get pods -l app=nginx"
echo "kubectl get svc nginx-service"
echo ""
echo "🌍 Para obtener la URL del Load Balancer (interno):"
echo "kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
echo "🔒 El NLB está en subnets privadas - el tráfico pasará por FortiGate"
echo "⏳ El Load Balancer puede tardar 2-3 minutos en estar disponible..."
echo ""
echo "🔍 Monitorear el progreso:"
echo "watch 'kubectl get svc nginx-service'"
