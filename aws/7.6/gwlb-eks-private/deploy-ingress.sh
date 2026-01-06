#!/bin/bash

echo "🚀 Desplegando Ingress Controller y Nginx en subnets privadas (FortiGate routing)..."

# 1. Instalar AWS Load Balancer Controller
echo "📦 Instalando AWS Load Balancer Controller..."

# Crear service account
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
EOF

# Instalar con Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=customer-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# 2. Desplegar Nginx
echo "🌐 Desplegando Nginx..."
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
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
    alb.ingress.kubernetes.io/subnets: subnet-0b8b8b8b8b8b8b8b8,subnet-06af0c59e9fd58e06
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
echo "📋 Para verificar el estado:"
echo "kubectl get pods -l app=nginx"
echo "kubectl get svc nginx-service"
echo "kubectl get ingress nginx-ingress"
echo ""
echo "🌍 Para obtener la URL del Load Balancer (interno):"
echo "kubectl get ingress nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
echo "🔒 El ALB está en subnets privadas - el tráfico pasará por FortiGate"
echo "⏳ El Load Balancer puede tardar 2-3 minutos en estar disponible..."
